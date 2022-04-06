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
int shouldbeon;							//shouldbeon controls, weather the lights should be running at the moment
int buttonbefore;						//Buttonbefore is used for checking not for state but for changes of button state

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
    	if(shouldbeon){
    		lauflicht();		//run the lights if shey should be running
    	}
    	statecheck();

    }

    return 1;
}



/* ------------------------------------ GLOBAL FUNCTIONS ------------------------------ */
int lauflicht(void){
	GPIOA->ODR ^= MASK_LED_RED; 		//LED on
	delayws(WAITTIME);					//Wait and poll Button
	GPIOA->ODR ^= MASK_LED_RED;			//LED on
	if(!shouldbeon){return 1;}			//Check if lights should be running
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
	GPIOA->ODR ^= MASK_LED_BLUE; 		//Change of directions
	if(!shouldbeon){return 1;}
	GPIOA->ODR ^= MASK_LED_GREEN;
	delayws(WAITTIME);
	GPIOA->ODR ^= MASK_LED_GREEN;
	if(!shouldbeon){return 1;}
	GPIOA->ODR ^= MASK_LED_YELLOW;
	delayws(WAITTIME);
	GPIOA->ODR ^= MASK_LED_YELLOW;
	return 0;
}

int read2(void){
	int is_on = GPIOB->IDR;				//Load button S2 into memory
	return !((is_on & (1<<5))>>5);		//Bitmaske, um S2 Wert zu isolieren und auf Stelle 0 zu bewegen invertieren, da LOW-Aktiv
}

void statecheck(void){					//Statecheck checks for changes in the Button
	int now = read2();
	if(now && buttonbefore != now){
		if(shouldbeon){
			shouldbeon = 0;
			delay(75);					//The delay debounces the button S2, so statecheck does not run again, if a change was detected
		}
		else if(buttonbefore != now){
			shouldbeon = 1;
			delay(75);
		}
	}
	buttonbefore = now;
}


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
    /* enable port clocks*/
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
    GPIOB->PUPDR &= ~(3 << 10);				// PULL-UP
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
static void delay(const uint16_t ms) //regular delay function
{

    for (uint16_t i = 0; i < ms; ++i)
    {
        for (uint16_t j = 0; j < LOOPS_PER_MS; ++j)
        {
            __asm("NOP");
        }
    }
}

static void delayws(const uint16_t ms) //delay with statecheck function
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
