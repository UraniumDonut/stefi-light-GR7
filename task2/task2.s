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
    MOV     r2, #0x01           // load mask for adjusting port clock gating (A: LEDs)
    LDR     r0, [r1, #0]        // get current value of RCC_AHB2ENR
    ORRS    r0, r0, r2          // configure clock gating for ports
    STR     r0, [r1, #0]        // apply settings

#--- port init
#- LEDs
    LDR     r1, =GPIOA_MODER    // load port A mode register address
    MOVS    r2, #0x03           // prepare mask
    LDR     r0, [r1, #0]        // get current value of port A mode register
    BICS    r0, r2              // delete bits
    MOVS    r2, #0x01           // load configuration mask
    ORRS    r0, r0, r2          // apply mask
    STR     r0, [r1, #0]        // apply result to port A mode register

#- switch LED off
    LDR     r1, =GPIOA_ODR      // load port A output data register
    MOVS    r2, #0x01           // load mask for LED
    LDR     r0, [r1, #0]        // get current value of GPIOA
    ORRS    r0, r0, r2          // configure pin state
    STR     r0, [r1, #0]        // apply settings

#- buttons

    /* ... place your code here ... */


    CPSIE   i                   // enable interrupts globally


#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global main
    .type   main, %function
main:
    EORS    r0, r0, r2
    STR     r0, [r1, #0]

    BL      delay

    /* ... replace current code here ... */

    B       main


#----------------------------------------------------------------------------------------#

    .align  2
    .syntax unified
    .thumb
    .thumb_func
    .global delay
    .type   delay, %function
delay:
    MOVS    r6, #0              // ...
    LDR     r7, =0x400000       // ...
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
