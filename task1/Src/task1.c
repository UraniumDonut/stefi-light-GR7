/* ***************************************************************************************
 *  Project:    task1 - running LED with key control
 *  File:       task1.c
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
 *  Status:     under development
 *
 *  Description:
 *          Blinks the red LED of STefi Light, currently.
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
#define LOOPS_PER_MS    622             // NOP-loops for delay()
#define WAITTIME        666


/* ------------------------------------ TYPE DEFINITIONS ------------------------------ */
/* ------------------------------------ GLOBAL VARIABLES ------------------------------ */
int shouldbeon;
int buttonbefore;

/* ------------------------------------ PRIVATE VARIABLES ----------------------------- */


/* ------------------------------------ PROTOTYPES ------------------------------------ */
static void GPIO_init(void);
static void delay(const uint16_t ms);
static void delayws(const uint16_t ms);
int lauflicht(void);
int read2(void);
void statecheck(void);

/* ------------------------------------ M A I N --------------------------------------- */
int main(void)
{
    /* --- initialization --- */
    __disable_irq();        // disable interrupts globally

    GPIO_init();

    __enable_irq();         // enable interrupts globally


    /* --- one time tasks --- */


    /* --- infinite processing loop --- */
    while (1)
    {
        /* ... Main Loop ... */
    	if(shouldbeon){
    		lauflicht();
    	}
    	statecheck();

    }

    return 1;
}

int lauflicht(void){
	GPIOA->ODR ^= MASK_LED_RED; 		//LED Anschalten
	delayws(WAITTIME);					//Warten
	GPIOA->ODR ^= MASK_LED_RED;			//LED Abschalten
	if(!shouldbeon){return 1;}				//Prüfen, ob Schalter gedrückt ist
	GPIOA->ODR ^= MASK_LED_YELLOW;		//...
	delayws(WAITTIME);
	GPIOA->ODR ^= MASK_LED_YELLOW;
	if(!shouldbeon){return 1;}
	GPIOA->ODR ^= MASK_LED_GREEN;
	delayws(WAITTIME);
	GPIOA->ODR ^= MASK_LED_GREEN;
	if(!shouldbeon){return 1;}
	GPIOA->ODR ^= MASK_LED_BLUE;
	delayws(WAITTIME);
	GPIOA->ODR ^= MASK_LED_BLUE; 		//Richtungswechsel
	if(!shouldbeon){return 1;}
	GPIOA->ODR ^= MASK_LED_GREEN;
	delayws(WAITTIME);
	GPIOA->ODR ^= MASK_LED_GREEN;
	if(!shouldbeon){return 1;}
	GPIOA->ODR ^= MASK_LED_YELLOW;
	delayws(WAITTIME);
	GPIOA->ODR ^= MASK_LED_YELLOW;
	return 1;
}

int read2(void){
	int is_on;
	is_on = GPIOB->IDR;				//Taster S2 Abfragen
	is_on = (is_on & (1<<5));		//Bitmaske, um S2 Wert zu isolieren und auf Stelle 0 zu bewegen
	is_on = is_on>>5;
	return !is_on;					//invertieren, da LOW-Aktiv

}

void statecheck(void){
	int now = read2();
	if(now && buttonbefore != now){
		if(shouldbeon){
			shouldbeon = 0;
			delay(50);
			//while(read2()){}
		}
		else if(buttonbefore != now){
			shouldbeon = 1;
			delay(50);
			//while(read2()){}
		}
	}
	buttonbefore = now;
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

    /* --- LEDs --- */
    GPIOA->ODR |= MASK_LED_RED;
    GPIOA->MODER &= ~(3 << 0);
    GPIOA->MODER |= (1 << 0);               // set LED 0 pin (PA0) to output

    GPIOA->ODR |= MASK_LED_YELLOW;
    GPIOA->MODER &= ~(3 << 2);
    GPIOA->MODER |= (1 << 2);               // set LED 1 pin (PA1) to output

    GPIOA->ODR |= MASK_LED_GREEN;
    GPIOA->MODER &= ~(3 << 4);
    GPIOA->MODER |= (1 << 4);               // set LED 2 pin (PA2) to output

    GPIOA->ODR |= MASK_LED_BLUE;
    GPIOA->MODER &= ~(3 << 6);
    GPIOA->MODER |= (1 << 6);               // set LED 3 pin (PA3) to output

    //GPIOB->ODR |= MASK_S2;
    GPIOB->MODER &= ~(3 << 10);             // set Button 2 pin (PB5) to input
    GPIOB->PUPDR &= ~(3 << 10);				//PULL-UP
    GPIOB->PUPDR |=  (1 << 10);
}


/* ------------------------------------------------------------------------------------ *\
 * method:  static void delay(const uint16_t ms)
 *
 * Realizes a millisecond delay by very bad busy-wait.
 *
 * requires:    - nothing -
 * parameters:  ms - delay time in milliseconds
 * returns:     - nothing -
\* ------------------------------------------------------------------------------------ */
static void delay(const uint16_t ms)
{

    for (uint16_t i = 0; i < ms; ++i)
    {
        for (uint16_t j = 0; j < LOOPS_PER_MS; ++j)
        {
            __asm("NOP");
        }
    }
}

static void delayws(const uint16_t ms)
{

    for (uint16_t i = 0; i < ms; ++i)
    {
    	statecheck();
        for (uint16_t j = 0; j < LOOPS_PER_MS; ++j)
        {
            __asm("NOP");
        }
    }
}


/* ************************************ E O F ***************************************** */
