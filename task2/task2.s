#****************************************************************************************#
#   Project:    task2 - switch triggered LEDs
#   File:       task2.s
#
#   Language:   ASM
#
#   Hardware:   STefi Light v1.1
#   Processor:  STM32G431KBT6U
#
#   Author:     Manuel Lederhofer
#   Datum:      31.10.2014
#
#   Version:    5.0
#   History:
#       31.10.2014  ML  create file
#       27.09.2018  ML  edit comments, extend vector table
#       18.12.2018  ML  port from MKL05Z32VLC4 to STM32L476RG
#       27.02.2019  ML  move section of exception handlers to bottom of file
#		25.09.2019	ML	minor changes for a better code and comment understanding
#       04.09.2020  HL  port from STM32L476RG to STM32F411xE
#       21.09.2020  ML  tidy up, comments and formatting
#       29.09.2021  ML  port from STM32F411xE to STM32F042K6T6
#       09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
#
#   Status:     working
#
#   Description:
#       See the description and requirements of the requested application
#       in the lab exercise guide.
#
#   Notes:
#       - MCU speed at startup is 16 MHz
#
#   ToDo:
#       - Change the example code to match the description and requirements
#          of the requested application in the lab exercise guide.
#****************************************************************************************#

    .include "G431_addr.s"


#----------------------------------------------------------------------------------------#
    .section .vectortable,"a"   // vector table at begin of ROM
#----------------------------------------------------------------------------------------#

    .align  2

    .word   0x20004000          // initial Stack Pointer:   0x20000000 (RAM base) + 0x4000 (16K SRAM1 length)
    .word   0x08000401          // initial Program Counter
    .word   _nmi                // NMI
    .word   _hardf              // hard fault


#----------------------------------------------------------------------------------------#
    .text                       // section .text (default section for program code)
#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global init
    .type   init, %function
init:
    CPSID   i                   // disable interrupts globally

    MOVS    r0, #0              // safely initialize the GPRs
    MOVS    r1, #0
    MOVS    r2, #0
    MOVS    r3, #0
    MOVS    r4, #0
    MOVS    r5, #1				//r5 is Button 3 before
    MOVS    r6, #0
    MOVS    r7, #0
    MOV     r8, #1				//r8 is Button 0 before
    MOV     r9, #0				//r9 is the combinding condition
    MOV     r10, r0
    MOV     r11, r0
    MOV     r12, r0

#--- enable port clocking
    LDR     r1, =RCC_AHB2ENR    // load address of RCC_AHB2ENR
    MOV     r2, #0x03           // load mask for adjusting port clock gating (A and B: LEDs and buttons)
    LDR     r0, [r1, #0]        // get current value of RCC_AHB2ENR
    ORRS    r0, r0, r2          // configure clock gating for ports
    STR     r0, [r1, #0]        // apply settings

#--- port init
#- LEDs
    LDR     r1, =GPIOA_MODER    // load port A mode register address
    MOVS    r2, #0xFF           // prepare mask Zero all
    LDR     r0, [r1, #0]        // get current value of port A mode register
    BICS    r0, r2              // delete bits
    MOVS    r2, #0x55           // load configuration mask Output All
    ORRS    r0, r0, r2          // apply mask
    STR     r0, [r1, #0]        // apply result to port A mode register

#- switch LEDs off
    LDR     r1, =GPIOA_ODR      // load port A output data register
    MOVS    r2, #0xF            // load mask for all LEDs
    LDR     r0, [r1, #0]        // get current value of GPIOA
    ORRS    r0, r0, r2          // configure pin state
    STR     r0, [r1, #0]        // apply settings


#- buttons
    MOV     r3, #0x1
    MOV     r4, #0x0

    LDR     r1, =GPIOB_MODER    // load port B mode register address
    MOVS    r2, #0x03           // prepare mask Zero all
    LDR     r0, [r1, #0]        // get current value of port B mode register
    BICS    r0, r2              // delete bits
    LSL		r2, r2, #14			// offset for S3
    BICS    r0, r2              // delete bits

    STR     r0, [r1, #0]        // apply result to port B mode register


    LDR     r1, =GPIOB_PUPDR    // load port B mode register address
    MOVS    r2, #0x03           // prepare mask Zero all
    LDR     r0, [r1, #0]        // get current value of port B mode register
    BICS    r0, r2              // delete bits
    LSL		r2, r2, #14			// offset for S3
    BICS    r0, r2              // delete bits
    MOVS    r2, #0x1            // load configuration mask S3
    ORRS    r0, r0, r2          // apply mask
    LSL		r2, r2, #14			// offset for S3
    ORRS    r0, r0, r2          // apply mask
    STR     r0, [r1, #0]        // apply result to port B mode register


    CPSIE   i                   // enable interrupts globally


#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global main
    .type   main, %function
main:

	MOV     r9, #0				//clear combined condition
	MOV		r9, r5				//check button 1 before
	LDR     r1, =GPIOB_IDR 		//load input data register
    LDR     r0,  [r1, #0]
    MOV     r2, #0x7F			//mask S3
    BICS    r0, r2				//delete bits
    LSR		r0, r0, #6			//shift value to pos. 1
    ORRS	r9, r9, r0			//add S3 to combined condition
    LSR		r0, r0, #1			//return s3 state to pos. 0
    MOV		r5, r0				//set button 3 before state
    CMP     r9, #0x1			//check combined condition
    IT      EQ
    BLEQ    todoleft			//branch if true

	MOV     r9, #0				//clear combined condition
	MOV		r9, r8				//check button 1 before
	LDR     r1, =GPIOB_IDR 		//Load input data register
    LDR     r0,  [r1, #0]
    MOV     r2, #0xFE			//mask S0
    BICS    r0, r2				//delete bits
    LSL		r0, r0, #1			//shift value to pos. 1
    ORRS	r9, r9, r0			//add S0 to combined condition
    LSR		r0, r0, #1			//return s0 state to pos. 0
    MOV		r8, r0				//set button 0 before state
    CMP     r9, #0x1			//check combined condition
    IT      EQ
    BLEQ    todoright			//branch if true



    BL      delay


    B       main



#----------------------------------------------------------------------------------------#
    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global todoright
    .type   todoright, %function

todoright:
	MOV		r8, #0
    LDR     r1, =GPIOA_ODR      // load port A output data register
    LDR     r0, [r1, #0]        // get current value of GPIOA
    MOVS    r2, #0x3            // load mask for LED 0+1
    EORS    r0, r0, r2
    STR     r0, [r1, #0]		// write toggle
    BX      lr                  // return to main function

#----------------------------------------------------------------------------------------#
    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global todoleft
    .type   todoleft, %function

todoleft:
	MOV		r5, #0
    LDR     r1, =GPIOA_ODR      // load port A output data register
    LDR     r0, [r1, #0]        // get current value of GPIOA
    MOVS    r2, #0xC            // load mask for LED 2+3
    EORS    r0, r0, r2
    STR     r0, [r1, #0]		//write toggle
    BX      lr                  // return to main function

#----------------------------------------------------------------------------------------#
    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global delay
    .type   delay, %function

delay:
    MOVS    r6, #0              // ...
    LDR     r7, =0x19640       // ...
.L1:
    ADDS    r6, r6, #1          // ...
    CMP     r6, r7              // ...
    BNE     .L1                 // ...
    BX      lr                  // ...


#----------------------------------------------------------------------------------------#

    .align 2
    .global stop
stop:
    NOP                         // do nothing (NOP is here to avoid a debugger crash, only)
    B       stop                // if this line is reached, something went wrong


#----------------------------------------------------------------------------------------#
.lp1:           // this label is only to nicify the line up in the .lst file
    .ltorg
#----------------------------------------------------------------------------------------#


#----------------------------------------------------------------------------------------#
    .section .exhand,"ax"       // section for exception handlers
#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .type   _nmi, %function
_nmi:
#--- enable clock
    LDR     r1, =RCC_AHB2ENR    // load address of RCC_AHB2ENR
    MOV     r2, #0x01           // load mask
    LDR     r0, [r1, #0]        // get current value of RCC_AHB2ENR
    ORRS    r0, r0, r2          // configure clock gating for port
    STR     r0, [r1, #0]        // apply settings

#--- init pins
    LDR     r1, =GPIOA_MODER    // load port A mode register address
    MOVS    r2, #0xFF           // prepare mask
    LDR     r0, [r1, #0]        // get current value of port A mode register
    BICS    r0, r0, r2          // delete bits
    MOVS    r2, #0x44           // load configuration mask
    ORRS    r0, r0, r2          // configure pins
    STR     r0, [r1, #0]        // apply settings to port A mode register

#--- switch some LEDs on
    LDR     r1, =GPIOA_ODR      // load port A data output register address
    MOVS    r2, #0x0A           // load mask for blue and yellow LED
    LDR     r0, [r1, #0]
    BICS    r0, r0, r2
    STR     r0, [r1, #0]        // switch LEDs on

    B   _nmi


#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .type   _hardf, %function
_hardf:
#--- enable clock
    LDR     r1, =RCC_AHB2ENR    // load address of RCC_AHB2ENR
    MOV     r2, #0x01           // load mask
    LDR     r0, [r1, #0]        // get current value of RCC_AHB2ENR
    ORRS    r0, r0, r2          // configure clock gating for port
    STR     r0, [r1, #0]        // apply settings

#--- init pins
    LDR     r1, =GPIOA_MODER    // load port A mode register address
    MOVS    r2, #0xFF           // prepare mask
    LDR     r0, [r1, #0]        // get current value of port A mode register
    BICS    r0, r0, r2          // delete bits
    MOVS    r2, #0x11           // load configuration mask
    ORRS    r0, r0, r2          // configure pins
    STR     r0, [r1, #0]        // apply settings to port A mode register

#--- switch some LEDs on
    LDR     r1, =GPIOA_ODR      // load port A data output register address
    MOVS    r2, #0x05           // load mask for red and green LED
    LDR     r0, [r1, #0]
    BICS    r0, r0, r2
    STR     r0, [r1, #0]        // switch LEDs on

    B       _hardf


#----------------------------------------------------------------------------------------#
.lp2:           // this label is only to nicify the line up in the .lst file
    .ltorg
#----------------------------------------------------------------------------------------#

    .end


#************************************** E O F *******************************************#
