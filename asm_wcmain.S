/*
 * Assembly language main function implementation
 */

#define MAX_WORDLEN 63
#define HASHTABLE_SIZE 13249

.section .rodata
	printFormat: .string "%s"
	intFormat: .string "%d"	
	readFile: .string "r"
	fileSpecify: .string "Error: File not specified.\n"
	fileCannotOpen: .string "Error: Cannot open file.\n"	
	debug: .string "debug"
	
.section .bss
	hashTable:
    		.skip HASHTABLE_SIZE*8  # reserve space for HASHTABLE_SIZE pointers
	word:
		.space MAX_WORDLEN + 1 # allocate space for word string=

	.section .text

	.globl main
main:
	pushq %rbp
	movq %rsp, %rbp

	pushq %r12
        pushq %r13
	pushq %r14

	movq %rdi, %r12 # for argc
	movq 8(%rsi), %r13 # for input file argv[1]

	cmpl $2, %r12d
	jl .std_input
	ja .file_not_specified
	
	movq %r13, %rdi
	movq $readFile, %rsi

	call fopen
	
	cmpl $0, %eax
	je .file_cannot_open
	
	movq %rax, %r14 #r14 for the file indicator

.init_hashtable:
	xorq %r12, %r12         #r12 is not used, make it the total word
	movl $HASHTABLE_SIZE, %ecx  # set loop counter
	leal hashTable, %edi         # load address of hashTable into EDI

.zero_loop:
	cmpl $0, %ecx 		#if the counter is 0
	jle .read_word_loop
	movl $0, (%edi)              # set current element to 0 (NULL)
	addl $8, %edi                # move to next element
	decl %ecx
	jmp .zero_loop               # repeat until ECX is 0
	
.read_word_loop:
	movq %r13, %rdi  	#copy the input file indicator
	leaq word, %rsi		#copy the word string pointer
	call wc_readnext
	
	cmpl $0, %eax  		#read done, start calculate statistics
	je .compute_statistics

	incq %r12 		#increase the total word counter
	
	leaq word, %rdi
	call wc_tolower

	leaq word, %rdi
	call wc_trim_non_alpha
	
	jmp .read_word_loop

.compute_statistics:
	movq $debug, %rdi
	call printf
	jmp .ending	

.std_input:
	movq $0, %r14
	jmp .init_hashtable

.file_not_specified:
	movq $fileSpecify, %rdi
        call perror
	movq $1, %rax #error code 1
	jmp .ending

.file_cannot_open:
	movq $fileCannotOpen, %rdi
        call perror
        movq $2, %rax #error code 1
        jmp .ending

.ending:
        popq %r14
        popq %r13
        popq %r12
        popq %rbp
        ret
/*
vim:ft=gas:
*/
