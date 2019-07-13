#include "stdint.h"
#include "stdlib.h"
#include "stdio.h"
#include "memory_block.h"
#include "fully_associative.h"
#include "stdbool.h"

fully_associative_cache* fac_init(main_memory* mm)
{
    fully_associative_cache* cache = malloc(sizeof(fully_associative_cache));

    cache->mm = mm;
    cache->cs = cs_init();

    for (int i = 0; i < FULLY_ASSOCIATIVE_NUM_WAYS; i++)
    {
        cache->ways[i] = NULL;
        cache->dirty[i]=false;
        cache->valid[i]=false;
    }

    // initialize the linked list that we will use to keep track of the mru
    cache->mru = malloc(sizeof(node));
    struct node* current = cache->mru;
    for (int i = FULLY_ASSOCIATIVE_NUM_WAYS-1; i > 0; i--)
    {
        current->way = i;

        current->next = malloc(sizeof(node));
        current->next->previous = current;

        current = current->next;
    }

    // note that current is now the tail of the linked list, but it hasn't been initialized yet
    current->way = 0;
    current->next = NULL;

    return cache;
}

// Optional

// static void mark_as_used(fully_associative_cache* fac, int way)
// {
//     ++fac->counter;
//     fac->mru[way] = fac->mru[way] + fac->counter;
// }

// static int mru(fully_associative_cache* fac)
// {
//     int next_way = 0, min_mru = fac->mru[0];

//     for (int i = 0; i < (FULLY_ASSOCIATIVE_NUM_WAYS-1); i++)
//     {
//         if (min_mru < fac->mru[i])
//         {
//             min_mru = fac->mru[i];
//             next_way = i;
//         }
//     }
//     return next_way;
// }

void fac_store_word(fully_associative_cache* fac, void* addr, unsigned int val)
{
    int found = 0;

    // compute the start address of the memory block addr is contained in
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;


    /* if the cache has the data at the requested memory address to be rewritten (WRITE HIT), then we write directly
     * to the cache block */
    for (int i = 0; i < FULLY_ASSOCIATIVE_NUM_WAYS; i++)
    {
        if (fac->valid[i] == true && mb_start_addr == fac->ways[i]->start_addr)
        {
            // get the found memory block from the correct cache way
            memory_block* mb_hit = fac->ways[i];

            // get the address of the specific word in the block being read and rewrite it with the given value
            unsigned int* mb_hit_addr = mb_hit->data + addr_offt;
            *mb_hit_addr = val;

            // set the dirty bit of the modified set
            fac->dirty[i] = true;

            // update the cache statistics
            ++fac->cs.w_queries;

            //update linked list order (move node containing way that was just accessed to the head of the list)
            struct node* node = fac->mru->next;
            while(node != NULL)
            {
                //printf("%p\n", node);

                // node that was just accessed will have node->way=i
                if (node->way == i)
                {
                    // if node is the tail, its next field is NULL, so don't set the next's previous
                    if (node->next != NULL)
                        node->next->previous = node->previous;

                    node->previous->next = node->next;
                    fac->mru->previous=node;
                    node->next =fac->mru;
                    node->previous=NULL;

                    fac->mru = node;
                    break;
                }
                node=node->next;
            }

            found = 1;

            break;
        }
    }

    /* otherwise, if the memory address being rewritten isn't in the cache (WRITE MISS), then we read the
    whole memory block from main memory and write the data to the appropriate word within the block */
    if (found != 1)
    {
        // check if there's any empty space in the cache for us to put this block in
        int unused_way = FULLY_ASSOCIATIVE_NUM_WAYS;
        for (int i = 0; i < FULLY_ASSOCIATIVE_NUM_WAYS; i++) {
            if (fac->valid[i] == false) {
                unused_way = i;
                break;
            }
        }

        // if there is empty space in the cache, fill that space in with the read block
        if (unused_way != FULLY_ASSOCIATIVE_NUM_WAYS) {
            // load the memory block of data from main memory
            memory_block* mb_miss = mm_read(fac->mm, mb_start_addr);

            // get the address of the specific word in the block being read and write the data
            unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
            *mb_miss_addr = val;

            // store the new memory block into cache
            fac->ways[unused_way] = mb_miss;
            fac->dirty[unused_way] = true;
            fac->valid[unused_way] = true;

            // if the node is already at the top of the list (the node is fac->mru), then we don't
            // need to update the list, so we start searching with fac->mru->next
            struct node* node = fac->mru->next;
            while (node != NULL) {
                // pull the node with this way to the head of the LRU tracker list
                if (node->way == unused_way) {
                    // if node is the tail, its next field is NULL, so don't set the next's previous
                    if (node->next != NULL)
                        node->next->previous = node->previous;

                    node->previous->next = node->next;
                    fac->mru->previous=node;
                    node->next =fac->mru;
                    node->previous=NULL;

                    // set the new head of the list to this node
                    fac->mru = node;
                    break;
                }

                node = node->next;
            }
        }

        /* now start the process of evicting a block from memory for the new one to be written in
        the block to be evicted will be in the least recently used "way", so it's corresponding node in the lru linked-list
        will be at the bottom */
        else {
            struct node* node = fac->mru;
            while(node->next != NULL)
            {
                if (node->next->next==NULL)
                {
                    if (fac->valid[node->next->way]==true)
                    {
                        if (fac->dirty[node->next->way]==true)
                        {
                            mm_write(fac->mm, fac->ways[node->next->way]->start_addr, fac->ways[node->next->way]);
                        }
                    }
                    // now start process of freeing block from memory
                    if (fac->valid[node->next->way] == true)
                        mb_free(fac->ways[node->next->way]);

                    // load the memory block of data from main memory
                    memory_block* mb_miss = mm_read(fac->mm, mb_start_addr);

                    // get the address of the specific word in the block being read and write the data
                    unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
                    *mb_miss_addr = val;

                    fac->ways[node->next->way] = mb_miss;
                    fac->dirty[node->next->way] = true;        // we set the dirty bit here since the loaded memory block was modified
                    fac->valid[node->next->way] = true;

                    /* update order of linked list to place node corresponding to recently written-to cache-way at the head
                    of the list */
                    struct node* new_head = node->next;
                    new_head->next=fac->mru;
                    fac->mru->previous=new_head;
                    new_head->previous->next=NULL;
                    new_head->previous = NULL;
                    fac->mru = new_head;
                    break;
                }
                node=node->next;
            }

            // struct node* current = fac->mru;
            // while (current->next != NULL)
            // {
            //     current = current->next;
            // }
            // mm_write(fac->mm, fac->ways[current->way]->start_addr, fac->ways[current->way]);
            // // evict memory block from memory
            // mb_free(fac->ways[current->way]);
            // /* make second to last node point to NULL (so that the last node is now
            // disconnected and able to be freed from memory) */
            // current->previous->next = NULL;
            // // free last node from memory
            // free(current);
        }

        // update the cache statistics
        ++fac->cs.w_queries;
        ++fac->cs.w_misses;
    }
}


unsigned int fac_load_word(fully_associative_cache* fac, void* addr)
{
    int found = 0;
    unsigned int result;
    /* Compute the memory block's cache-line (there will be 16 distinct cache-lines, since
        we have 16 sets in our cache array (each set is for a memory block) */

    // compute the start address of the memory block addr is contained in
    size_t addr_offt = (size_t) (addr - MAIN_MEMORY_START_ADDR) % MAIN_MEMORY_BLOCK_SIZE;
    void* mb_start_addr = addr - addr_offt;

    /* if the cache has the data from the requested memory address (READ HIT), then we return the data
     * from the cache */
    for (int i = 0; i < FULLY_ASSOCIATIVE_NUM_WAYS; i++)
    {
        if (fac->valid[i] == true && mb_start_addr == fac->ways[i]->start_addr)
        {
            // get the found memory block from the correct cache set
            memory_block* mb_hit = fac->ways[i];

            // get the address of the specific word in the block being read and get the data
            unsigned int* mb_hit_addr = mb_hit->data + addr_offt;
            result = *mb_hit_addr;

            // update the cache statistics
            ++fac->cs.r_queries;

            //update linked list order (move node containing way that was just accessed to the head of the list)
            struct node* node = fac->mru->next;
            while(node != NULL)
            {
                //printf("%d\n", node->way);

                // node that was just accessed will have node->way=i
                if (node->way == i)
                {
                    // if node is the tail, its next field is NULL, so don't set the next's previous
                    if (node->next != NULL)
                        node->next->previous = node->previous;

                    node->previous->next = node->next;
                    fac->mru->previous=node;
                    node->next =fac->mru;
                    node->previous=NULL;

                    fac->mru = node;
                    break;
                }
                node=node->next;
            }
            found = 1;
            break;
        }
    }

    /* Otherwise, if the block of memory requested isn't in cache (READ MISS), then read it from main memory, and start the
    eviction process */

    if (found != 1)
    {
        // update the cache statistics
        ++fac->cs.r_queries;
        ++fac->cs.r_misses;

        // check if there's any empty space in the cache for us to put this block in
        int unused_way = FULLY_ASSOCIATIVE_NUM_WAYS;
        for (int i = 0; i < FULLY_ASSOCIATIVE_NUM_WAYS; i++) {
            if (fac->valid[i] == false) {
                unused_way = i;
                break;
            }
        }

        // if there is empty space in the cache, fill that space in with the read block
        if (unused_way != FULLY_ASSOCIATIVE_NUM_WAYS) {
            // load the memory block of data from main memory
            memory_block* mb_miss = mm_read(fac->mm, mb_start_addr);

            // get the address of the specific word in the block being read and get the data
            unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
            result = *mb_miss_addr;

            // store the new memory block into cache
            fac->ways[unused_way] = mb_miss;
            fac->dirty[unused_way] = false;
            fac->valid[unused_way] = true;

            // if the node is already at the top of the list (the node is fac->mru), then we don't
            // need to update the list, so we start searching with fac->mru->next
            struct node* node = fac->mru->next;
            while (node != NULL) {
                // pull the node with this way to the head of the LRU tracker list
                if (node->way == unused_way) {
                    // if node is the tail, its next field is NULL, so don't set the next's previous
                    if (node->next != NULL)
                        node->next->previous = node->previous;

                    node->previous->next = node->next;
                    fac->mru->previous=node;
                    node->next =fac->mru;
                    node->previous=NULL;

                    // set the new head of the list to this node
                    fac->mru = node;
                    break;
                }

                node = node->next;
            }
        }

        // otherwise, if there is no empty space in the cache, evict/replace a block
        else {

            /* replace the least recently used memory block with the block loaded from main memory
             If the replaced block has been modified, however (is "dirty"), we need to write it
             back to main memory as well to make sure the changes are stored */

            struct node* current = fac->mru;
            while (current->next != NULL)
            {
                current = current->next;
            }
            // if the lru block has been written to ("is dirty"), write it back to main memory
            //printf("%d %d\n", fac->dirty[current->way], fac->valid[current->way]);
            if ((fac->valid[current->way] & fac->dirty[current->way]) == true)
            {
                mm_write(fac->mm, fac->ways[current->way]->start_addr, fac->ways[current->way]);
            }

            //printf("Valid: %d LRU: %d\n", fac->valid[current->way], current->way);

            if (fac->valid[current->way]==true)
            {
                // evict memory block from memory
                mb_free(fac->ways[current->way]);
            }

            // load the memory block of data from main memory
            memory_block* mb_miss = mm_read(fac->mm, mb_start_addr);

            // get the address of the specific word in the block being read and get the data
            unsigned int* mb_miss_addr = mb_miss->data + addr_offt;
            result = *mb_miss_addr;

            // store the new memory block into cache
            fac->ways[current->way] = mb_miss;
            fac->dirty[current->way] = false;
            fac->valid[current->way] = true;

            // rearrange linked list to place node corresponding to cache-way most recently written-to at head
            current->next=fac->mru;
            fac->mru->previous=current;
            current->previous->next=NULL;
            current->previous=NULL;
            fac->mru = current;
        }
    }


    /* otherwise, if the memory the processor was looking for wasn't in the cache (READ MISS), then we
     * must read it from main memory and update the cache */


    return result;
}

void fac_free(fully_associative_cache* fac)
{
    struct node* node=fac->mru;
    for (int i = 0; i < FULLY_ASSOCIATIVE_NUM_WAYS-1; i++)
    {
        node=node->next;
        free(node->previous);
    }
    free(node);

    // free all the memory blocks stored in the cache
    for (int i = 0; i < FULLY_ASSOCIATIVE_NUM_WAYS; i++)
    {
        if (fac->ways[i] != NULL)
        {
            mb_free(fac->ways[i]);
        }
    }

    // free the cache struct allocation
    free(fac);
}
