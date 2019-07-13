#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "memory_block.h"
#include "set_associative.h"
#include "stdbool.h"

// initialize the cache
set_associative_cache* sac_init(main_memory* mm)
{
    set_associative_cache* cache = malloc(sizeof(set_associative_cache));
    cache->mm = mm;
    cache->cs = cs_init();

    for (int set = 0; set < SET_ASSOCIATIVE_NUM_SETS; set++) {
        for (int way = 0; way < SET_ASSOCIATIVE_NUM_WAYS; way++) {
            cache->lru_tracker[set][way] = -1;
            cache->sets[set][way].mb = NULL;
            cache->sets[set][way].valid = false;
            cache->sets[set][way].dirty = false;
        }
    }

    return cache;
}

// determine which set a given memory address maps to in the cache
static int addr_to_set(void* addr)
{
    unsigned int address = (uintptr_t)addr;
    return (address >> MAIN_MEMORY_BLOCK_SIZE_LN) % SET_ASSOCIATIVE_NUM_SETS;
}

// return the least recently used (LRU) way index of the set
static int lru(set_associative_cache* sac, int set)
{
    int lru_way = -1;

    /* the LRU way will always have lru-tracker number (SET_ASSOCIATIVE_NUM_WAYS - 1), so just find the way with that tracker number
     * note that this function is only called if this set is full, so all lru-tracker numbers have been set
     * (in particular, they all have unique values between 0 and SET_ASSOCIATIVE_NUM_WAYS-1) */
    for (int i = 0; i < SET_ASSOCIATIVE_NUM_WAYS; i++) {
        if (sac->lru_tracker[set][i] == SET_ASSOCIATIVE_NUM_WAYS - 1) {
            lru_way = i;
            break;
        }
    }

    /* note that since we always return the way with the maximum lru-tracker number, lru_tracker[i] < SET_ASSOCIATIVE_NUM_WAYS for all i,
     * so the tracker cannot overflow (as with other implementations) */
    return lru_way;
}

// update the LRU-tracker when we use the way in the given set
static void mark_as_used(set_associative_cache* sac, int set, int way, bool hit)
{
    /* for a read/write miss, unless the way is unused (in which case it has tracker number -1), we increment each way's tracker number
     * we then give the used way a tracker number of 0; this ensures that tracker numbers are strictly higher for lesser recently used ways,
     * and all tracker numbers are unique */
    for (int i = 0; i < SET_ASSOCIATIVE_NUM_WAYS; i++) {
        if (sac->lru_tracker[set][i] >= 0) {

            /* note that if we have a read/write hit, the ordering of tracker numbers should not change except for
             * the used way getting a tracker number of 0; since this would give us 2 0s in the tracker, we
             * increment all the tracker numbers *less* than the tracker number of the used way; this both keeps
             * the remaining tracker numbers in the same order (and all unique) and prevents the tracker from overflowing */
            if (hit == false || sac->lru_tracker[set][i] < sac->lru_tracker[set][way])
                sac->lru_tracker[set][i]++;
        }
    }

    sac->lru_tracker[set][way] = 0;
}

// store the word val at address addr (for more comments see sac_load_word())
void sac_store_word(set_associative_cache* sac, void* addr, unsigned int val)
{
    // compute memory block addresses/relevant set number
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;
    int set = addr_to_set(addr);

    // determine if any way's memory block in the relevant set has the data at the requested address
    bool write_hit = false;
    int way;
    for (way = 0; way < SET_ASSOCIATIVE_NUM_WAYS; way++) {
        if (sac->sets[set][way].valid == true && sac->sets[set][way].mb->start_addr == mb_start_addr) {
            write_hit = true;
            break;
        }
    }

    // if the cache has data at the address (WRITE HIT), overwrite it with the given value
    if (write_hit == true) {
        memory_block* mb_hit = sac->sets[set][way].mb;
        unsigned int* word_addr = mb_hit->data + addr_offt;
        *word_addr = val;

        // set the dirty bit of this way high since we modified its data
        sac->sets[set][way].dirty = true;

        // update cache statistics
        ++sac->cs.w_queries;
    }

    /* otherwise, if the cache has no data at the address (WRITE MISS), then we read the relevant memory
     * block from main memory, overwrite the word at the given address, and add it to the cache */
    else {
        int lru_way = SET_ASSOCIATIVE_NUM_WAYS, unused_way = SET_ASSOCIATIVE_NUM_WAYS;

        // determine if there are any empty ways in the set for us to put the new memory block in
        for (int i = 0; i < SET_ASSOCIATIVE_NUM_WAYS; i++) {
            if (sac->sets[set][i].valid == false) {
                unused_way = i;
                break;
            }
        }

        // if there isn't one, we need to evict a block in the set (and write it to main memory if it has been modified)
        if (unused_way == SET_ASSOCIATIVE_NUM_WAYS) {
            lru_way = lru(sac, set);

            if (sac->sets[set][lru_way].dirty == true) {
                mm_write(sac->mm, sac->sets[set][lru_way].mb->start_addr, sac->sets[set][lru_way].mb);
            }

            mb_free(sac->sets[set][lru_way].mb);
        }

        // load the block of the requested data from main memory and modify it
        memory_block* mb_miss = mm_read(sac->mm, mb_start_addr);
        unsigned int* word_addr = mb_miss->data + addr_offt;
        *word_addr = val;

        // replace/fill the way slot with a new way containing the read and modified data memory block (note that we set the dirty bit high here)
        way = (unused_way == SET_ASSOCIATIVE_NUM_WAYS ? lru_way : unused_way);
        set_associative_way replacement = { .mb = mb_miss, .valid = true, .dirty = true };
        sac->sets[set][way] = replacement;

        // update cache statistics
        ++sac->cs.w_queries;
        ++sac->cs.w_misses;
    }

    // marked this way as used for the lru tracker
    mark_as_used(sac, set, way, write_hit);
}

// return the word stored at address addr
unsigned int sac_load_word(set_associative_cache* sac, void* addr)
{
    // compute the start address of the memory block addr is contained in
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;

    // find which set this memory address maps to
    int set = addr_to_set(addr);

    // determine if any way's memory block in the relevant set has the data at the requested address
    bool read_hit = false;
    int way;
    for (way = 0; way < SET_ASSOCIATIVE_NUM_WAYS; way++) {
        if (sac->sets[set][way].valid == true && sac->sets[set][way].mb->start_addr == mb_start_addr) {
            read_hit = true;
            break;
        }
    }

    unsigned int result;

    // if the cache has the data (READ HIT), then return it
    if (read_hit == true) {
        // get the memory block containing the data
        memory_block* mb_hit = sac->sets[set][way].mb;

        // get the address of the specific word requested and store it in result
        unsigned int* word_addr = mb_hit->data + addr_offt;
        result = *word_addr;

        // update cache statistics
        ++sac->cs.r_queries;
    }

    /* otherwise, if the cache doesn't have the data (READ MISS), then read/return the data from
     * main memory and put the new data in the cache */
    else {
        int lru_way = SET_ASSOCIATIVE_NUM_WAYS, unused_way = SET_ASSOCIATIVE_NUM_WAYS;

        // determine if there are any empty ways in the set for us to put the new memory block in
        for (int i = 0; i < SET_ASSOCIATIVE_NUM_WAYS; i++) {
            if (sac->sets[set][i].valid == false) {
                unused_way = i;
                break;
            }
        }

        // if there isn't one, we need to evict a block in the set
        if (unused_way == SET_ASSOCIATIVE_NUM_WAYS) {
            // get the least recently used (LRU) way from this set
            lru_way = lru(sac, set);

            /* if the memory block in the way has been modified (is "dirty"), we need to write it back to
             * main memory to store the changes */
            if (sac->sets[set][lru_way].dirty == true) {
                mm_write(sac->mm, sac->sets[set][lru_way].mb->start_addr, sac->sets[set][lru_way].mb);
            }

            // free this block since we're done with it either way
            mb_free(sac->sets[set][lru_way].mb);
        }

        // load the block of the requested data from main memory
        memory_block* mb_miss = mm_read(sac->mm, mb_start_addr);

        // calculate the address of the specific word requested and get the data
        unsigned int* word_addr = mb_miss->data + addr_offt;
        result = *word_addr;

        // replace/fill the way slot with a new way containing the read data memory block
        way = (unused_way == SET_ASSOCIATIVE_NUM_WAYS ? lru_way : unused_way);
        set_associative_way replacement = { .mb = mb_miss, .valid = true, .dirty = false };
        sac->sets[set][way] = replacement;

        // update cache statistics
        ++sac->cs.r_queries;
        ++sac->cs.r_misses;
    }

    // marked this way as used for the lru tracker
    mark_as_used(sac, set, way, read_hit);

    return result;
}

// free all the memory allocated for the cache
void sac_free(set_associative_cache* sac)
{
    // free all the memory blocks still stored in the cache
    for (int i = 0; i < SET_ASSOCIATIVE_NUM_SETS; i++) {
        for (int j = 0; j < SET_ASSOCIATIVE_NUM_WAYS; j++) {
            if (sac->sets[i][j].mb != NULL) {
                mb_free(sac->sets[i][j].mb);
            }
        }
    }

    // free the cache itself
    free(sac);
}
