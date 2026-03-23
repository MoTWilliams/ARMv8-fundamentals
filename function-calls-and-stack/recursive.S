// Recursively compute the sum of the first n integers
.data
    .globl  c                   // i64 c
    .type   c, %object
    .size   c, 8

    .globl  n                   // i64 n
    .type   c, %object
    .size   c, 8

c:  .xword  0
n:  .xword  5

// Program section
.text
    .globl  main                // Name the main function
    .arch   armv8-a+fp+simd     // Processor type

    .type   recsum, %function
    .type   main, %function

// i64 recsum(i64 n) {
//     if (n <= 0) return 0;
//     i64 head = n;
//     i64 tail = recsum(n - 1);
//     return head + tail;
// }
recsum:
    SUB  SP,  SP,  #16          // Dig the stack for two registers
    STUR X30,[SP,  #8]          // Store the return address
    STUR X0, [SP,  #0]          // Store n

    // if (n <= 0) return 0
    SUBS XZR, X0,  #0           // Compare n (arg = X0) and 0
    B.GT recurse                // Condition failed. Recurse

    SUB  X0,  X0,  X0           // Otherwise, set return value to 0
    ADD  SP,  SP,  #16          // Pop stack, don't bother restoring values
    BR   X30                    // Return

recurse:
    SUB  X0,  X0,  #1           // arg = n-1
    BL   recsum                 // Call recsum(n-1)

lvrec:
    LDUR X9, [SP,  #0]          // head = original n
    ADD  X0,  X9,  X0           // return register = head + tail
    LDUR X30,[SP,  #8]          // Restore return address
    ADD  SP,  SP,  #16          // Restore stack pointer
    BR   X30                    // Return

// int main() {
//     c = recsum(5);
//     return 0;
// }
main:
    // Main is a non-leaf, so store its return address on the stack
    SUB  SP,  SP,  #16          // Allocate space for one register, rounded up for 16-byte alignment
    STUR X30,[SP,  #0]          // Store the return address

    // c = recsum(5)
    ADR  X9,  n                 // Load &n into a temp
    LDUR X0, [X9,  #0]          // Load n into arg (X0)
    BL   recsum                 // Call recsum(5)
    ADR  X9,  c                 // Load &c into a temp
    STUR X0, [X9,  #0]          // Store the result in c

    // Return 0
    SUB  X0,  X0,  X0           // Set the return register to 0

    // Restore the stack
    LDUR X30,[SP,  #0]          // Restore the return address
    ADD  SP,  SP,  #16          // Restore the stack counter
    RET                         // Return from main
