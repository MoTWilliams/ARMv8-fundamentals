// An assembly program to count the digits in a sentence
.data
    .globl  str                 // Declare str
    .type   str, %object        // Define object str
str:                            // Put values in the string
    .asciz  "I have 271 cats and 96 dogs."

.text
    .globl  main                // Declare main
    .arch   armv8-a+fp+simd     // ARMv8 processor
    .type   main, %function     // Main function
    .type   count_dgt, %function// count_dgt function

main:
    MOV   X27, SP               // Stack pointer -> X27
    ADR   X19, str              // &str[0] -> X19

    MOV   X1,  X19              // arg = &str[0] -> X1
    BL    count_dgt             // Call count_dgt(str)
    MOV   X20, X0               // Store result in X20

    B     exit                  // Exit main
// End main

count_dgt:
    SUB   X27, X27, #16         // Dig the stack for 2 registers
    STUR  X9, [X27, #0]         // Preserve X9
    STUR  X10,[X27, #8]         // Preserve X10

    MOV   X9,  X1               // Initialize char* c = &str[0] -> X9
    MOV   X0,  #0               // Initialize digit count to 0 -> X0
loop:
    LDURB W10,[X9,  #0]         // Load *c (str[i]) -> W10

    CBZ   W10, exit_loop        // If *c == '\0', exit the loop

    CMP   W10, #48              // Compare *c and '0'
    B.LT  not_digit             // If *c < '0', it's not a digit
    CMP   W10, #57              // Compare *c and '9'
    B.GT  not_digit             // If *c > '9', it's not a digit

    ADD   X0,  X0,  #1          // Otherwise, increment the digit count
    ADD   X9,  X9,  #1          // c++ (by one byte)
    B     loop                  // Loop again
not_digit:
    ADD   X9,  X9,  #1          // Just increment the loop counter
    B     loop                  // and loop again
exit_loop:
    LDUR  X9, [X27, #0]         // Restore X9
    LDUR  X10,[X27, #8]         // Restore X10
    ADD   X27, X27, #16         // Restore the stack pointer

    BR    X30                   // Return control to the caller
// End count_dgt

exit:
    NOP
