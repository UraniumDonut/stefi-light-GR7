#****************************************************************************************#
#   Project:    task3 - switch triggered LEDs (interrupts)
#   File:       task3.s
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
#       27.02.2019  ML  move section of exception handlers to bottom of file,
#                           change ASM pseudo commands from .space to .org
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

    /* ... place your code here ... */

    /* N.B.
        Look at the .space or the .org assembler directive to insert the address of the
        ISRs at the right place in the vector table. Verify your settings by the help of
        the list file. */
	.org 0x00000058
    .word   _exti0              // EXTI0
	.org 0x0000009C
    .word   _exti7              // EXTI7

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
    MOVS    r5, #0
    MOVS    r6, #0
    MOVS    r7, #0
    MOV     r8, r0
    MOV     r9, r0
    MOV     r10, r0
    MOV     r11, r0
    MOV     r12, r0

#--- enable port clocking
    LDR     r1, =RCC_AHB2ENR    // load address of RCC_AHB2ENR
    MOV     r2, #0x03           // load mask for adjusting port clock gating (A: LEDs)
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
    BICS    r0, r0, r2          // configure pin state
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




#--- button interrupt config
#- enable clock for SYSCFG module
    LDR     r1, =RCC_APB2ENR    // load RCC APB2 peripheral clock enable register address
    MOVS    r2, #0x01           // bit 0: SYSCFGCOMPEN --> SYSCFG + COMP clock enable
    LDR     r0, [r1, #0]        // get current value
    ORRS    r0, r0, r2          // set bit
    STR     r0, [r1, #0]        // enable clock

#- connect GPIO pins of the buttons to EXTended Interrupt controller lines (EXTI)
#  in SYSCFG module (SYSCFG_* registers)
    LDR		r1, =SYSCFG_EXTICR1	// Set input line button s0
    MOVS 	r2, #0xF
    LDR     r0, [r1, #0]
    BICS    r0, r2              // delete bits
    MOVS	r2, #0x0001
    ORRS	r0, r0, r2
	STR     r0, [r1, #0]

    LDR		r1, =SYSCFG_EXTICR2 // Set input line button s3
    MOVS 	r2, #0xF000
    LDR     r0, [r1, #0]
    BICS    r0, r2              // delete bits
    MOVS	r2, #0x1000
    ORRS	r0, r0, r2
	STR     r0, [r1, #0]

#- configure lines in EXTI module (EXTI_* registers)
	LDR     r1, =EXTI_IMR1 		//Set interrupt mask for S0 and S3
    LDR     r2, =0x0081
	LDR     r0, [r1, #0]
	ORRS	r0, r0, r2
    STR     r0, [r1, #0]

	LDR 	r1, =EXTI_FTSR1		//enable falling trigger for S0 and S3
    LDR     r2, =0x0081
	LDR     r0, [r1, #0]
	ORRS	r0, r0, r2
    STR     r0, [r1, #0]

	LDR 	r1, =EXTI_RTSR1		//disable rising trigger for S0 and S3
    LDR     r2, =0x0081
	LDR     r0, [r1, #0]
	BICS	r0, r2
    STR     r0, [r1, #0]


#- NVIC: set interrupt priority, clear pending bits
#  and enable interrupts for buttons (see: PM, ch. 4.2)

	LDR		r1, =NVIC_ICPR0		//Clear pending interrupts for S0 and S3
    LDR 	r2, =0x00800040
    LDR     r0, [r1, #0]
    ORRS	r0, r0, r2
	STR     r0, [r1, #0]

    LDR		r1, =NVIC_ISER0		//Enable interrupts for S0 and S3
    LDR 	r2, =0x00800040
    LDR     r0, [r1, #0]
    ORRS	r0, r0, r2
	STR     r0, [r1, #0]

    CPSIE   i                   // enable interrupts globally


#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global main
    .type   main, %function
main:

    B       main	//loop forever



#----------------------------------------------------------------------------------------#
    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global todoleft
    .type   todoleft, %function

#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global delay
    .type   delay, %function
delay:
    MOVS    r6, #0              // ...
    LDR     r7, =0x31400       // ...
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

    .align  2
    .syntax unified
    .thumb
    .type   _exti0, %function
_exti0:
    PUSH    {lr}                // save special content
#--- do the work
	BL		delay				//delay for debounce
	LDR     r1, =GPIOB_IDR 		//Load input data register
    LDR     r0,  [r1, #0]
    MOV     r2, #0xFE			//mask S0
    BICS    r0, r2				//delete bits
    CMP     r0, #0x1			//check button off
    IT      EQ					//if button off
    BEQ		clean				//skip LED toggle

	LDR     r1, =GPIOA_ODR		//Load LED GPIO register
	MOVS	r2, #0x3			//Mask LED0, LED1
	LDR     r0, [r1, #0]
    EORS    r0, r0, r2			//toggle LEDs
    STR     r0, [r1, #0]		//write changes
    clean:
	BL		delay				//delay for debounce

#--- clear interrupt flag
    LDR		r1, =EXTI_PR1		//Load pending interrupt register
    MOVS	r2, #0x1
    LDR     r0, [r1, #0]
    ORRS	r0, r0, r2
    STR     r0, [r1, #0]



#--- leave ISR
    POP     {r1}                // get special content back
    BX      r1                  // go back to where we came from


#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .type   _exti7, %function
_exti7:
    PUSH    {lr}                // save special content
#--- do the work
	BL		delay				//delay for debounce
	LDR     r1, =GPIOB_IDR 		//Load input data register
    LDR     r0,  [r1, #0]
    MOV     r2, #0x7F			//mask S3
    BICS    r0, r2				//delete bits
    LSR		r0, r0, #7			//shift value to pos. 0
    CMP     r0, #0x1			//check button off
    IT      EQ					//if button off
    BEQ		clean3				//skip LED toggle

	LDR     r1, =GPIOA_ODR		//Load LED GPIO register
	MOVS	r2, #0xC			//Mask LED0, LED1
	LDR     r0, [r1, #0]
    EORS    r0, r0, r2			//toggle LEDs
    STR     r0, [r1, #0]		//write changes
    clean3:
	BL		delay				//delay for debounce

#--- clear interrupt flag
    LDR		r1, =EXTI_PR1		//Load pending interrupt register
    MOVS	r2, #0x1
    LDR     r0, [r1, #0]
    ORRS	r0, r0, r2
    STR     r0, [r1, #0]



#--- leave ISR
    POP     {r1}                // get special content back
    BX      r1                  // go back to where we came from
#----------------------------------------------------------------------------------------#
.lp2:           // this label is only to nicify the line up in the .lst file
    .ltorg
#----------------------------------------------------------------------------------------#

    .end


#************************************** E O F *******************************************#
