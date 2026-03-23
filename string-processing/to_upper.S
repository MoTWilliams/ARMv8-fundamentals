// Convert all lower-case letters in a sentence to upper-case
.data
    .globl  str
    .type   str, %object

str:
    .asciz "Look at the BaNaNaS!"

.text
    .globl  main
    .arch   armv8-a+fp+simd
    .type   main, %function
    .type   to_upper, %function

main:
    MOV   X27, SP               // Move SP to X27 to avoid alignment exceptions

    ADR   X1,  str              // &str[0] -> X1
    BL    to_upper              // Call to_upper
    MOV   X19, X0               // result -> X19

    B     exit                  // Exit main function
// End main()

// In-place conversion of all lowercase letters in a string to uppercase
to_upper:
    SUB   X27, X27, #16         // Dig the stack for two registers
    STUR  X9, [X27, #0]         // Preserve X9
    STUR  X19,[X27, #8]         // Preserve X19 (we're using W19)

    MOV   X9,  X1               // c = &str[0] -> X9--initialize loop variable
Loop:
    LDURB W19,[X9,  #0]         // Load *c

    CBZ   W19, ExitLoop         // If *c == '\0', exit the loop

    CMP   W19, #97              // Compare *c and 'a'
    B.LT  NotLower              // If *c < 'a', it's not lowercase

    CMP   W19, #122             // Compare *c and 'z'
    B.GT  NotLower              // If *c > 'z', it's not lowercase

    SUB   W19, W19, #32         // Otherwise, convert *c to uppercase
    STURB W19,[X9,  #0]         // Store the new uppercase letter at c
    ADD   X9,  X9,  #1          // c++ (by only one byte)
    B     Loop                  // Loop again
NotLower:
    ADD   X9,  X9,  #1          // c++
    B     Loop                  // Loop again
ExitLoop:
    MOV   X0,  X1               // Return &str[0]

    LDUR  X9, [X27, #0]         // Restore X9
    LDUR  X19,[X27, #8]         // Restore X19
    ADD   X27, X27, #16         // Pop
    BR    X30                   // Return control to the caller
// End to_upper()

exit:
    NOP
