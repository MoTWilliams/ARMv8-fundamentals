// An ARMv8 assembly program to find the median of a sorted array of floats
.data
    .type   arr, %object        // Declare array arr

arr:                            // Store values in arr
    .float  0.25, 1.0, 1.75, 2.5, 3.14

.text
    .globl  main                // Declare main
    .arch   armv8-a+fp+simd     // ARMv8 processor
    .type   main, %function
    .type   med_val, %function  // Declare med_val function

main:
    MOV   X27, SP               // To avoid 16-alignment exception

    ADR   X19, arr              // &arr[0] -> X19

    MOV   X1,  X19              // addr = &arr[0] -> X1
    MOV   X2,  X20              // len = n -> X2
    BL    med_val               // Call med_val(addr, len)
    FMOV  S20, S0               // median -> S20

    B     exit                  // Exit main
// End main()

med_val:
    SUB   X27, X27, #40         // Dig the stack for 5 registers
    STUR  X9, [X27, #0]         // Preserve X9
    STUR  X10,[X27, #8]         // Preserve X10
    STUR  X11,[X27, #16]        // Preserve X11
    STUR  D9, [X27, #24]        // Preserve D9
    STUR  D10,[X27, #32]        // Preserve D10

    ASR   X9,  X2,  #1          // len / 2 (floor division) -> X9
    LSL   X10, X9,  #2          // len/2 * 4 bytes -> X10
    ADD   X10, X1,  X10         // &arr[len/2] -> X10
    LDUR  S9, [X10, #0]         // arr[len/2] -> S9

    SUB   X11, X2,  X9          // len - len/2 -> X11
    CMP   X9,  X11              // Compare len/2 and (len - len/2)
    B.EQ  even_elems            // If len - len/2 == len/2, arr has even # elems

    FMOV  S0,  S9               // Otherwise, arr[len/2] = median
leave_func:
    LDUR  X9, [X27, #0]         // Restore X9
    LDUR  X10,[X27, #8]         // Restore X10
    LDUR  X11,[X27, #16]        // Restore X11
    LDUR  D9, [X27, #24]        // Restore D9
    LDUR  D10,[X27, #32]        // Restore D10
    ADD   X27, X27, #40         // Restore the stack
    BR    X30

// Even # elems--average the two middle elems
even_elems:
    LDUR  S10,[X10, #-4]        // arr[len/2 - 1] -> S10 <- THIS LINE

    // Average the middle elements
    FADD  S0,  S9,  S10         // arr[len/2] + arr[len/2 - 1]
    FMOV  S9,  2.0              // Store 2.0 in a float register -> S10
    FDIV  S0,  S0,  S9          // Divide the sum by 2 and return

    B     leave_func

exit:
    NOP
