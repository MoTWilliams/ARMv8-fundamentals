// Morgan Williams - mtw0067
// CSCE 2610.001
// PA2-1: Assembly code to calculate y = 6 * sum_{n=1}^a (n^5)

// y = 6 * sum_{n=1}^a (n^5)
//   = 6 * [a^2 * (a+1)^2 * (2a^2+2a-1)] / 12
//   = [2a^6 + 6a^5 + 5a^4 - a^2] / 2

	.text                       // program section
	.global    main             // main
	.arch      armv8-a+fp+simd  // processor type
	.type      main, %function  // main function

main:
    // a -> X20 (assumed)
    // y goes in X21

    MUL  X9,  X20, X20          // a^2
    MUL  X10, X9,  X9           // a^2 * a^2 = a^4

    LSL  X11, X10, #2           // a^4 * 4
    SUB  X21, X11, X9           // y = 4a^4 - a^2
    ADD  X21, X10, X21          // y = 5a^4 - a^2

    MUL  X11, X20, X10          // a^5 = a * a^4
    LSL  X11, X11, #1           // a^5 * 2
    ADD  X21, X11, X21          // y = 2a^5 + 5a^4 - a^2
    ADD  X21, X11, X21          // y = 4a^5 + 5a^4 - a^2
    ADD  X21, X11, X21          // y = 6a^5 + 5a^4 - a^2

    MUL  X11, X9, X10           // a^6 = a^2 * a^4
    LSL  X11, X11, #1           // a^6 * 2
    ADD  X21, X11, X21          // y = 2a^6 + 6a^5 + 5a^4 - a^2

    LSR  X21, X21, #1           // y = [2a^6 + 6a^5 + 5a^4 - a^2]/2; a positive

    NOP                         // End of the program
