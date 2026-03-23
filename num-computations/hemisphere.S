// Compute the surface area and volume of a sphere
// Surface area = 2 * pi * r^2 ; Volume = (2/3) * pi * r^3
.data
    .globl  r
    .type   r, %object          // Declare radius
r:
    .float  1.362               // Give the radius a value

    .type   constants, %object  // Declare constants array
    .size   constants, 3
constants:
    .float  3.1415, 2.0, 3.0    // pi, two, three

.text
    .globl  main                // Declare main
    .arch   armv8-a+fp+simd     // ARMv8 proccessor
    .type   main, %function
    .type   hemisphere, %function

main:
    MOV   X27, SP               // Stack pointer -> X27
    ADR   X9, r                 // &r -> X9
    LDUR  S2, [X9,  #0]         // arg2 = r -> S2
    ADR   X1, constants         // arg1 = &constants -> X1

    BL    hemisphere            // Call hemisphere(&constants, r)

    FMOV  S19, S0               // Surface area -> S19
    FMOV  S20, S1               // Volume -> S20

    B     exit                  // Exit main
// End main()

hemisphere:
    FMUL  S0,  S2,  S2          // SA (intermediate) = r*r -> S0
    LDUR  S9, [X1,  #0]         // pi -> S9
    FMUL  S9,  S9,  S0          // SA (intermediate) = pi * r^2 -> S9
    FADD  S0,  S9,  S9          // Curved SA = 2 * pi * r^2 -> S0
    FMUL  S1,  S2,  S0          // V (intermediate) = r * 2.0 * pi * r^2
    FADD  S0,  S9,  S0          // Total SA = (2 * pi * r^2) + (pi * r^2)
    LDUR  S9, [X1,  #8]         // load 3.0 -> S9
    FDIV  S1,  S1,  S9          // V = (2.0 * pi * r^3) / 3.0

    BR    X30                   // Return control to caller
// End hemisphere()

exit:
    NOP
