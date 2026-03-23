// Recursively compute product from n=0 to a of (2n^2 + 1)
.text
    .globl  main
    .arch   armv8-a+fp+simd

    .type   main, %function
    .type   prod_rec, %function

main:
    MOV  X27, SP                // Move SP to X27 to avoid alignment exceptions

    MOV  X1,  #4                // 0 < a < 6 -> X1
    BL   prod_rec               // Call prod_rec(a)
    MOV  X20, X0                // result -> X20

    B    exit                   // Exit main function
// End main()

// Compute the product
prod_rec:
    SUB  X27, X27, #16          // Dig the stack for 2 registers
    STUR X30,[X27, #0]          // Preserve return address

    CBZ  X1,  unroll            // If n == 0, unroll recursion

    MUL  X19, X1,  X1           // Otherwise, n*n -> X19
    LSL  X19, X19, #1           // 2 * n*n
    ADD  X19, X19, #1           // 2n^2 + 1
    STUR X19,[X27, #8]          // Store X19

    SUB  X1,  X1,  #1           // n--
    BL   prod_rec               // Call prod_rec(n-1)
    LDUR X19,[X27, #8]          // Restore X19
    MUL  X0,  X19, X0           // Return (2n^2 + 1) * prod_rec(n-1)

    LDUR X30,[X27, #0]          // Restore return address
    ADD  X27, X27, #16          // Restore the stack
    BR   X30                    // Return control to the caller
unroll:
    MOV  X0,  #1                // Set return value to 1

    LDUR X30,[X27, #0]          // Restore return address
    ADD  X27, X27, #16          // Restore the stack
    BR   X30                    // Return control to caller
// End prod_rec()

exit:
    NOP
