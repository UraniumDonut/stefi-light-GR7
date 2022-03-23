#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Project:      task3 - switch triggered LEDs (interrupts)
# File:         makefile
# 
# Language:     make
#
# Hardware:     STefi Light v1.1
# Processor:    STM32G431KBT6U
#
# Author:       Flaviu Popp-Nowak, Manuel Lederhofer
# Datum:        00.12.2013
#
# Version:      5.0
# History:
#       18.12.2013  FPN	initial version
#       11.07.2014  ML  switch to GNU ARM toolchain, add output files, nicify code
#       21.10.2014  ML  add path entries for testing with Sourcery CodeBench toolchain
#		28.01.2015	ML	changed naming of list files
#		29.09.2015	ML	changed GCCDIR to Freescale KDS toolchain
#       27.09.2016  HL  changed GCCDIR to KDS 3.2 toolchain
#		07.12.2018	ML	remove unnecessary inactive paths and variables
#		18.12.2018	ML	port from MKL05Z32VLC4 (KDS) to STM32L476RG (sw4stm)
#		13.03.2019	ML	move gcc and make path to poject properties 
#		29.09.2021  ML  port from STM32L476RG/STM32F411xE to STM32F042K6T6
#       09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
#
# Status:       working
#  
# Description:
#       Default makefile for this project.
#    
# Notes:
#       - / - 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#--------- general config ----------------------------------------------------------------

TOOLPREFIX  = arm-none-eabi

AS       = $(TOOLPREFIX)-as
LD       = $(TOOLPREFIX)-ld
SIZE	 = $(TOOLPREFIX)-size
OBJDUMP  = $(TOOLPREFIX)-objdump

RM		 = rm -rf


#--------- specific config ---------------------------------------------------------------

TARGET    = task3
ARMCPU    = cortex-m4

#GCCFLAGS  = -O0 -g3 -Wall -c -fmessage-length=0 -mabi=aapcs -mthumb -msoft-float --save-temps -fverbose-asm
#ASFLAGS   = -specs=nosys.specs
ASFLAGS   = -march=armv7-m -mcpu=$(ARMCPU) -adglns -g3 -mthumb --warn 
LDFLAGS   = -g -Map $(@:%.elf=%.map) --cref -static
LDSCRIPT  = ldscript_rom.ld
OBJDFLAGS = -htdr -j .text -j .data -j .bss -j .vectortable -j .exhand

RMFILES   = *.elf *.o *.lst *.map *.als


#--------- machine room ------------------------------------------------------------------

all: $(TARGET).elf makefile $(LDSCRIPT)
	@echo Target '$@' ready

$(TARGET).elf: $(TARGET).o
	$(LD) -o $@ -T $(LDSCRIPT) $< $(LDFLAGS)
	$(OBJDUMP) $(OBJDFLAGS) $@ > $(@:%.elf=%.lst)
	$(SIZE) $@

$(TARGET).o: $(TARGET).s G431_addr.s
	$(AS) -o $@ $< $(ASFLAGS) > $(@:%.o=%.als)

clean:
	@-$(RM) $(wildcard $(RMFILES))


.PHONY: clean


#'''''''''''''''''''''''''''''''''''''' E O F '''''''''''''''''''''''''''''''''''''''''''# 
