// Basic non-leaf function call with stack management
    .data                       // data section
    .globl  a
    .globl  b
    .globl  c
    .type   a, %object          // i64 a
    .type   b, %object          // i64 b
    .type   c, %object          // i64 c
    .size   a, 8
    .size   b, 8
    .size   c, 8

a:  .xword  5                   // a = 5
b:  .xword  4                   // b = 4
c:  .xword  0                   // c = 0

    .text                       // program section
    .globl    main              // name the main function
    .arch    armv8-a+fp+simd    // processor type
    .type    g, %function
    .type    h, %function
    .type    f, %function
    .type    main, %function    // main function

g:                              // g(x)--Leaf
    // return x + 3
    ADD  X0,  X0,  #3           // Add 3 to the arg and place it in the return register
    BR   X30                    // Return to the caller

h:                              // h(y)--Leaf
    // return y * 2
    LSL  X0,  X0,  #1           // Multiply the arg by 2 and place it in the return register
    BR   X30                    // Return to the caller

f:                              // f(aa,bb)--Non-leaf
    SUB  SP,  SP,  #16          // Dig the stack for two registers
    STUR X30,[SP,  #8]          // Store the return address on the stack
    STUR X9, [SP,  #0]          // Store anything that may be in the temp register X9

    // t = g(aa)
    BL   g                      // Arg 1 (aa) is already in X0, so just call g(aa)
    ADD  X9,  XZR, X0           // Store the result of g(aa) in temp t (X9)

    ADD  X0,  XZR, X1           // Place arg 2 (bb) in X0 to pass into h(bb)
    BL   h                      // Call h(bb)
    ADD  X0,  X9,  X0           // Add the result of h(bb) to t and place the result into X0 to return

    LDUR X9, [SP,  #0]          // Restore X9
    LDUR X30,[SP,  #8]          // Restore the caller's return address
    ADD  SP,  SP,  #16          // Restore the stack pointer

    BR   X30                    // return t + h(bb) to the caller

main:
    // main is a non-leaf, so store the return address
    SUB  SP,  SP,  #16          // Dig the stack. We only need one space, but we round up to align by 16
    STUR X30,[SP,  #0]          // Store the return address on the stack

    // c = f(a,b)
    ADR  X9,  a                 // Load &a into temp register
    LDUR X0, [X9,  #0]          // Load a into arg 1

    ADR  X9,  b                 // Load &b into temp register
    LDUR X1, [X9,  #0]          // Load b into arg 2

    ADR  X9,  c                 // Load &c into temp register
    BL   f                      // Call f(a,b)
    STUR X0, [X9,  #0]          // Store the result in c

    // return 0
    SUB  X0,  X0,  X0           // Set X0 = 0

    LDUR X30,[SP,  #0]          // Restore the return address
    ADD  SP,  SP,  #16          // Restore the stack pointer
    RET                         // Return from main (exit)







