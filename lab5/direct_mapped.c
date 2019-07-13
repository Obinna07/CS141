#include "stdint.h"
#include "stdlib.h"
#include "memory_block.h"
#include "direct_mapped.h"
#include "math.h"
#include "stdbool.h"

// This is a function called "dmc_init" which will return a pointer to the cache (whose datatype is "direct_mapped_cache", which is a struct defined in direct_mapped_cache.h)
direct_mapped_cache* dmc_init(main_memory* mm)
{
    // allocate memory for a direct_mapped_cache struct
    direct_mapped_cache *cache = malloc(sizeof(direct_mapped_cache));

    // initialize the DMC
    cache->mm = mm;
    cache->cs = cs_init();

    for (int i = 0; i < DIRECT_MAPPED_NUM_SETS; i++) {
        cache->sets[i] = NULL;
        cache->dirty[i] = false;
        cache->valid[i] = false;
    }

    // return the initialized cache
    return cache;
}

// helper function to compute set that memory block belongs to (given a *starting* memory block address)
static int addr_to_set(void* addr)
{
    unsigned int address = (uintptr_t)addr;
    int set = (address >> MAIN_MEMORY_BLOCK_SIZE_LN) % DIRECT_MAPPED_NUM_SETS;
    return set;
}

/* function called "dmc_store_word" in which you are trying to store [val] in the main memory by using the direct_mapped_cache (we're able to access memory through the dmc
    because memory (mm) is an element of cache, which we initialized above)*/
void dmc_store_word(direct_mapped_cache* dmc, void* addr, unsigned int val)
{
    // compute the start address of the memory block addr is contained in
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;

    volatile int set = addr_to_set(addr);

    /* if the cache has the data at the requested memory address to be rewritten (WRITE HIT), then we write directly
     * to the cache block */
    if (dmc->valid[set] == true && mb_start_addr == dmc->sets[set]->start_addr) {
        // get the found memory block from the correct cache set
        memory_block* mb_hit = dmc->sets[set];

        // get the address of the specific word in the block being read and rewrite it with the given value
        unsigned int* mb_hit_addr = mb_hit->data + addr_offt;
        *mb_hit_addr = val;

        // set the dirty bit of the modified set
        dmc->dirty[set] = true;

        // update the cache statistics
        ++dmc->cs.w_queries;
    }

    /* otherwise, if the memory address being rewritten isn't in the cache (WRITE MISS), then we read the
     * whole memory block from main memory and write the data to the appropriate word within the block */
    else {
        /* evict the memory block in this set; if it has been modified (is "dirty"), we need to write it
         * back to main memory as well to make sure the changes are stored */
        if (dmc->valid[set] == true) {
            if (dmc->dirty[set] == true) {
                mm_write(dmc->mm, dmc->sets[set]->start_addr, dmc->sets[set]);
            }

            // this block is no longer being used, so free its memory
            mb_free(dmc->sets[set]);
        }

        // load the memory block of data from main memory
        memory_block* mb_miss = mm_read(dmc->mm, mb_start_addr);

        // get the address of the specific word in the block being read and write the data
        unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
        *mb_miss_addr = val;

        dmc->sets[set] = mb_miss;
        dmc->dirty[set] = true;        // we set the dirty bit here since the loaded memory block was modified
        dmc->valid[set] = true;

        // update the cache statistics
        ++dmc->cs.w_queries;
        ++dmc->cs.w_misses;
    }
}

// return the word stored at memory address addr
unsigned int dmc_load_word(direct_mapped_cache* dmc, void* addr)
{
    // compute the start address of the memory block addr is contained in
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;

    unsigned int result, set = addr_to_set(addr);

    /* if the cache has the data from the requested memory address (READ HIT), then we return the data
     * from the cache */
    if (dmc->valid[set] == true && mb_start_addr == dmc->sets[set]->start_addr) {
        // get the found memory block from the correct cache set
        memory_block* mb_hit = dmc->sets[set];

        // get the address of the specific word in the block being read and get the data
        unsigned int* mb_hit_addr = mb_hit->data + addr_offt;
        result = *mb_hit_addr;

        // update the cache statistics
        ++dmc->cs.r_queries;
    }

    /* otherwise, if the memory the processor was looking for wasn't in the cache (READ MISS), then we
     * must read it from main memory and update the cache */
    else {
        // same eviction procedure as in dmc_store_word()
        if (dmc->valid[set] == true) {
            if (dmc->dirty[set] == true) {
                mm_write(dmc->mm, dmc->sets[set]->start_addr, dmc->sets[set]);
            }

            mb_free(dmc->sets[set]);
        }

        // load the memory block of data from main memory
        memory_block* mb_miss = mm_read(dmc->mm, mb_start_addr);

        // get the address of the specific word in the block being read and get the data
        unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
        result = *mb_miss_addr;

        dmc->sets[set] = mb_miss;
        dmc->dirty[set] = false;        // we do NOT set the dirty bit here since the new block wasn't modified
        dmc->valid[set] = true;

        // update the cache statistics
        ++dmc->cs.r_queries;
        ++dmc->cs.r_misses;
    }

    return result;
}

// free all the memory allocated for the cache
void dmc_free(direct_mapped_cache* dmc)
{
    // free all the memory blocks stored in the cache
    for (int i = 0; i < DIRECT_MAPPED_NUM_SETS; i++) {
        if (dmc->sets[i] != NULL) {
            mb_free(dmc->sets[i]);
        }
    }

    // free the cache struct allocation
    free(dmc);
}
