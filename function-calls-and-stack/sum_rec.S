// ARMv8 assembly program to recursively sum a quadratic power series
.text
    .globl  main                // Main function
    .arch   armv8-a+fp+simd     // ARMv8 processor

    .type   sum_rec, %function
    .type   main, %function

// Main function
main:
    MOV  X27, SP                // Copy stack pointer to X27

    // *** DELETE ***
    MOV  X20, #2
    // *** DELETE ***

    MOV  X1,  X20               // a -> X1
    BL   sum_rec                // Call sum_rec(a)
    MOV  X21, X0                // sum -> X21
    B    exit                   // Exit main

// Recursively compute the sum of a quadratic power series
// i64 sum_rec(i64 n) {
//         if (n == 0) return 0;
//         return n*n - 1 + sum_rec(n-1);
// }
sum_rec:
    SUB  X27, X27, #16          // Dig the stack for 2 registers
    STUR X30,[X27, #0]          // Store return address

    CBZ  X1,  unroll            // If n == 0, return

    MUL  X9,  X1,  X1           // Otherwise, n*n -> X9
    SUB  X9,  X9,  #1           // n*n - 1
    STUR X9, [X27, #8]          // Store X9

    SUB  X1,  X1,  #1           // n--
    BL   sum_rec                // Call sum_rec(n-1)
    LDUR X9, [X27, #8]          // Load X9
    ADD  X0,  X0,  X9           // Return n*n - 1 + sum_rec(n-1)

    LDUR X30,[X27, #0]          // Restore return address
    ADD  X27, X27, #16          // Restore stack pointer
    BR   X30                    // Return control to caller

unroll:
    MOV  X0,  #0                // Return 0
    LDUR X30,[X27, #0]          // Restore return address
    ADD  X27, X27, #16          // Restore stack pointer
    BR   X30                    // Return control to caller
// End sum_rec()

exit:
    NOP
