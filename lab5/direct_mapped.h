#ifndef DIRECT_MAPPED_H
#define DIRECT_MAPPED_H

#include "main_memory.h"
#include "cache_stats.h"
#include "stdbool.h"

#define DIRECT_MAPPED_NUM_SETS 16
#define DIRECT_MAPPED_NUM_SETS_LN 4

typedef struct direct_mapped_cache
{
    main_memory* mm;                                // pointer to main memory
    cache_stats cs;                                 // struct of statistics for the cache (hit rate, etc.)
    memory_block* sets[DIRECT_MAPPED_NUM_SETS];     // array of sets (pointers to memory blocks) contained in the cache
    bool dirty[DIRECT_MAPPED_NUM_SETS];             // boolean flags to determine whether the data in each set has been modified (is "dirty") or not
    bool valid[DIRECT_MAPPED_NUM_SETS];             // boolean flags to determine whether a set has been filled in or not
} direct_mapped_cache;

// Do not edit below this line

direct_mapped_cache* dmc_init(main_memory* mm);

void dmc_store_word(direct_mapped_cache* dmc, void* addr, unsigned int val);

unsigned int dmc_load_word(direct_mapped_cache* dmc, void* addr);

void dmc_free(direct_mapped_cache* dmc);

#endif
