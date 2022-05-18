/* ***************************************************************************************
 *  Project:    task4 - timer and interrupts
 *  File:       task4.c
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
 *		10.09.2021  ML  create project; based upon task1
 *      09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
 *
 *  Status:     under development
 *
 *  Description:
 *          Blinks the red LED of STefi Light very fast, currently.
 *          This file contains the main routine and the initialization.
 *
 *  Notes:
 *      - MCU speed at startup is 16 MHz
 *
 *  Todo:
 *      - Change the example code to match the description and requirements
 *          of the requested application in the lab exercise guide.
 *
 ************************************************************************************** */

/* ------------------------------------ INCLUDES -------------------------------------- */
#include "stm32g431xx.h"
#include "STefi-Light.h"


/* ------------------------------------ DEFINES --------------------------------------- */
/* ------------------------------------ TYPE DEFINITIONS ------------------------------ */
/* ------------------------------------ GLOBAL VARIABLES ------------------------------ */
/* ------------------------------------ PRIVATE VARIABLES ----------------------------- */


/* ------------------------------------ PROTOTYPES ------------------------------------ */
static void GPIO_init(void);


/* ------------------------------------ M A I N --------------------------------------- */
int main(void)
{
    /* --- initialization --- */
    __disable_irq();        // disable interrupts globally

    GPIO_init();
    //SysTick->

    __enable_irq();         // enable interrupts globally


    /* --- one time tasks --- */


    /* --- infinite processing loop --- */
    while (1)
    {


    }

    return 1;
}


/* ------------------------------------ GLOBAL FUNCTIONS ------------------------------ */


/* ------------------------------------ PRIVATE FUNCTIONS ----------------------------- */

/* ------------------------------------------------------------------------------------ *\
 * method:  static void GPIO_init(void)
 *
 * Initializes GPIOs on STefi Light for pins with peripherals attached.
 *
 * requires:    - nothing -
 * parameters:  - none -
 * returns:     - nothing -
\* ------------------------------------------------------------------------------------ */
static void GPIO_init(void)
{
    /* enable port clocks */
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;    // LEDs: A
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOBEN;    // Buttons: B
    RCC->APB2ENR |= 1;						// Multiplexer Takt


    /* --- LEDs --- */
    GPIOA->ODR |= MASK_LED_RED;
    GPIOA->MODER &= ~(3 << 0);
    GPIOA->MODER |= (1 << 0);               // set LED pin to output

    GPIOA->ODR |= MASK_LED_YELLOW;
    GPIOA->MODER &= ~(3 << 2);
    GPIOA->MODER |= (1 << 2);               // set LED 1 pin (PA1) to output

    GPIOA->ODR |= MASK_LED_GREEN;
    GPIOA->MODER &= ~(3 << 4);
    GPIOA->MODER |= (1 << 4);               // set LED 2 pin (PA2) to output

    GPIOA->ODR |= MASK_LED_BLUE;
    GPIOA->MODER &= ~(3 << 6);
    GPIOA->MODER |= (1 << 6);               // set LED 3 pin (PA3) to output

    GPIOB->IDR |= MASK_S1;
    GPIOB->MODER &= ~(3 << 8);

    GPIOB->IDR |= MASK_S2;
    GPIOB->MODER &= ~(3 << 10);

    GPIOB->PUPDR &= ~(3 << 8);
    GPIOB->PUPDR |= (1 << 8);

    GPIOB->PUPDR &= ~(3 << 10);
    GPIOB->PUPDR |= (1 << 10);

    SysTick->LOAD = 0xCAF;				// 1hz 755554, 2hz 3AAAAA, 4hz 1D5555, 8hz EAAAA, 1024hz CAF
    SysTick->VAL = 0;
    SysTick->CTRL = 0x07;

    SYSCFG->EXTICR[1] |= (1 << 0);
    SYSCFG->EXTICR[1] |= (1 << 4);


    EXTI->IMR1 |= (3 << 4);
    EXTI->FTSR1 |= (3 << 4);



    NVIC->ISER[0] |= (1 << 10);
    NVIC->ISER[0] |= (1 << 23);
    NVIC->ICPR[0] |= (1 << 10);
    NVIC->ICPR[0] |= (1 << 23);
}


/* ************************************ E O F ***************************************** */
