// An ARMv8 assembly program to estimate sin x^2 from a series with a single loop
// sin x^2 = sum from n=0 to a of (-1)^n * x^(4n+2) / (2n+1)!
.text
    .globl  main                // Declare main
    .arch   armv8-a+fp+simd     // ARMv8 processor
    .type   main, %function

main:
    // -1.0 <= x <= 1.0 -> D20 ; 0 < a < 11 -> X20

    UCVTF D19, X20              // Convert a to double -> D19

    // Constants
    FMOV  D22, 1.0              // 1.0 -> D22
    FMOV  D23, 2.0              // 2.0 -> D23

    // Initialize sum with term_0 and start loop at n=1
    FMOV  D9,  D22              // Initialize loop counter n=1 -> D9
    FMUL  D10, D20, D20         // term_0 = x^2 -> D10
    FMOV  D21, D10              // Initialize sum to term_0 -> D21

    // Other important values
    FMUL  D24, D10, D10         // Maintain (-1)^n * x^4 -> D24
    FMOV  D11, XZR              // Maintain n-1 -> D11
loop:
    FCMP  D9,  D19              // Compare n and a
    B.GT  exit_loop             // If n > a, leave the loop

    // term *= -(x^4) / ((2(n-1) + 2) * (2(n-1) + 3))
    FADD  D12, D11, D11         // 2 * (n-1) -> D12
    FADD  D12, D12, D23         // 2(n-1) + 2
    FADD  D13, D12, D22         // 2(n-1) + 2 + 1 -> D13
    FMUL  D12, D12, D13         // (2(n-1) + 2) * (2(n-1) + 3) -> D12
    FNEG  D24, D24              // (-1)^n (x^4) -> D13
    FDIV  D12, D24, D12         // -(x^4) / ((2(n-1) + 2) * (2(n-1) + 3)) -> D12
    FMUL  D10, D10, D12         // term *= -(x^4) / ((2(n-1) + 2)*(2(n-1) + 3))

    FADD  D21, D21, D10         // sum += term

    FMOV  D11, D9               // Preserve n-1
    FADD  D9,  D9,  D22         // n++
    B     loop                  // Loop again

exit_loop:
    NOP
