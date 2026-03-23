// Assembly code to calculate y = sum_{n=1}^3 (x[n+a])^2-x[n+b]

    .data                       // data section
	.type      x, %object       // defining object x

x:                              // array x
                                // 20 64-bit elements
	.xword     1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20

    .text                       // program section
    .global    main             // main
    .arch      armv8-a+fp+simd  // processor type
    .type      main, %function  // main function

main:
    // a -> X20, b -> X21 (assumed)
    // y goes in X22

    ADR  X9, x                  // Store the base address of x[] into X9

    SUB  X10, X10, X10          // Get 0 without XZR
    ADD  X10, X10, #1           // n = 1
    ADD  X22, X20, X10          // y = a + n
    LSL  X22, X22, #3           // offset = (n+a) * 8 (8-byte elements)
    ADD  X22, X9,  X22          // y = &x[n+a] (base &x[] + offset)
    LDUR X22,[X22, #0]          // y = x[n+a] (load x[n+a])
    MUL  X22, X22, X22          // y = (x[n+a])^2
    ADD  X11, X21, X10          // t = b + n
    LSL  X11, X11, #3           // get offset
    ADD  X11, X9,  X11          // t = &x[n+b]
    LDUR X11,[X11, #0]          // t = x[n+b]
    SUB  X22, X22, X11          // y = (x[n+a])^2 - t

    ADD  X10, X10, #1           // n++ (n = 2)
    ADD  X11, X20, X10          // t0 = a + n
    LSL  X11, X11, #3           // get offset
    ADD  X11, X9,  X11          // t0 = &x[n+a]
    LDUR X11,[X11, #0]          // t0 = x[n+a]
    MUL  X11, X11, X11          // t0 = (x[n+a])^2
    ADD  X12, X21, X10          // t1 = b + n
    LSL  X12, X12, #3           // 8-byte elements
    ADD  X12, X9,  X12          // t1 = &x[n+b]
    LDUR X12,[X12, #0]          // t1 = x[n+b]
    ADD  X22, X22, X11          // y += t0
    SUB  X22, X22, X12          // y -= t1

    ADD  X10, X10, #1           // n++ (n = 3)
    ADD  X11, X20, X10          // t0 = a + n
    LSL  X11, X11, #3           // get offset
    ADD  X11, X9,  X11          // t0 = &x[n+a]
    LDUR X11,[X11, #0]          // t0 = x[n+a]
    MUL  X11, X11, X11          // t0 = (x[n+a])^2
    ADD  X12, X21, X10          // t1 = b + n
    LSL  X12, X12, #3           // 8-byte elements
    ADD  X12, X9,  X12          // t1 = &x[n+b]
    LDUR X12,[X12, #0]          // t1 = x[n+b]
    ADD  X22, X22, X11          // y += t0
    SUB  X22, X22, X12          // y -= t1

    NOP                         // End of the program
