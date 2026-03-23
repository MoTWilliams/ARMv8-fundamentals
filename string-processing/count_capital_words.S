// An assembly program to count the all-upper-case words in a string
.data
    .globl  str                 // Declare string
    .type   str, %object        // Define str object
str:                            // Put values in the string
    .asciz  "This STRING has SOME  NumB3r5 AND words"

.text
    .globl  main                // Declare main
    .arch   armv8-a+fp+simd     // ARMv8 processor
    .type   main, %function     // Main function
    .type   count_wd, %function // count_wd function

main:
    MOV   X27, SP               // Stack pointer -> X27
    ADR   X19, str              // &str[0] -> X19

    MOV   X1,  X19              // arg = &str[0] -> X1
    BL    count_wd              // Call count_wd(str)
    MOV   X20, X0               // Store result in X20

    B     exit                  // Exit main
// End main

count_wd:
    SUB   X27, X27, #32         // Dig the stack 4 registers
    STUR  X9, [X27, #0]         // Preserve X9
    STUR  X10,[X27, #8]         // Preserve X10
    STUR  X11,[X27, #16]        // Preserve X11
    STUR  X12,[X27, #24]        // Preserve X12

    MOV   X9,  X1               // Initialize char* p = &str[0] -> X9
    MOV   X0,  #0               // Initialize capWord counter to 0 -> X0

    // state = upperWord upperChar inWord
    MOV   W10, #0               // Initialize state = all false (0b000) -> W10
loop:
    LDURB W11,[X9,  #0]         // char c = *p -> W11
    CBZ   W11, last_word        // Prepare to exit the loop when c == '\0'

    CMP   W11, #32              // Compare c and ' '
    B.EQ  exit_word             // If c == ' ' end the word

    // Otherwise, set upperChar appropriately
    CMP   W11, #90              // Compare c and 'Z'
    B.LE  check_char_upper      // If c <= 'Z', it might be uppercase

check_for_new:
    TBNZ  W10, #0, not_word_start   // if (state AND 0b001) != 0, inWord = true

    // Otherwise, start new word
    ORR   W10, W10, #1          // inWord = true (OR 0b001)

    // upperWord = upperChar
    LSL   W12, W10, #1          // temp = state << 1 -> X12
    EOR   W12, W10, W12         // temp = state XOR temp
    AND   W12, W12, #4          // temp = temp AND 0b100
    EOR   W10, W12, W10         // state = temp XOR state

    B     next_iter             // Finish the iteration

exit_word:
    MOV   W12, W10              // Store a copy of the current state
    BIC   W10, W10, #1          // inWord = false (Clear 0b001)
    BIC   W10, W10, #4          // upperWord = false (Clear 0b100)
    TBNZ  W12, #2, inc_wd_count // if (stored AND 0b100) != 0, upperWord = true
    B     next_iter             // Otherwise, just finish the iteration

check_char_upper:
    CMP   W11, #65              // Compare c and 'A'
    B.GE  char_upper            // If c >= 'A', it is uppercase
    B     check_for_new         // Otherwise, it's already false, so move on
char_upper:
    ORR   W10, W10, #2          // upperChar = true (OR 0b010)
    B     check_for_new         // Now move on

not_word_start:
    TBZ   W10, #2,  next_iter   // if (state AND 0b100) == 0, finish iteration
    TBNZ  W10, #1,  next_iter   // if (state AND 0b010) != 0, finish iteration

    BIC   W10, W10, #4          // Otherwise, word not uppercase (Clear 0b100)
next_iter:
    BIC   W10, W10, #2          // upperChar = false (Clear 0b010)
    ADD   X9,  X9,  #1          // p++ one byte
    B     loop                  // Loop again

inc_wd_count:
    ADD   X0,  X0,  #1          // capWord++
    B     next_iter             // Finish the iteration

last_word:
    TBNZ  W10, #2, last_inc     // if (state AND 0b100) != 0, upperWord = true

exit_loop:
    LDUR  X9, [X27, #0]         // Restore X9
    LDUR  X10,[X27, #8]         // Restore X10
    LDUR  X11,[X27, #16]        // Restore X11
    LDUR  X12,[X27, #24]        // Restore X12
    ADD   X27, X27, #32         // Restore stack pointer
    BR    X30                   // Return control to the caller

last_inc:
    ADD   X0,  X0,  #1          // capWord++
    B     exit_loop             // Finish exiting the loop
// End count_wd()

exit:
    NOP




























