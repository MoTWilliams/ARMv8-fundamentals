// Recursive exponentiation, stack, and function calls
.data
    .globl  c                   // i64 c
    .type   c, %object
    .size   c, 8

    .globl  b                   // i64 base
    .type   b, %object
    .size   b, 8

    .globl  e                   // i64 exponent
    .type   e, %object
    .size   e, 8

c:  .xword  0
b:  .xword  3
e:  .xword  4

// Program section
.text
    .globl  main                // Name the main function
    .arch   armv8-a+fp+simd     // Processor type

    .type   pow, %function
    .type   main, %function

// i64 pow(i64 base, i64 exp) {
//     if (exp <= 0) return 1;
//     long head = base;
//     long tail = pow(base, exp - 1);
//     return head * tail;
// }
pow:
    SUB  SP,  SP,  #32          // Dig the stack for the return address, base, exp, rounded for 16-byte alignment
    STUR X30,[SP,  #16]         // Store the caller's return address
    STUR X0, [SP,  #8]          // Store base
    STUR X1, [SP,  #0]          // Store exp

    // if (exp <= 0) return 1;
    SUBS XZR, X1,  #0           // Compare exp and 0
    B.GT recurse                // Condition false. Recurse

    MOV  X0,  #1                // Otherwise, set return value to 1
    ADD  SP,  SP,  #32          // Pop from the stack, don't bother restoring
    BR   X30                    // Return

recurse:
    SUB  X1,  X1,  #1           // arg 2 = exp - 1
    BL   pow                    // arg 1 doesn't change. Just call pow(base, exp - 1)

unroll:
    LDUR X9, [SP,  #8]          // Head (temp) = old base
    MUL  X0,  X9,  X0           // Return register = head * tail
    LDUR X30,[SP,  #16]         // Restore return address
    ADD  SP,  SP,  #32          // Restore stack pointer
    BR   X30                    // Return

// int main() {
//     c = pow(3,4); --> 81
//     return 0;
// }
main:
    SUB  SP,  SP,  #16          // Dig the stack one register, rounded up for 16-byte alignment
    STUR X30,[SP,  #0]          // Store the return address on the stack

    ADR  X9,  b                 // Load &b into a temp
    LDR  X0, [X9,  #0]          // Load b into arg 1
    ADR  X9,  e                 // Load &e into a temp
    LDR  X1, [X9,  #0]          // Load e into arg 2
    BL   pow                    // Call pow(base, exp) with base = 3 and exp = 4
    ADR  X9,  c                 // Load &c into a temp
    STUR X0, [X9,  #0]          // Store the result in c

    SUB  X0,  X0,  X0           // Set the return register to 0

    LDUR X30,[SP,  #0]          // Restore the caller's return address
    ADD  SP,  SP,  #16          // Restore the stack pointer
    RET                         // Return 0 from main

