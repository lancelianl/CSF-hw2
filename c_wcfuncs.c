// Important: do not add any additional #include directives!
// The only C library functions that may be used are
//
// - fgetc
// - malloc
// - free

#include <stdlib.h>
#include "wcfuncs.h"

// Compute a hash code for the given NUL-terminated
// character string.
//
// The hash algorithm should be implemented as follows:
//
// uint32_t hash_code = 5381
// for each character c of w in order {
//   hash_code = hash_code * 33 + c
// }
//
// Note that the character values should be treated as
// being unsigned (in the range 0..255)
uint32_t wc_hash(const unsigned char *w) {
  uint32_t hash_code = 5381;
  for (; *w; w++) {
    hash_code = hash_code * 33 + (uint32_t)*w; 
  }
  return hash_code;
}

// Compare two strings lexicographically. Return
//
// - a negative value if lhs string is less than rhs string
// - 0 if lhs string is identical to rhs string
// - a positive value if lhs string is greater than rhs string
//
// Lexicographical comparison is a generalization of alphabetical
// order, but using character codes. If one string is a prefix
// of the other, it is considered as "less than". E.g.,
// "hi" would compare as less than "high".
int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs) {
  while (*lhs && (*lhs == *rhs)) {
        lhs++;
        rhs++;
    }
    return *(const unsigned char *)lhs - *(const unsigned char *)rhs;
}

// Copy NUL-terminated source string to the destination buffer.
void wc_str_copy(unsigned char *dest, const unsigned char *source) {
  // TODO: implement
  while (*source) {
        *dest = *source;
        dest++;
        source++;
    }
    *dest = '\0'; 
}

// Return 1 if the character code in c is a whitespace character,
// false otherwise.
//
// For the purposes of this function, a whitespace character is one of
//
//   ' '
//   '\t'
//   '\r'
//   '\n'
//   '\f'
//   '\v'
int wc_isspace(unsigned char c) {
  // TODO: implement
  switch (c) {
        case ' ':
        case '\t':
        case '\r':
        case '\n':
        case '\f':
        case '\v':
            return 1;
        default:
            return 0;
    }
}

// Return 1 if the character code in c is an alphabetic character
// ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
int wc_isalpha(unsigned char c) {
  // TODO: implement
  return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');
}

// Read the next word from given input stream, storing
// the word in the array pointed-to by w. (This array should be
// assumed to be MAX_WORDLEN+1 elements in size.) Return 1
// if a word is read successfully, 0 otherwise.
//
// For the purposes of this function, a word is a sequence of
// 1 or more non-whitespace characters.
//
// If a sequence of non-whitespace characters has more than
// MAX_WORDLEN characters, then only the first MAX_WORDLEN
// characters in the sequence should be stored in the array.
int wc_readnext(FILE *in, unsigned char *w) {
  // TODO: implement
    unsigned char *word = w;
    int c;

    do {
        c = fgetc(in);
        if (c == EOF) {
            return 0;  
        }
    } while (wc_isspace(c));

    // Read the word
    while (!wc_isspace((unsigned char)c) && word - w <= MAX_WORDLEN) {
        *word++ = (unsigned char)c;
        c = fgetc(in);
        if (c == EOF) {
          *word = '\0';
          return 1;
          break;  // End of file
        }
    }
    *word = '\0';  
    while (!wc_isspace((unsigned char)c) && c != EOF) c = fgetc(in);
    return 1;
}

// Convert the NUL-terminated character string in the array
// pointed-to by w so that every letter is lower-case.
void wc_tolower(unsigned char *w) {
  // TODO: implement
  while (*w != '\0') {
    *w = (*w >= 'A' && *w <= 'Z') ? (*w - 'A' + 'a') : *w;
    w++;
  }

}

// Remove any non-alphaabetic characters from the end of the
// NUL-terminated character string pointed-to by w.
void wc_trim_non_alpha(unsigned char *w) {
  // TODO: implement
  int len = 0;
  while (w[len] != '\0') len++;
  while (!wc_isalpha(w[len-1]) && len > 0) len--; 
  // if (w == word && wc_isalpha(*word))
  w[len] = '\0';
}

// Search the specified linked list of WordEntry objects for an object
// containing the specified string.
//
// If a matching object is found, set the int variable pointed-to by
// inserted to 0 and return a pointer to the matching object.
//
// If a matching object is not found, allocate a new WordEntry object,
// set its next pointer to point to what head points to (i.e., so the
// new object is at the head of the list), set the variable pointed-to
// by inserted to 1, and return a pointer to the new node. Note that
// the new node should have its count value set to 0. (It is the caller's
// job to update the count.)
struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted) {
  // TODO: implement
  // if(head) printf("append");
  struct WordEntry *curr = head;
  while (curr){
    unsigned char *curr_str = (unsigned char *)curr->word;
    if (wc_str_compare(curr_str, s) == 0) {
            *inserted = 0;
            return curr;
      }
    curr = curr->next;
  } 
  struct WordEntry *newEntry = (struct WordEntry *)malloc(sizeof(struct WordEntry));
  wc_str_copy((unsigned char *)newEntry->word, s);
  newEntry->count = 0;
  newEntry->next = head;
  *inserted = 1;
  return newEntry;
}

// Find or insert the WordEntry object for the given string (s), returning
// a pointer to it. The head of the linked list which contains (or should
// contain) the entry for s is the element of buckets whose index is the
// hash code of s mod num_buckets.
//
// Returns a pointer to the WordEntry object in the appropriate linked list
// which represents s.
struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s) {
  // TODO: implement
  int inserted = -1;
  uint32_t hashIndex = wc_hash(s) % num_buckets;
  struct WordEntry *newEntry = wc_find_or_insert(buckets[hashIndex], s, &inserted);
  if (inserted) {
    buckets[hashIndex] = newEntry;
  }
  return newEntry;
}

// Free all of the nodes in given linked list of WordEntry objects.
void wc_free_chain(struct WordEntry *p) {
  // TODO: implement
  struct WordEntry *curr = p;
  struct WordEntry *next;
  while (curr) {
    next = curr->next;
    free(curr);
    curr = next;
  }
}
