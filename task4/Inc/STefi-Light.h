/* ***************************************************************************************
 *  Project:    task4
 *  File:       STefi-Light.h
 *
 *  Language:   C
 *
 *  Hardware:   STefi Light v1.1
 *  Processor:  STM32F042K6 / STM32G431KBT6U
 *
 *  Author:     Manuel Lederhofer
 *  Datum:      30.07.2021
 *
 *  Version:    1.1
 *  History:
 *      30.07.2021  ML  create file
 *      09.03.2022  ML  check G431 compatibility
 *
 *  Status:     working
 *
 *  Description:
 *          Definitions and declarations related to STefi Light board hardware
 *          extended by application related elements.
 *
 *
 *  Notes:
 *          Default MCU speed at startup is:
 *          - F042 = 8 MHz
 *          - G431 = 16 MHz
 *
 *  ToDo:
 *      - none -
 ************************************************************************************** */
#ifndef STEFI_LIGHT_H_
#define STEFI_LIGHT_H_
/* ==================================================================================== */

/* ------------------------------------ INCLUDES -------------------------------------- */


/* ------------------------------------ DEFINES --------------------------------------- */

/* --- STefi peripherals related definitions --- */

// LEDs
#define MASK_LED0           (1 << 0)
#define MASK_LED1           (1 << 1)
#define MASK_LED2           (1 << 2)
#define MASK_LED3           (1 << 3)

#define MASK_LED_RED        (MASK_LED0)
#define MASK_LED_YELLOW     (MASK_LED1)
#define MASK_LED_GREEN      (MASK_LED2)
#define MASK_LED_BLUE       (MASK_LED3)
#define MASK_LED_ALL        (MASK_LED_RED | MASK_LED_YELLOW | MASK_LED_GREEN | MASK_LED_BLUE)


// buttons
#define MASK_S0         (1 << 0)
#define MASK_S1         (1 << 4)
#define MASK_S2         (1 << 5)
#define MASK_S3         (1 << 7)

#define MASK_KEY0       (MASK_S0)
#define MASK_KEY1       (MASK_S1)
#define MASK_KEY2       (MASK_S2)
#define MASK_KEY3       (MASK_S3)


/* --- STefi MCU related definitions --- */

/* --- application related definitions --- */

/* ------------------------------------ TYPE DEFINITIONS ------------------------------ */
/* ------------------------------------ GLOBAL VARIABLES ------------------------------ */
/* ------------------------------------ PROTOTYPES ------------------------------------ */
/* ------------------------------------ GLOBAL FUNCTIONS ------------------------------ */

/* ==================================================================================== */
#endif /* STEFI_LIGHT_H_ */
/* ************************************ E O F ***************************************** */
