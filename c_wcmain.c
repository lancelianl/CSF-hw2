#include <stdio.h>
#include <stdint.h>
#include "wcfuncs.h"

// Suggested number of buckets for the hash table
#define HASHTABLE_SIZE 13249


// TODO: prototypes for helper functions

int main(int argc, char **argv) {
  // stats (to be printed at end)
  uint32_t total_words = 0;
  uint32_t unique_words = 0;
  const unsigned char *best_word = (const unsigned char *) "";
  uint32_t best_word_count = 0;

  FILE *file;

  if (argc < 2) {
         file = stdin; 
    }else if (argc == 2) {
      file = fopen(argv[1], "r");
    } else {
      fprintf(stderr, "Error: File not specified.\n");
    }

    if (!file) {
        fprintf(stderr, "Error: Cannot open file '%s'.\n", argv[1]);
        return 2;  
    }

  struct WordEntry *hashTable[HASHTABLE_SIZE] = {NULL};
  unsigned char word[MAX_WORDLEN + 1];
  while (wc_readnext(file, word)) {
    total_words++;
    wc_tolower(word);
    wc_trim_non_alpha(word);
    wc_dict_find_or_insert(hashTable, HASHTABLE_SIZE, word) -> count++;
    
  }

  struct WordEntry *curr;
  for (int i = 0; i < HASHTABLE_SIZE; i++){
    if (hashTable[i]){
      curr = hashTable[i]; 
      while (curr) {
        unique_words++; 
        if (curr->count > best_word_count) {
          best_word_count = curr->count;
          best_word = curr->word;
        } else if (curr->count == best_word_count) {
          best_word = wc_str_compare(curr->word, best_word) < 0 ? curr->word : best_word;
        }
        curr = curr->next;
      }
    } 
  }
  
  printf("Total words read: %u\n", total_words);
  printf("Unique words read: %u\n",  unique_words);
  printf("Most frequent word: %s (%u)\n",  best_word, best_word_count);

  // TODO: make sure file is closed (if one was opened)
  // TODO: make sure memory is freed
  fclose(file);
  for (int i = 0; i < HASHTABLE_SIZE; i++){
    if (hashTable[i]) wc_free_chain(hashTable[i]);
  }
  return 0;
}

// TODO: definitions of helper functions
