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

  // TODO: implement

//   while ( next word is read successfully using wc_readnext ) {
//   increase total word count by 1

//   use wc_tolower to convert word to lower case

//   use wc_trim_non_alpha to remove non-alphabetic characters at end of word

//   use wc_dict_find_or_insert to find or insert the word in the hash table

//   increment the WordEntry's count
// }

  FILE *file = fopen(argv[1], "r");
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
