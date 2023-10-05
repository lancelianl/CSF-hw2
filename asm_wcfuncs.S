/*
 * Assembly language function implementations
 */

#define MAX_WORDLEN 63

/*
 * Offsets for the fields of the struct WordEntry data type
 * (Note that there is 4 bytes of padding between the count and next
 * fields.)
 */
#define WORDENTRY_WORD_OFFSET   (0)
#define WORDENTRY_COUNT_OFFSET  (MAX_WORDLEN+1)
#define WORDENTRY_NEXT_OFFSET   (MAX_WORDLEN+1+4+4)
#defind MAX_WORDLEN (63) 
 .section .rodata
/* Define any string constants or read-only data here */
/*
printFormat: .string "%u"
badFile: .string "bad input file indicator"
inputString: .string "%c"
*/
.section .bss
buffer:
    .space 1  # Allocate space for a single character

 .section .text

/*
 * Compute a hash code for the given NUL-terminated
 * character string.
 *
 * The hash algorithm should be implemented as follows:
 *
 * uint32_t hash_code = 5381
 * for each character c of w in order {
 *   hash_code = hash_code * 33 + c
 * }
 *
 * Note that the character values should be treated as
 * being unsigned (in the range 0..255)
 *
 * C function prototype:
 *    uint32_t wc_hash(const unsigned char *w);
 */
 .globl wc_hash
wc_hash:
pushq %rbp
movq %rsp, %rbp

movl $5381, %eax //set hashcode to 5381
movq %rdi, %rcx //pointer for the string
movl $33, %r10d //store the constant 33 for future use

.hashcode_loop:
movzbl (%rcx), %r11d // get the char into %r11d
cmpb $0, %r11b // check for the null terminator
je .done_hashcode_loop

mull %r10d //calculate the new hashcode and store in eax
addl %r11d, %eax

incq %rcx
jmp .hashcode_loop

.done_hashcode_loop:
popq %rbp
ret

/*
 * Compare two strings lexicographically. Return
 *
 * - a negative value if lhs string is less than rhs string
 * - 0 if lhs string is identical to rhs string
 * - a positive value if lhs string is greater than rhs string
 *
 * Lexicographical comparison is a generalization of alphabetical
 * order, but using character codes. If one string is a prefix
 * of the other, it is considered as "less than". E.g.,
 * "hi" would compare as less than "high".
 *
 * C function prototype:
 *    int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs);
 */
 .globl wc_str_compare
wc_str_compare:
 /* %rdi represents *lhs, %rsi represents *rhs */
.compareLoop:
 movzbl (%rdi), %edx /* copy data in %rdi to %edx */
 movzbl (%rsi), %ecx /* copy data in %rdi to %ecx */
 cmpl %ecx, %edx /* compare char one by one */
 jl .lhsLess /* jump if %edx < %ecx */
 jg .lhsGreater /* jump if %edx > %exc */
 /* if we reach here, the strings are identical so far */
 cmpl $0x00, %edx /* if both chars are equal to the null terminator, the strings are identical */
 je .equal
 incq %rdi /* go to the next char */
 incq %rsi
 jmp .compareLoop /* restart the loop */

.lhsLess:
 movl $-1, %eax /* return a negative value */
 ret

.lhsGreater:
 movl $1, %eax /* return a positive value */
 ret

.equal:
 movl $0, %eax /* return 0 */
 ret

/*
 * Copy NULterminated source string to the destination buffer.
 *
 * C function prototype:
 *    void wc_str_copy(unsigned char *dest, const unsigned char *source);
 */
 .globl wc_str_copy
wc_str_copy:
push %rbp
movq %rsp, %rbp

movq %rdi, %rax // rax for the destintaion
movq %rsi, %rcx // rcs for the source

.copy_loop:
movzbl (%rcx), %edx // use dl as a temp variable to copy value, since we cannot operate two address.  
movb %dl, (%rax)

cmpb $0, %dl // check for the null terminator
je .done_copy

incq %rax
incq %rcx // increment the address for source and destination
jmp .copy_loop
 
.done_copy:
pop %rbp
ret


/*
 * Return 1 if the character code in c is a whitespace character,
 * false otherwise.
 *
 * For the purposes of this function, a whitespace character is one of
 * 
 *   ' '
 *   '\t'
 *   '\r'
 *   '\n'
 *   '\f'
 *   '\v'
 *
 * C function prototype:
 *    int wc_isspace(unsigned char c);
 */

 .globl wc_isspace
wc_isspace:
 /* check if %dil (last 8 bits of %rdi) is space */
 cmpb $0x20, %dil /* check if ' ' */
 je .isspace

 cmpb $0x09, %dil /* check if '\t' */
 je .isspace

 cmpb $0x0d, %dil /* check if '\r' */
 je .isspace

 cmpb $0x0a, %dil /* check if '\n' */
 je .isspace

 cmpb $0x0c, %dil /* check if '\f' */
 je .isspace

 cmpb $0x0b, %dil /* check if '\v' */
 je .isspace

 /* if not space, return 0 */
 movl $0, %eax
 ret

.isspace:
 movl $1, %eax
 ret

/*
 * Return 1 if the character code in c is an alphabetic character
 * ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
 *
 * C function prototype:
 *    int wc_isalpha(unsigned char c);
 */
 .globl wc_isalpha
wc_isalpha:
 /* check if between 'A' and 'Z' */
 cmpb $0x41, %dil /* check if c is less than 'A' */
 jl .notAtoZ

 cmpb $0x5A, %dil /* check if c is greater than 'Z' */
 jg .notAtoZ

 /* if we reach here, c is between 'A' and 'Z' */
 movl $1, %eax
 ret

.notAtoZ:
 /* check if between 'a' and 'z' */
 cmpb $0x61, %dil /* check if c is less than 'a' */
 jl .notAlpha

 cmpb $0x7A, %dil /* check if c is greater than 'z' */
 jg .notAlpha

 /* if we reach here, c is between 'a' and 'z' */
 movl $1, %eax
//addq $8, %rsp
 ret

.notAlpha:
 movl $0, %eax
//addq $8, %rsp
 ret

/*
 * Read the next word from given input stream, storing
 * the word in the array pointed-to by w. (This array should be
 * assumed to be MAX_WORDLEN+1 elements in size.) Return 1
 * if a word is read successfully, 0 otherwise.
 *
 * For the purposes of this function, a word is a sequence of
 * 1 or more non-whitespace characters.
 *
 * If a sequence of non-whitespace characters has more than
 * MAX_WORDLEN characters, then only the first MAX_WORDLEN
 * characters in the sequence should be stored in the array.
 *
 * C function prototype:
 *    int wc_readnext(FILE *in, unsigned char *w);
 */
 .globl wc_readnext
wc_readnext:
pushq %rbp
movq %rsp, %rbp
pushq %r12
pushq %r13
pushq %r14
pushq %r15 

	movq %rdi, %r12 #save the file pointer in r12
    movq %rsi, %r13 #save the word pointer in r13
    xorq %r14, %r14

.read_forward_space_loop:
    # Set up arguments for fscanf
    	movq %r12, %rdi 
        call fgetc

	movsxd %eax, %rax

    # Check the result of fscanf
    	cmpq $-1, %rax  # Check if fscanf read one item
    	je .error_read     # If not, jump to error handling
	movq %rax, %r15  #for the buffer	

 # Check if character is whitespace
    	movzbl %r15b, %edi       # Load the read byte into %edi
    	call wc_isspace      
    	cmpl $1, %eax
    	je .read_forward_space_loop

.read_char_loop:

	movb %r15b, (%r13, %r14)   # Store the byte in buffer
	incq %r14

	cmpl $MAX_WORDLEN, %r14d
	jae .overflow_loop

	movq %r12, %rdi
        call fgetc
        
	movsxd %eax, %rax 
	cmpq $-1, %rax  # Check if fscanf read one item
	je .read_end

	movq %rax, %r15
	movzbl %r15b, %edi       # Load the read byte into %eax
        call wc_isspace
        cmpl $1, %eax
        je .read_end
	
	jmp .read_char_loop
	
.overflow_loop:
	movq %r12, %rdi
	call fgetc

	movsxd %eax, %rax

	cmpq $-1, %rax  # Check if fscanf read one item
        je .read_end
	movq %rax, %r15

	movzbl %r15b, %edi       # Load the read byte into %eax
        call wc_isspace
        cmpl $1, %eax
        je .read_end

	jmp .overflow_loop

.read_end:
    # Null-terminate the buffer
    movb $0, (%r13, %r14)    # Store null terminator in buffer
    movl $1, %eax
       # Epilogue
popq %r15
popq %r14
	popq %r13
	popq %r12
    popq %rbp
    ret

.error_read: 
    movl $0, %eax
popq %r15
popq %r14
        popq %r13
        popq %r12
	popq %rbp
	ret
/*
 * Convert the NUL-terminated character string in the array
 * pointed-to by w so that every letter is lower-case.
 *
 * C function prototype:
 *    void wc_tolower(unsigned char *w);
 */
 .globl wc_tolower
wc_tolower:
 push %rbp
movq %rsp, %rbp

movq %rdi, %r10 // use r10 for the string address

.to_lower_loop:
movzbl (%r10), %eax // put the current char in al
cmpb $0, %al //check for null terminator
je .lower_loop_done

cmpb $'A', %al //check for upper case
jl .lower_iteration_end
cmpb $'Z', %al
jg .lower_iteration_end

subb $'A', %al  //convert the upper to lower
addb $'a', %al
movb %al, (%r10)
jmp .lower_iteration_end

.lower_iteration_end:
incq %r10
jmp .to_lower_loop

.lower_loop_done:
popq %rbp
 ret

/*
 * Remove any non-alphaabetic characters from the end of the
 * NUL-terminated character string pointed-to by w.
 *
 * C function prototype:
 *    void wc_trim_non_alpha(unsigned char *w);
 */
 .globl wc_trim_non_alpha
wc_trim_non_alpha:
  push %rbp
movq %rsp, %rbp

movq %rdi, %r10 //use r10 for the moving pointer 
movq %rdi, %r11 //use r11 for the original address of string
.trim_forward_loop: //traverse to the null terminator
movzbl (%r10), %eax
cmpb $0, %al
je .trim_backward_loop

incq %r10
jmp .trim_forward_loop

.trim_backward_loop: //trace back from \0
cmpq %r11, %r10  //cannot search the address before the string (undefined behavior)
jl .backward_loop_done

movzbl (%r10), %edi //set the first argument of is_alpha
call wc_isalpha
cmpl $1, %eax // if the character is alpha
je .backward_loop_done

decq %r10
jmp .trim_backward_loop

.backward_loop_done:
incq %r10 //restore the r10 value to non-alpha
movb $0, (%r10)
popq %rbp
 ret

/*
 * Search the specified linked list of WordEntry objects for an object
 * containing the specified string.
 *
 * If a matching object is found, set the int variable pointed-to by
 * inserted to 0 and return a pointer to the matching object.
 *
 * If a matching object is not found, allocate a new WordEntry object,
 * set its next pointer to point to what head points to (i.e., so the
 * new object is at the head of the list), set the variable pointed-to
 * by inserted to 1, and return a pointer to the new node. Note that
 * the new node should have its count value set to 0. (It is the caller's
 * job to update the count.)
 *
 * C function prototype:
 *    struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted);
 */

.globl wc_find_or_insert
wc_find_or_insert:
 /* TODO: implement */
 /* %rdi: *head, %rsi: *s, %rdx: *inserted */
 subq $8, %rsp /* stack alignment */
 /* save arguments for later retrievement */
 pushq %r12
 pushq %r13
 pushq %rdx
 movq %rdi, %r12
 movq %rsi, %r13

.Lfind_or_insert_loop:
 cmpq $0, %rdi /* check if we reach the end of the linked list */
 je .Lfind_or_insert_not_found
 movq %r13, %rsi /* retrieve %rsi */
 pushq %rdi /* save %rdi */
 call wc_str_compare /* check if %rdi (current word in the linked list) and %rsi (target string) are the same */
 popq %rdi /* retreive %rdi */
 je .Lfind_or_insert_found
 movq WORDENTRY_NEXT_OFFSET(%rdi), %rdi /* move to the next WordEntry object */
 jmp .Lfind_or_insert_loop

.Lfind_or_insert_not_found:
 /* object not found */
 /* number of byte to allocate: WORDENTRY_NEXT_OFFSET + 8 */
 movq $WORDENTRY_NEXT_OFFSET, %rdi
 addq $8, %rdi
 subq $8, %rsp /* stack alignment */
 call malloc /* now %rax stores the address of the newly allocated object */
 movq %rax, %rdi /* %rax as the destination of str_copy */
 movq %r13, %rsi /* retrieve %rsi */
 call wc_str_copy /* word = *s */
 addq $8, %rsp /* stack alignment */
 movq $0, WORDENTRY_COUNT_OFFSET(%rdi) /* count = 0 */
 movq %r12, WORDENTRY_NEXT_OFFSET(%rdi) /* next = head */
 movq %rdi, %rax /* return the modified WordEntry */
 popq %rdx /* retrieve %rdx *inserted */
 movq $1, (%rdx) /* *inserted = 1 */
 popq %r13
 popq %r12
 addq $8, %rsp /* stack alignment */
 ret

.Lfind_or_insert_found:
 /* object found */
 popq %rdx /* retrieve %rdx *inserted */
 movq $0, (%rdx) /* *inserted = 0 */
 movq %rdi, %rax /* return the address of the matching object */
 popq %r13
 popq %r12
 addq $8, %rsp /* stack alignment */
 ret

/*
 * Find or insert the WordEntry object for the given string (s), returning
 * a pointer to it. The head of the linked list which contains (or should
 * contain) the entry for s is the element of buckets whose index is the
 * hash code of s mod num_buckets.
 *
 * Returns a pointer to the WordEntry object in the appropriate linked list
 * which represents s.
 *
 * C function prototype:
 *    struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s);
 */

 .globl wc_dict_find_or_insert
wc_dict_find_or_insert:
 /* TODO: implement */
 /* %rdi: *buckets[], %rsi: num_buckets, %rdx: *s */

 /* save arguments for later retrievement */
 pushq %r12
 pushq %r13
 pushq %r14
 pushq %r15
 movq %rdi, %r12
 movq %rsi, %r13
 movq %rdx, %r14
 /* allocate an address for inserted */
 movq $8, %rdi 
 subq $8, %rsp /* stack alignment */
 call malloc
 addq $8, %rsp /* stack alignment */
 movq %rax, %r15

 movq %r14, %rdi /* compute hashcode of *s */
 call wc_hash /* rax now stores dividend (hashcode) */

 xorq %rdx, %rdx /* clear %rdx, ensuring that we're working with a 64-bit dividend */
 movq %r13, %rcx /* load divider (num_buckets) into %rcx */
 idivq %rcx /* perform division, %rdx now stores the remainder */

 pushq %rdx /* save %rdx */
 movq (%r12, %rdx, 8), %rdi /* load buckets[hashIndex] to %rdi */
 movq %r14, %rsi /* load s to %rsi */
 movq %r15, %rdx /* load &inserted to rdx */
 call wc_find_or_insert /* %rax now stores newEntry */

 cmpq $1, (%rdx) /* check if inserted */
 je .Ldict_find_or_insert_inserted
 popq %rdx /* stack alignment */
 popq %r15
 popq %r14
 popq %r13
 popq %r12
 ret

.Ldict_find_or_insert_inserted:
 /* retrieve %rdx and %rdi */
 popq %rdx /* retrieve %rdx */
 movq %rax, (%r12, %rdx, 8) /* buckets[hashIndex] = newEntry */
 popq %r15
 popq %r14
 popq %r13
 popq %r12
 ret


/*
 * Free all of the nodes in given linked list of WordEntry objects.
 *
 * C function prototype:
 *    void wc_free_chain(struct WordEntry *p);
 */
 .globl wc_free_chain
wc_free_chain:
 movl $0, %eax
 pushq %r12 /* stack alignment */

.freeLoop:
 cmpq $0, %rdi /* check if we reach the end of the chain */
 je .endOfChain
 movq WORDENTRY_NEXT_OFFSET(%rdi), %r12 /* store the address of next WordEntry object in callee-saved register %r12 */
 call free /* free %rdi */
 movq %r12, %rdi /* move to the next WordEntry object */
 jmp .freeLoop

.endOfChain:
 popq %r12 /* stack alignment */
 ret

/*
vim:ft=gas:
*/
