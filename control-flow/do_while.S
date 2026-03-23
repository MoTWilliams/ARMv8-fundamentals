// Do-while loop with array access and float comparison

.data
    .globl  d
    .type   d, %object
    .size   d, 20
d:  .double 134.72, 0.913, 482.5, 76.048, 249.3, 3.81, 417.092, 55.6, 299.044
    .double 12.5, 461.007, 187.94, 24.318, 330.2, 7.04, 498.991, 462.71, 91.056
    .double 0.624, 266.5

    .type   c, %object
c:  .double 0.1

.text
    .globl  main
    .arch   armv8-a+fp+simd
    .type   main, %function

main:
    ADR   X19, d                // &d[0] -> X19
// *** REMOVE AFTER TESTING ***
    // a = 3 ; b = 4 ; c = 248.1
    MOV   X20, #3               // a = 3 -> X20
    MOV   X21, #4               // b = 4 -> X21

    ADR   X9,  c                // &c -> X9
    LDUR  D22,[X9, #0]          // c = 248.1 -> D22
// *** END TEST CODE ***
    MOV   X9,  X21              // initialize loop counter i = b -> X9

loop:                           // Do-while loop
    SUB   X9,  X9,  #1          // i--

    ASR   X10, X21, #1          // b/2 -> X10
    LSL   X10, X10, #3          // b/2 * 8 bytes (double)
    ADD   X10, X19, X10         // &d[b/2]
    LDUR  D9, [X10, #0]         // d[b/2] -> D9
    FSUB  D9,  D9,  D22         // d[b/2] - c

    SUB   X10, X20, #1          // a-1 -> X10
    LSL   X10, X10, #3          // (a-1) * 8 bytes
    ADD   X10, X19, X10         // &d[a-1]

    STUR  D9, [X10, #0]         // d[a-1] = d[b/2] - c

    LSL   X10, X9,  #3          // i * 8 bytes -> X10
    ADD   X10, X19, X10         // &d[i]
    LDUR  D9, [X10, #0]         // d[i] -> D9
    FCMP  D22, D9               // Compare c and d[i]
    B.LT  exit_loop             // If c < d[i], exit the loop
    B     loop                  // Otherwise, loop again

exit_loop:
    NOP
