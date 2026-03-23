// While loop with short-circuit OR condition
.data
    .globl  d
    .type   d, %object

d:
    .xword   4, 1, 7, 9, 12, 20, 25, 30, 0

.text
    .globl  main
    .arch   armv8-a+fp+simd
    .type   main, %function

main:
    ADR  X19, d                 // &d[0] -> X19
    MOV  X20, #1                // a = 1 -> X20
    MOV  X21, #6                // b = 6 -> X21
    MOV  X22, #2                // c = 2 -> X22

    // Initialize loop pointer -> X9
    MOV  X9,  X19               // i64 *p = &d[0]

    // &d[a] -> X23
    LSL  X23, X20, #3           // a * 8 bytes
    ADD  X23, X19, X23          // Calculate &d[a]

    // &d[b] -> X24
    LSL  X24, X21, #3           // b * 8 bytes
    ADD  X24, X19, X24          // Calculate &d[b]
Loop:
    // Check first condition
    CMP  X21, #0                // Compare b and 0
    B.GT LoopBody               // If b > 0, jump to loop body

    // If first condition fails, check second condition
    LDUR X10,[X9,  #0]          // Load *p -> X10
    CMP  X10, X20               // Compare *p and a
    B.GE ExitLoop               // If *p >= a, exit the loop
    // Otherwise, enter the loop body
LoopBody:
    LDUR X10,[X24, #0]          // Load d[b]
    SUB  X10, X24, X22          // Compute d[b] - c
    STUR X10,[X23, #0]          // d[a] = d[b] - c

    ADD  X9,  X9,  #8           // p++ (by 8 bytes)
    B    Loop                   // Loop again
ExitLoop:
    B   exit
// End main()

exit:
    NOP
