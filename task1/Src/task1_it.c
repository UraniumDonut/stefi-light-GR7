/* ***************************************************************************************
 *  Project:    task1 - running LED with key control
 *  File:       task1_it.c
 *
 *  Language:   C
 *
 *  Hardware:   STefi Light v1.1
 *  Processor:  STM32G431KBT6U
 *
 *  Author:     Manuel Lederhofer
 *  Datum:      10.09.2021
 *
 *  Version:    2.0
 *  History:
 *      10.09.2021  ML  create project
 *      09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
 *
 *  Status:     working
 *
 *  Description:
 *          this file contains the interrupt vector table and the implementation of all
 *          interrupt handlers used in the lab exercises.
 *
 *  Notes:
 *      - MCU speed at startup is 16 MHz
 *
 ************************************************************************************** */

/* ------------------------------------ INCLUDES -------------------------------------- */
#include "stm32g431xx.h"
#include "STefi-Light.h"


/* ------------------------------------ DEFINES --------------------------------------- */
/* ------------------------------------ TYPE DEFINITIONS ------------------------------ */


/* ------------------------------------ GLOBAL VARIABLES ------------------------------ */
extern void* _estack;           // initial stack pointer from ldscript
extern void* Reset_Handler;     // exception handler from startup code


/* ------------------------------------ PRIVATE VARIABLES ----------------------------- */
/* ------------------------------------ PROTOTYPES ------------------------------------ */


/* ------------------------------------ GLOBAL FUNCTIONS (Exceptions Handlers) -------- */

/* ------------------------------------------------------------------------------------ *\
 * method:  void ISR_error(void)
 *
 * Default interrupt handler for core interrupts.
 * Enables the green and red LED on the STefi Light board.
\* ------------------------------------------------------------------------------------ */
void ISR_error(void)
{
    /* init */
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;    // PA: clock on (LEDs)
    GPIOA->ODR |= MASK_LED_ALL;
    GPIOA->MODER = (GPIOA->MODER & 0xFFFFFF00) | 0x11;

    while(1)
    {   /* light up the LEDs permanently */
        GPIOA->ODR &= ~(MASK_LED_GREEN | MASK_LED_RED);
    }
}


/* ------------------------------------------------------------------------------------ *\
 * method:  void ISR_default(void)
 *
 * Default interrupt handler for non-core interrupts.
 * Enables the blue and yellow LED on the STefi Light board.
\* ------------------------------------------------------------------------------------ */
void ISR_default(void)
{
    /* init */
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;    // PA: clock on (LEDs)
    GPIOA->ODR |= MASK_LED_ALL;
    GPIOA->MODER = (GPIOA->MODER & 0xFFFFFF00) | 0x44;

    while(1)
    {   /* light up the LEDs permanently */        GPIOA->ODR &= ~(MASK_LED_BLUE | MASK_LED_YELLOW);
    }
}


/* ------------------------------------ INTERRUPT VECTOR TABLE ------------------------ */

__attribute__ ((section (".isr_vector")))
void (* const paIsrFunc[118])(void) =
{
    /* --- core vectors --- */
    (void *)&_estack,       /*  00 (0x00000000)  initial stack pointer */
    (void *)&Reset_Handler, /*  01 (0x00000004)  (prio: -3) initial program counter (leads to first command to execute) */
    ISR_error,              /*  02 (0x00000008)  (prio: -2) non-maskable interrupt */
    ISR_error,              /*  03 (0x0000000C)  (prio: -1) hard fault exception */
    ISR_error,              /*  04 (0x00000010)  memory management */
    ISR_error,              /*  05 (0x00000014)  bus fault - pre-fetch fault, memory access fault */
    ISR_error,              /*  06 (0x00000018)  usage fault - undefined instruction or illegal state */
    ISR_error,              /*  07 (0x0000001C)  reserved vector 7 */
    ISR_error,              /*  08 (0x00000020)  reserved vector 8 */
    ISR_error,              /*  09 (0x00000024)  reserved vector 9 */
    ISR_error,              /*  10 (0x00000028)  reserved vector 10 */
    ISR_error,              /*  11 (0x0000002C)  system service call via SWI instruction */
    ISR_error,              /*  12 (0x00000030)  monitor */
    ISR_error,              /*  13 (0x00000034)  reserved vector 13 */
    ISR_error,              /*  14 (0x00000038)  pendable service call exception  */
    ISR_error,              /*  15 (0x0000003C)  SysTick exception */
	/* --- non-core vectors --- */
	ISR_default,            /*   0 (0x00000040)  window watchdog interrupt */
	ISR_default,            /*   1 (0x00000044)  PVD through EXTI line 16 interrupt */
	ISR_default,            /*   2 (0x00000048)  RTC/TAMP/CSS on LSE through EXTI line 19 interrupt */
	ISR_default,            /*   3 (0x0000004C)  RTC Wakeup timer through EXTI line 20 interrupt */
	ISR_default,            /*   4 (0x00000050)  Flash global interrupt */
	ISR_default,            /*   5 (0x00000054)  RCC global interrupt */
	ISR_default,            /*   6 (0x00000058)  EXTI Line 0 interrupt */
	ISR_default,            /*   7 (0x0000005C)  EXTI Line 1 interrupt */
	ISR_default,            /*   8 (0x00000060)  EXTI Line 2 interrupt */
	ISR_default,            /*   9 (0x00000064)  EXTI Line 3 interrupt */
	ISR_default,            /*  10 (0x00000068)  EXTI Line 4 interrupt */
	ISR_default,            /*  11 (0x0000006C)  DMA1 channel 1 interrupt */
	ISR_default,            /*  12 (0x00000070)  DMA1 channel 2 interrupt */
	ISR_default,            /*  13 (0x00000074)  DMA1 channel 3 interrupt */
	ISR_default,            /*  14 (0x00000078)  DMA1 channel 4 interrupt */
	ISR_default,            /*  15 (0x0000007C)  DMA1 channel 5 interrupt */
	ISR_default,            /*  16 (0x00000080)  DMA1 channel 6 interrupt */
	ISR_default,            /*  17 (0x00000084)  DMA1 channel 7 interrupt */
	ISR_default,            /*  18 (0x00000088)  ADC1 + ADC2 global interrupt */
	ISR_default,            /*  19 (0x0000008C)  USB high priority interrupts */
	ISR_default,            /*  20 (0x00000090)  USB low priority interrupts */
	ISR_default,            /*  21 (0x00000094)  FDCAN1 interrupt 0 */
	ISR_default,            /*  22 (0x00000098)  FDCAN1 interrupt 1 */
	ISR_default,            /*  23 (0x0000009C)  EXTI line [9:5] interrupts */
	ISR_default,            /*  24 (0x000000A0)  TIM1 break + TIM15 global interrupts */
	ISR_default,            /*  25 (0x000000A4)  TIM1 update + TIM16 global interrupts */
	ISR_default,            /*  26 (0x000000A8)  TIM1 trigger, commutation, direction change, index  + TIM17 interrupts */
	ISR_default,            /*  27 (0x000000AC)  TIM1 capture compare interrupt */
	ISR_default,            /*  28 (0x000000B0)  TIM2 global interrupt */
	ISR_default,            /*  29 (0x000000B4)  TIM3 global interrupt */
	ISR_default,            /*  30 (0x000000B8)  TIM4 global interrupt */
	ISR_default,            /*  31 (0x000000BC)  I2C1 event + EXTI line 23 interrupts */
    ISR_default,            /*  32 (0x000000C0)  I2C1 error interrupt */
    ISR_default,            /*  33 (0x000000C4)  I2C2 event + EXTI line 24 interrupts */
    ISR_default,            /*  34 (0x000000C8)  I2C2 error interrupt */
    ISR_default,            /*  35 (0x000000CC)  SPI1 global interrupt */
    ISR_default,            /*  36 (0x000000D0)  SPI2 global interrupt */
    ISR_default,            /*  37 (0x000000D4)  USART1 global + EXTI line 25 interrupts */
    ISR_default,            /*  38 (0x000000D8)  USART2 global + EXTI line 26 interrupts */
    ISR_default,            /*  39 (0x000000DC)  USART3 global + EXTI line 28 interrupts */
    ISR_default,            /*  40 (0x000000E0)  EXTI line [15:10] interrupts */
    ISR_default,            /*  41 (0x000000E4)  RTC alarms interrupts */
    ISR_default,            /*  42 (0x000000E8)  USB wakeup from suspend trough EXTI line 18 interrupt */
    ISR_default,            /*  43 (0x000000EC)  TIM8 break, transition error, index error interrupts */
    ISR_default,            /*  44 (0x000001F0)  TIM8 update interrupt */
    ISR_default,            /*  45 (0x000001F4)  TIM8 trigger, commutation, direction change, index interrupts */
    ISR_default,            /*  46 (0x000001F8)  TIM8 capture compare interrupt */
    ISR_default,            /*  47 (0x000001FC)  ADC3 global interrupt */
    ISR_default,            /*  48 (0x00000100)  FSMC global interrupt */
    ISR_default,            /*  49 (0x00000104)  LPTIM1 global interrupt */
    ISR_default,            /*  50 (0x00000108)  TIM5 global interrupt */
    ISR_default,            /*  51 (0x0000010C)  SPI3 global interrupt */
    ISR_default,            /*  52 (0x00000110)  UART4 global + EXTI line 34 interrupts */
    ISR_default,            /*  53 (0x00000114)  UART5 global + EXTI line 35 interrupts */
    ISR_default,            /*  54 (0x00000118)  TIM6 + DAC1/3 underrun global interrupts */
    ISR_default,            /*  55 (0x0000011C)  TIM7 + DAC2/4 underrun global interrupts */
    ISR_default,            /*  56 (0x00000120)  DMA2 channel 1 interrupt */
    ISR_default,            /*  57 (0x00000124)  DMA2 channel 2 interrupt */
    ISR_default,            /*  58 (0x00000128)  DMA2 channel 3 interrupt */
    ISR_default,            /*  59 (0x0000012C)  DMA2 channel 4 interrupt */
    ISR_default,            /*  60 (0x00000130)  DMA2 channel 5 interrupt */
    ISR_default,            /*  61 (0x00000134)  ADC4 global interrupt */
    ISR_default,            /*  62 (0x00000138)  ADC5 global interrupt */
    ISR_default,            /*  63 (0x0000013C)  UCPD1 global + EXTI line 43 interrupts */
    ISR_default,            /*  64 (0x00000140)  COMP1/COMP2/COMP3 through EXTI lines 21/22/29 interrupts */
    ISR_default,            /*  65 (0x00000144)  COMP4/COMP5/COMP6 through EXTI lines 30/31/32 interrupts */
    ISR_default,            /*  66 (0x00000148)  COMP7 through EXTI line 33 interrupt */
    ISR_default,            /*  67 (0x0000014C)  HRTIM master timer interrupt (hrtim_it1) */
    ISR_default,            /*  68 (0x00000150)  HRTIM timer A interrupt (hrtim_it2) */
    ISR_default,            /*  69 (0x00000154)  HRTIM timer B interrupt (hrtim_it3) */
    ISR_default,            /*  70 (0x00000158)  HRTIM timer C interrupt (hrtim_it4) */
    ISR_default,            /*  71 (0x0000015C)  HRTIM timer D interrupt (hrtim_it5) */
    ISR_default,            /*  72 (0x00000160)  HRTIM timer E interrupt (hrtim_it6) */
    ISR_default,            /*  73 (0x00000164)  HRTIM fault interrupt (hrtim_it8) */
    ISR_default,            /*  74 (0x00000168)  HRTIM timer F interrupt (hrtim_it7) */
    ISR_default,            /*  75 (0x0000016C)  CRS interrupt */
    ISR_default,            /*  76 (0x00000170)  SAI */
    ISR_default,            /*  77 (0x00000174)  TIM20 break, transition error, index error interrupts */
    ISR_default,            /*  78 (0x00000178)  TIM20 update interrupt */
    ISR_default,            /*  79 (0x0000017C)  TIM20 trigger, commutation, direction change, index interrupts */
    ISR_default,            /*  80 (0x00000180)  TIM20 capture compare interrupt */
    ISR_default,            /*  81 (0x00000184)  Floating point interrupt */
    ISR_default,            /*  82 (0x00000188)  I2C4 event + EXTI line 4 interrupts */
    ISR_default,            /*  83 (0x0000018C)  I2C4 error interrupt */
    ISR_default,            /*  84 (0x00000190)  SPI4 global interrupt */
    ISR_default,            /*  85 (0x00000194)  AES global interrupt */
    ISR_default,            /*  86 (0x00000198)  FDCAN2 interrupt 0 */
    ISR_default,            /*  87 (0x0000019C)  FDCAN2 interrupt 1 */
    ISR_default,            /*  88 (0x000001A0)  FDCAN3 interrupt 0 */
    ISR_default,            /*  89 (0x000001A4)  FDCAN3 interrupt 1 */
    ISR_default,            /*  90 (0x000001A8)  RNG global interrupt */
    ISR_default,            /*  91 (0x000001AC)  LPUART global interrupt */
    ISR_default,            /*  92 (0x000001B0)  I2C3 event + EXTI line 27 interrupts */
    ISR_default,            /*  93 (0x000001B4)  I2C3 error interrupt */
    ISR_default,            /*  94 (0x000001B8)  DMAMUX overrun interrupt */
    ISR_default,            /*  95 (0x000001BC)  QUADSPI global interrupt */
    ISR_default,            /*  96 (0x000001C0)  DMA1 channel 8 interrupt */
    ISR_default,            /*  97 (0x000001C4)  DMA2 channel 6 interrupt */
    ISR_default,            /*  98 (0x000001C8)  DMA2 channel 7 interrupt */
    ISR_default,            /*  99 (0x000001CC)  DMA2 channel 8 interrupt */
    ISR_default,            /* 100 (0x000001D0)  Cordic interrupt */
    ISR_default             /* 101 (0x000001D4)  FMAC interrupt */
};


/* ************************************ E O F ***************************************** */
