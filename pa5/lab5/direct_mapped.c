#include "stdint.h"
#include "stdlib.h"
#include "memory_block.h"
#include "direct_mapped.h"
#include "math.h"
#include "stdbool.h"

//`memory_block arr[DIRECT_MAPPED_NUM_SETS];
//`memory_block result;

// TODO:
// - 'valgrind leak-check=full' claims dmc_load_word() is leaking memory in test22
// - need to write our own test cases for corner cases

// This is a function called "dmc_init" which will return a pointer to the cache (whose datatype is "direct_mapped_cache", which is a struct defined in direct_mapped_cache.h)
direct_mapped_cache* dmc_init(main_memory* mm)
{
    // allocate memory for a direct_mapped_cache struct
    direct_mapped_cache *cache = malloc(sizeof(direct_mapped_cache));

    // initialize the DMC
    cache->mm = mm;
    cache->cs = cs_init();
    //`cache->arr = arr;
    //`cache->result = result;

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
    //`int set = fmod(address / pow(2,5), DIRECT_MAPPED_NUM_SETS);
    int set = (address >> DIRECT_MAPPED_NUM_SETS_LN) % DIRECT_MAPPED_NUM_SETS;
    return set;
}

/* function called "dmc_store_word" in which you are trying to store [val] in the main memory by using the direct_mapped_cache (we're able to access memory through the dmc
    because memory (mm) is an element of cache, which we initialized above)*/
void dmc_store_word(direct_mapped_cache* dmc, void* addr, unsigned int val)
{
    // compute the start address of the memory block addr is contained in
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;

    int set = addr_to_set(addr);

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
        // load the memory block of data from main memory
        memory_block* mb_miss = mm_read(dmc->mm, mb_start_addr);

        // get the address of the specific word in the block being read and write the data
        unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
        *mb_miss_addr = val;

        // set the dirty bit since the new memory block has been edited
        dmc->dirty[set] = true;

        // update the cache statistics
        ++dmc->cs.w_queries;
        ++dmc->cs.w_misses;

        /* replace the memory block in this set with the block loaded from main memory
         * if the replaced block has been modified, however (is "dirty"), we need to write it
         * back to main memory as well to make sure the changes are stored */
        if (dmc->dirty[set] == true) {
            mm_write(dmc->mm, dmc->sets[set]->start_addr, dmc->sets[set]);
            free(dmc->sets[set]);
        }
        dmc->sets[set] = mb_miss;
        dmc->dirty[set] = false;
        dmc->valid[set] = true;
    }
}

// return the word stored at memory address addr
unsigned int dmc_load_word(direct_mapped_cache* dmc, void* addr)
{
    /* Compute the memory block's cache-line (there will be 16 distinct cache-lines, since
        we have 16 sets in our cache array (each set is for a memory block) */

    // compute the start address of the memory block addr is contained in
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;

    /* check the relevent cache-line (using the set) to see if the memory start address
        of the memory the block is look for matches that of the memory block found
        in the array at this location (cache_arr[set]) */

    //`unsigned int mb_start_address = (uintptr_t)mb_start_addr;

    unsigned int result, set = addr_to_set(addr);

    //`if (mb_start_address == dmc->sets[addr_to_set(addr)])

    /* if the cache has the data from the requested memory address (READ HIT), then we return the data
     * from the cache */
    if (dmc->valid[set] == true && mb_start_addr == dmc->sets[set]->start_addr) {
        //`cache->result = (uintptr_t)arr[addr_to_set(addr)];

        // get the found memory block from the correct cache set
        memory_block* mb_hit = dmc->sets[set];

        // get the address of the specific word in the block being read and get the data
        unsigned int* mb_hit_addr = mb_hit->data + addr_offt;
        result = *mb_hit_addr;

        // update the cache statistics
        ++dmc->cs.r_queries;

        // update statistics
        // ++dmc->cs.r_queries;
        // ++dmc->cs.r_hits;

        //`return cache->result;
    }

    /* otherwise, if the memory the processor was looking for wasn't in the cache (READ MISS), then we
     * must read it from main memory and update the cache */
    else {
        // load the memory block of data from main memory
        memory_block* mb_miss = mm_read(dmc->mm, mb_start_addr);

        // get the address of the specific word in the block being read and get the data
        unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
        result = *mb_miss_addr;

        // update the cache statistics
        ++dmc->cs.r_queries;
        ++dmc->cs.r_misses;

        // update statistics
        // ++dmc->cs.r_queries;
        // ++dmc->cs.r_misses;

        /* replace the memory block in this set with the block loaded from main memory
         * if the replaced block has been modified, however (is "dirty"), we need to write it
         * back to main memory as well to make sure the changes are stored */
        if (dmc->dirty[set] == true) {
            mm_write(dmc->mm, dmc->sets[set]->start_addr, dmc->sets[set]);
            free(dmc->sets[set]);
        }
        dmc->sets[set] = mb_miss;
        dmc->dirty[set] = false;
        dmc->valid[set] = true;
    }

    return result;
}

void dmc_free(direct_mapped_cache* dmc)
{
    int i;
    for (i = 0; i < DIRECT_MAPPED_NUM_SETS; i++) {
        //free(dmc->sets[i]->data);
        free(dmc->sets[i]);
    }

    free(dmc);
}
