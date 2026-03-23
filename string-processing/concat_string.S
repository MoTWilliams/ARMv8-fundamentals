// An assembly program to concatenate two strings together in-place
.data
    .globl  dest                // Declare destination string
    .type   dest, %object       // Define dest object
dest:                           // Put values in dest
    .asciz  "Hello"

    .globl  src                 // Declare source string
    .type   src, %object        // Define src object
src:                            // Put values in src
    .asciz  " world!"

.text
    .globl  main                // Declare main
    .arch   armv8-a+fp+simd     // ARMv8 processor
    .type   main, %function     // Main function
    .type   strcat, %function   // strcat function

main:
    MOV   X27, SP               // Stack pointer -> 27
    ADR   X19, dest             // &dest[0] -> X19
    ADR   X20, src              // &src[0] -> X20

    MOV   X1,  X19              // arg1 = &dest[0] -> X1
    MOV   X2,  X20              // arg2 = &src[0] -> X2
    BL    strcat                // Call strcat(dest, src)

    B     exit                  // Exit main
// End main

strcat:
    SUB   X27, X27, #24         // Dig the stack for 3 registers
    STUR  X9, [X27, #0]         // Preserve X9
    STUR  X10,[X27, #8]         // Preserve X10
    STUR  X11,[X27, #16]        // Preserve X11

    MOV   X9,  X1               // Initialize char* d = &dest[0] -> X9
    MOV   X10, X2               // Initialize char* s = &src[0] -> X10
find_dest_end:
    LDURB W11,[X9,  #0]         // Load *d (dest[j]) -> W11
    CBZ   W11, concat_str       // If *d == '\0', end found. Begin concat
    ADD   X9,  X9,  #1          // d++ (by one byte)
    B     find_dest_end         // Loop again
concat_str:
    LDURB W11,[X10, #0]         // Load *s (src[j]) -> W11
    STURB W11,[X9,  #0]         // *d = *s (concatenate character)
    CBZ   W11, exit_strcat      // If *s == '\0', exit loop

    ADD   X9,  X9,  #1          // d++ one byte
    ADD   X10, X10, #1          // s++ one byte
    B     concat_str            // Loop again
exit_strcat:
    LDUR  X9, [X27, #0]         // Restore X9
    LDUR  X10,[X27, #8]         // Restore X10
    LDUR  X11,[X27, #16]        // Restore X11
    ADD   X27, X27, #24         // Restore the stack pointer
    BR    X30                   // Return control to the caller
// End strcat

exit:
    NOP
