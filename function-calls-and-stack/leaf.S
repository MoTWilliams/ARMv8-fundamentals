// Basic leaf function call
	.data						// data section
	.globl	a
	.globl	b
	.globl	c
	.type	a, %object			// i64 a
	.type	b, %object			// i64 b
	.type	c, %object			// i64 c
	.size	a, 8
	.size	b, 8
	.size	c, 8

a:	.xword	5					// a = 5
b:	.xword	4					// b = 4
c:	.xword	0					// c = 0

	.text						// program section
	.globl	main				// name the main function
	.arch	armv8-a+fp+simd		// processor type
	.type	add, %function		// add function
	.type	main, %function		// main function

add:
	SUB  SP,  SP,  #16			// Dig the stack for one register (8 bytes; SP = X28)
	STUR X9, [SP,  #0]			// Store whatever might be in X9

	ADD  X9,  X0,  X1			// t0 = a + b
	ADD  X0,  x9,  XZR			// Put the value of t0 in the return register X0

	LDUR X9, [SP,  #0]			// Restore X9
	ADD  SP,  SP,  #16			// Restore stack pointer

	BR   X30					// Return to caller

main:
	ADR  X19, c					// Load &c into X19
	ADR  X20, a					// Load &a into X20
	ADR  X21, b					// Load &b into X21

	LDUR X0, [X20, #0]			// Load a into arg 1 (X0)
	LDUR X1, [X21, #0]			// Load b into arg 2 (X1)

	BL   add					// Call add(a,b)
	STUR X0, [X19, #0]			// Store the result in c

	B    Exit

Exit:
	NOP
