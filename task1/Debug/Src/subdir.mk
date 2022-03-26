################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (9-2020-q2-update)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Src/task1.c \
../Src/task1_it.c 

OBJS += \
./Src/task1.o \
./Src/task1_it.o 

C_DEPS += \
./Src/task1.d \
./Src/task1_it.d 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o: ../Src/%.c Src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DSTM32G431KBTx -DSTM32 -DSTM32G4 -DNUCLEO_G431KB -c -I../Inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Src

clean-Src:
	-$(RM) ./Src/task1.d ./Src/task1.o ./Src/task1_it.d ./Src/task1_it.o

.PHONY: clean-Src

