// Assembly code for the following C snippet:

//      x[a] = x[b] + (c | 2);
//      a = b - c;
//      x[4*c] = x[b/2] + (a >> 2) - 3;

    .data                       // data section
    .type      x, %object       // defining object x
    .global    x
x:                              // array x
                                // 20 64-bit elements
    .xword     1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20

    .text                       // program section
    .global    main             // main
    .arch      armv8-a+fp+simd  // processor type
    .type      main, %function  // main function

main:
    // a -> X20, b -> X21, c -> X22 (assumed)

    ADR  X9, x                  // Store the base address of x[] into X9

    // x[a] = x[b] + (c | 2);
    LSL  X10, X21, #3           // t0 = x[b] offset = b * 8 bytes
    ADD  X10, X9,  X10          // t0 = &x[b] = x[] base + x[b] offset
    LDUR X10,[X10, #0]          // t0 = x[b] (Load x[b])
    ORR  X11, X22, #2           // t1 = c | 2
    ADD  X10, X10, X11          // t0 = t0 + t1 = x[b] + (c | 2)
    LSL  X11, X20, #3           // t1 = x[a] offset = a * 8 bytes
    ADD  X11, X9,  X11          // t1 = &x[a]
    STUR X10,[X11, #0]          // Store the result in x[a]

    // a = b - c;
    SUB  X20, X21, X22          // a = b - c

    // x[4*c] = x[b/2] + (a >> 2) - 3;
    LSR  X10, X21, #1           // t0 = b/2
    LSL  X10, X10, #3           // t0 = x[b/2] offset = (b/2) * 8 = t0 * 8
    ADD  X10, X9,  X10          // t0 = &x[b/2]
    LDUR X10,[X10, #0]          // t0 = x[b/2]
    ASR  X11, X20, #2           // t1 = a >> 2; a could be negative now
    ADD  X10, X10, X11          // t0 = t0 + t1 = x[b/2] + (a >> 2)
    SUB  X10, X10, #3           // t0 = t0 - 3 = x[b/2] + (a >> 2) - 3
    LSL  X11, X22, #5           // t1 = x[4*c] offset = c * 4 * 8 = c << 5
    ADD  X11, X9,  X11          // t1 = &x[4*c]
    STUR X10,[X11, #0]          // Store the result in x[4*c]

    NOP                         // End of the program
