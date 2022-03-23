/* ***************************************************************************************
 *  Project:    task2 - switch triggered LEDs
 *  File:       ldscript_rom.ld
 *
 *  Language:   ld
 *
 *  Hardware:   STefi Light v1.1
 *  Processor:  STM32G431KBT6U
 *
 *  Author:     Manuel Lederhofer
 *  Datum:      31.10.2014
 *
 *  Version:    6.0
 *  History:
 *      31.10.2014  ML  create file for Kinetis tower
 *      22.07.2015  ML  change MEMORY to switch from MK60N512VMD100 to MKL05Z32VLC4
 *      05.12.2018  ML  port from MKL05Z32VLC4 to STM32L476RG
 *                          remove PROTECT area, fit MEMORY regions
 *      25.09.2019  ML  change PGM memory base from 0x08002000 to 0x08000400
 *      04.09.2020  HL  port from STM32L476RG to STM32F411xE
 *      29.09.2021  ML  port from STM32F411xE to STM32F042K6T6
 *      09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
 *
 *  Status:     working
 *
 *  Description:
 *      Linker script for the STefi Light in MCT lab exercises.
 *
 *  Notes:
 *      The G431 incorporates three types of memory:
 *          - 128K flash    @ 0x08000000
 *          -  32K SRAM     @ SRAM1 (16K): 0x20000000, SRAM2 (6K): 0x20004000
 *          -  10K CCMSRAM  @ 0x10000000 || 0x20005800
 ************************************************************************************** */
 
MEMORY 
{
        IVECS   (R)     : ORIGIN = 0x08000000, LENGTH = 0x000001D8
        PGM     (RX)    : ORIGIN = 0x08000400, LENGTH = 0x00000C00
        EXHANDS (RX)    : ORIGIN = 0x08001000, LENGTH = 0x00000400
        RAM     (RW)    : ORIGIN = 0x20000000, LENGTH = 0x00001800
}

SECTIONS
{
    .vectortable : 
    {
        . = ALIGN(4);
        KEEP(*(.vectortable)) 
        . = ALIGN(4); 
    } > IVECS
            
    .text : 
    {
        *(.text) 
    } > PGM

    .exhand : 
    {
        *(.exhand)
    } > EXHANDS
}


/* ************************************ E O F ***************************************** */