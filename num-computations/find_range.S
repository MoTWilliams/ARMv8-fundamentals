// ARMv8 assembly program to find the range of an array

.data
    .globl  arr                 // The static array
    .type   arr, %object
    .size   arr, 512            // 64 8-byte elements = 512 bytes

arr:
    .xword 42, 319, -587, 12, 9081, 234, -999, 7312

.text
    .globl  main                // Name the main function
    .arch   armv8-a+fp+simd     // ARMv8 processor

    .type   find_rng, %function
    .type   main, %function

// Main function
main:
    MOV  X27, SP                // Copy stack pointer to X27
    ADR  X19, arr               // Load &arr into X19

    // X21 = find_rng(addr,len)
    MOV  X1,  X19               // addr = &arr -> X1
    MOV  X2,  X20               // len = n = X20 -> X2
    BL   find_rng               // Call find_rng(addr,len)
    MOV  X21, X0                // range -> X21
    B    exit                   // Exit main

// Find an array's range by iterating over its elements' addresses
// i64 find_rng(i64 *arr, i64 len) {
//         i64 *p = &arr[0], min = *p, max = *p;
//
//         while (p < &arr[len]) {
//                 min = *p < min ? *p : min;
//                 max = *p > max ? *p : max;
//                 p++;
//         }
//
//         return max - min;
// }
find_rng:
    SUB  X27, X27, #40          // Dig the stack for 5 registersX25	0x0000000000000000	64	R/W

    STUR X9, [X27, #0]          // Preserve X9
    STUR X10,[X27, #8]          // Preserve X10
    STUR X19,[X27, #16]         // Preserve X19
    STUR X20,[X27, #24]         // Preserve X20
    STUR X21,[X27, #32]         // Preserve X21

    // Initialization
    MOV  X9,  X1                // p = &arr[0] -> X9
    LSL  X19, X2,  #3           // len * 8 bytes
    ADD  X19, X1,  X19          // &arr[len] -> X19

    LDUR X20,[X9,  #0]          // min = *p -> X20
    MOV  X21, X20               // max = *p -> X21

Loop:
    CMP  X9,  X19               // Compare p and &arr[len]
    B.GE ExitLp                 // if p >= &arr[len], exit the loop

    LDUR X10,[X9,  #0]          // current = *p
    ADD  X9,  X9,  #8           // p++

    CMP  X10, X20               // Compare current and min
    B.LT NewMin                 // If current < min, current is the new min

    CMP  X10, X21               // Compare current and max
    B.GT NewMax                 // If current > max, current is the new max

    B    Loop                   // Loop again

NewMin:
    MOV  X20, X10               // min = current
    B    Loop                   // Loop again

NewMax:
    MOV  X21, X10               // max = current
    B    Loop                   // Loop again

ExitLp:
    SUB  X0,  X21, X20          // Return range = max-min

    LDUR X9, [X27, #0]          // Restore X9
    LDUR X10,[X27, #8]          // Restore X10
    LDUR X19,[X27, #16]         // Restore X19
    LDUR X20,[X27, #24]         // Restore X20
    LDUR X21,[X27, #32]         // Restore X21
    ADD  X27, X27, #40          // Restore the stack pointer

    BR   X30                    // Return control to caller
// End find_rng()

exit:
    NOP










