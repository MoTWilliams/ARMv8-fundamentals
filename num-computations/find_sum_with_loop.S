// ARMv8 assembly program to sum an exponential series with a single loop
.text
    .globl  main                // Main function
    .arch   armv8-a+fp+simd     // ARMv8 processor

    .type   find_sum, %function
    .type   main, %function

// Main function
main:
    MOV  X27, SP                // Copy stack pointer to X27

    MOV  X1,  X20               // a -> X1
    MOV  X2,  X21               // b -> X2
    BL   find_sum               // Call find_sum(a,b)
    MOV  X22, X0                // sum -> X22
    B    exit                   // Exit main

// Compute the sum from n=1 to a of (a^n - b)
// i64 find_sum(i64 a, i64 b) {
//         i64 a_pow_n = 1, sum = 0;
//         for (int n = 1; n <= a; n++) {
//                 a_pow_n *= a;
//                 i64 term = a_pow_n - b;
//                 sum += term;
//         }
//         return sum;
// }
find_sum:
    SUB  X27, X27, #32          // Dig the stack for 4 registers
    STUR X9, [X27, #0]          // Preserve X9
    STUR X10,[X27, #8]          // Preserve X10
    STUR X19,[X27, #16]         // Preserve X19
    STUR X20,[X27, #24]         // Preserve X20

    // Initialization
    MOV  X19, #1                // a_pow_n = 1 -> X19
    MOV  X20, #0                // sum = 0 -> X20

    MOV  X9,  #1                // n = 1 -> X9

Loop:
    CMP  X9,  X1                // Compare n and a
    B.GT ExitLp                 // If n > a, exit the loop

    MUL  X19, X19, X1           // a_pow_n *= a
    SUB  X10, X19, X2           // term (temp) = a_pow_n - b -> X10
    ADD  X20, X20, X10          // sum += term

    ADD  X9,  X9,  #1           // n++
    B    Loop                   // Loop again

ExitLp:
    MOV  X0,  X20               // Return sum

    LDUR X9, [X27, #0]          // Restore X9
    LDUR X10,[X27, #8]          // Restore X10
    LDUR X19,[X27, #16]         // Restore X19
    LDUR X20,[X27, #24]         // Restore X20
    ADD  X27, X27, #32          // Restore the stack pointer

    BR   X30                    // Return control to the caller
// End find_sum()

exit:
    NOP
