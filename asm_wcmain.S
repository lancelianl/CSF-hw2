/*
 * Assembly language main function implementation
 */

#define MAX_WORDLEN 63
#define HASHTABLE_SIZE 13249

#define WORDENTRY_WORD_OFFSET   (0)
#define WORDENTRY_COUNT_OFFSET  (MAX_WORDLEN+1)
#define WORDENTRY_NEXT_OFFSET   (MAX_WORDLEN+1+4+4)

.section .rodata
	printWords: .string "Total words read: %u\n"
	printUniqueWords: .string "Unique words read: %u\n"
	printBestWord: .string "Most frequent word: %s (%u)\n"
	printString: .string "%s"
	intFormat: .string "%d"	
	readFile: .string "r"
	fileSpecify: .string "Error: file not specified.\n"
	fileCannotOpen: .string "Error: Cannot open file.\n"	
	debug: .string "debug"
	
.section .bss
	hashTable:
    		.skip HASHTABLE_SIZE*8  # reserve space for HASHTABLE_SIZE pointers
	word:
		.space 8 # allocate space for word string=

	.section .text

	.globl main
main:
	pushq %rbp
	movq %rsp, %rbp

	pushq %r12
    pushq %r13
	pushq %r14
	pushq %r15

	movq %rdi, %r12 # for argc
	movq 8(%rsi), %r13 # for input file argv[1]

	cmpl $2, %r12d
	jl .std_input
	
	movq %r13, %rdi
	movq $readFile, %rsi

	call fopen
	
	cmpl $0, %eax
	je .file_cannot_open

	movq %rax, %r14 #r14 for the file indicator

.init_hashtable:
	xorq %r12, %r12         #r12 is not used, make it the total word
	movl $HASHTABLE_SIZE, %ecx  # set loop counter
	leaq hashTable, %rdi         # load address of hashTable into %rdi

.zero_loop:
	cmpl $0, %ecx 		#if the counter is 0
	jle .read_word_loop
	movl $0, (%edi)              # set current element to 0 (NULL)
	addl $8, %edi                # move to next element
	decl %ecx
	jmp .zero_loop               # repeat until ECX is 0
	
.read_word_loop:
	movq %r14, %rdi  	#copy the input file indicator
	leaq word, %rsi		#copy the word string pointer
	
	call wc_readnext
	
	cmpl $0, %eax  		#read done, start calculate statistics
	je .compute_prep

	incq %r12 	# %r12 stores the total_words counter
	
	leaq word, %rdi
	call wc_tolower

	leaq word, %rdi
	call wc_trim_non_alpha
 	
	# load argumnents to perfornm wc_dict_find_or_insert(hashTable, HASHTABLE_SIZE, word)
	leaq hashTable, %rdi
	movq $HASHTABLE_SIZE, %rsi
	leaq word, %rdx
	call wc_dict_find_or_insert
	incq WORDENTRY_COUNT_OFFSET(%rax) # count++

	jmp .read_word_loop

.compute_prep:
	# close the file
	movq %r14, %rdi 
	call fclose

	movq $0, %r13 # %r13 stores unique_words counter
	movq $0, %r14 # %r14 stores the best_word_count counter

	movq $0, %r10 # %r10 as the index
	leaq hashTable, %rcx # %rcx as the address of the start of hashTable

.compute_statistics:
	cmpq $HASHTABLE_SIZE, %r10 # check if we reach the end of the hashTable
	je .printResult
	movq (%rcx, %r10, 8), %r11 # load current element to %r11
	incq %r10 # move to the next element
	cmpq $0, %r11 # if the currect element is null, move to the next 
	je .compute_statistics

	incq %r13 # unique_words++
	cmpq %r14, WORDENTRY_COUNT_OFFSET(%r11) # compare current word count and best_word_count
	ja .update_best_word
	jmp .iterate_chain

.iterate_chain:
	movq WORDENTRY_NEXT_OFFSET(%r11), %r11 # move to the next entry in chain
	cmpq $0, %r11 # check if we reach the end of the chain
	je .compute_statistics
	incq %r13 # unique_words++
	cmpq %r14, WORDENTRY_COUNT_OFFSET(%r11) # compare current word count and best_word_count
	ja .update_best_word
	jmp .iterate_chain

.update_best_word:
	movq WORDENTRY_COUNT_OFFSET(%r11), %r14 # update the best_word_count counter
	leaq WORDENTRY_WORD_OFFSET(%r11), %r15 # %r15 stores the best_word
	jmp .iterate_chain

.printResult:
	movq $printWords, %rdi
	movq %r12, %rsi
	call printf
	movq $printUniqueWords, %rdi
	movq %r13, %rsi
	call printf
	movq $printBestWord, %rdi
	movq %r15, %rsi
	movq %r14, %rdx
	call printf

.free_hashtable:
	leaq hashTable, %r13 # %r13 as the address of the start of hashTable
        xorq %r12, %r12

.free_loop:
	cmpq $HASHTABLE_SIZE, %r12
	je .ending

	movq (%r13, %r12, 8), %rdi
	incq %r12
        cmpq $0, %rdi
	je .free_loop
	call wc_free_chain
	jmp .free_loop

.std_input:
    movq stdin(%rip), %rax
    movq %rax, %r14
        jmp .init_hashtable

.file_cannot_open:
	movq stderr(%rip), %rdi
        movq $fileCannotOpen, %rsi
        call fprintf
        movq $1, %rax #error code 1
        popq %r15
        popq %r14
        popq %r13
        popq %r12
        popq %rbp
	ret

.ending:
	xorq %rax, %rax
	popq %r15
        popq %r14
        popq %r13
        popq %r12
        popq %rbp
        ret
/*
vim:ft=gas:
*/
