// Evaluate a polynomial expression with ARMv8 float arithmetic
.data
    .type   x, %object          // Declare array x
    .size   x, 4                // x has 4 elements
x:  .float  4.3, -2.7, 0.6, -8.9

.text
    .globl  main                // Declare main
    .arch   armv8-a+fp+simd     // ARMv8 processor
    .type   main, %function

// y = a(x[3])^3 - b(x[2])^2 + cx[1] - x[0]
main:
    // a -> S20 ; b -> S21 ; c -> S22
    ADR   X19, x                // &x[0] -> X19

    LDUR  S9, [X19, #12]        // load x[3] -> S9
    FMUL  S23, S9,  S9          // y = (x[3])^2 -> S23
    FMUL  S23, S23, S9          // y = (x[3])^3
    FMUL  S23, S20, S23         // y = a * (x[3])^3

    LDUR  S9, [X19, #8]         // load x[2] -> S9
    FMUL  S9,  S9,  S9          // (x[2])^2
    FMUL  S9,  S21, S9          // b * (x[2])^2
    FSUB  S23, S23, S9          // y = a(x[3])^3 - b(x[2])^2

    LDUR  S9, [X19, #4]         // load x[1] -> S9
    FMUL  S9,  S22, S9          // c * x[1]
    FADD  S23, S23, S9          // y = a(x[3])^3 - b(x[2])^2 + cx[1]

    LDUR  S9, [X19, #0]         // load x[0] -> S9
    FSUB  S23, S23, S9          // y = a(x[3])^3 - b(x[2])^2 + cx[1] - x[0]

    NOP
