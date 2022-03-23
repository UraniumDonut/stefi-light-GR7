#*****************************************************************************************
#   Project:    task3 - switch triggered LEDs (interrupts)
#   File:       G431_addr.s
#
#   Language:   ASM
#
#   Hardware:   STefi v1.1
#   Processor:  STM32G431KBT6U
#
#   Author:     Manuel Lederhofer
#   Datum:      20.08.2015
#
#   Version:    3.0
#   History:
#       20.08.2015  ML  create file
#       07.12.2018  ML  port from MKL05Z32VLC4 to STM32L476RG
#       27.02.2019  ML  change from absolute addresses to BASE + OFFSET notation and
#                           add more timer modules
#       09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
#
#   Status:     working
#
#   Description:
#       Connects assembly addresses for STM32G431 MCU to symbolic register names
#       used in the datasheets.
#
#   Notes:
#       - default MCU speed at startup is 16 MHz.
#
#   ToDo:
#       - none -
#*****************************************************************************************


#----------------------------------------------------------------------------------------#
#   MCU Bus Base Addresses
#----------------------------------------------------------------------------------------#

    .equ    APB1_BASE,              0x40000000
    .equ    APB2_BASE,              0x40010000
    .equ    AHB1_BASE,              0x40020000
    .equ    AHB2_BASE,              0x48000000
    .equ    AHB3_BASE,              0xA0000000  //!!! FSMC + QSPI registers = AHB3 ?
    .equ    PPB_BASE,               0xE0000000  /* Cortex M4 with FPU Internal Peripherals */

#----------------------------------------------------------------------------------------#
#   System Configuration Controller
#
#   address space:  0x4001_0000 .. 0x4001_0029
#----------------------------------------------------------------------------------------#

    .equ    SYSCFG_BASE,            APB2_BASE

    .equ    SYSCFG_MEMRMP,          SYSCFG_BASE + 0x00
    .equ    SYSCFG_CFGR1,           SYSCFG_BASE + 0x04
    .equ    SYSCFG_EXTICR1,         SYSCFG_BASE + 0x08
    .equ    SYSCFG_EXTICR2,         SYSCFG_BASE + 0x0C
    .equ    SYSCFG_EXTICR3,         SYSCFG_BASE + 0x10
    .equ    SYSCFG_EXTICR4,         SYSCFG_BASE + 0x14
    .equ    SYSCFG_SCSR,            SYSCFG_BASE + 0x18
    .equ    SYSCFG_CFGR2,           SYSCFG_BASE + 0x1C
    .equ    SYSCFG_SWPR,            SYSCFG_BASE + 0x20
    .equ    SYSCFG_SKR,             SYSCFG_BASE + 0x24

#----------------------------------------------------------------------------------------#
#   Extended Interrupts And Events Controller
#
#   address space:  0x4001_0400 .. 0x4001_07FF
#----------------------------------------------------------------------------------------#

    .equ    EXTI_BASE,              APB2_BASE + 0x400

    .equ    EXTI_IMR1,              EXTI_BASE + 0x00
    .equ    EXTI_EMR1,              EXTI_BASE + 0x04
    .equ    EXTI_RTSR1,             EXTI_BASE + 0x08
    .equ    EXTI_FTSR1,             EXTI_BASE + 0x0C
    .equ    EXTI_SWIER1,            EXTI_BASE + 0x10
    .equ    EXTI_PR1,               EXTI_BASE + 0x14

    .equ    EXTI_IMR2,              EXTI_BASE + 0x20
    .equ    EXTI_EMR2,              EXTI_BASE + 0x24
    .equ    EXTI_RTSR2,             EXTI_BASE + 0x28
    .equ    EXTI_FTSR2,             EXTI_BASE + 0x2C
    .equ    EXTI_SWIER2,            EXTI_BASE + 0x30
    .equ    EXTI_PR2,               EXTI_BASE + 0x34

#----------------------------------------------------------------------------------------#
#   TIM module common configuration
#
#   Every timer has 1 KB address space:
#
#   TIM2 .. TIM7:   0x4000_0000 .. 0x4000_17FF (APB1)
#   TIM1:           0x4001_2C00 .. 0x4001_2FFF (APB2)
#   TIM8:           0x4001_3400 .. 0x4001_37FF (APB2)
#   TIM15 .. TIM17: 0x4001_4000 .. 0x4001_4BFF (APB2)
#   TIM20:          0x4001_5000 .. 0x4001_53FF (APB2)
#
#   note:
#       TIM2 + TIM5 are 32 bit timers. All others have a width of 16 bit.
#       Below, the timers on one line share a common register set description.
#
#       TIM 1, 8, 20    advances control timers
#       TIM 2, 3, 4, 5  general purpose timers  (TIM2/5 = 32 bit)
#       TIM 15          general purpose timers
#       TIM 16, 17      general purpose timers
#       TIM 6, 7        basic timers
#----------------------------------------------------------------------------------------#

    .equ    TIM_CR1_OFFSET,         0x00
    .equ    TIM_CR2_OFFSET,         0x04
    .equ    TIM_SMCR_OFFSET,        0x08
    .equ    TIM_DIER_OFFSET,        0x0C
    .equ    TIM_SR_OFFSET,          0x10
    .equ    TIM_EGR_OFFSET,         0x14
    .equ    TIM_CCMR1_OFFSET,       0x18
    .equ    TIM_CCMR2_OFFSET,       0x1C
    .equ    TIM_CCER_OFFSET,        0x20
    .equ    TIM_CNT_OFFSET,         0x24
    .equ    TIM_PSC_OFFSET,         0x28
    .equ    TIM_ARR_OFFSET,         0x2C
    .equ    TIM_RCR_OFFSET,         0x30
    .equ    TIM_CCR1_OFFSET,        0x34
    .equ    TIM_CCR2_OFFSET,        0x38
    .equ    TIM_CCR3_OFFSET,        0x3C
    .equ    TIM_CCR4_OFFSET,        0x40
    .equ    TIM_BDTR_OFFSET,        0x44
    .equ    TIM_CCR5_OFFSET,        0x48
    .equ    TIM_CCR6_OFFSET,        0x4C
    .equ    TIM_CCMR3_OFFSET,       0x50
    .equ    TIM_DTR2_OFFSET,        0x54
    .equ    TIM_ECR_OFFSET,         0x58
    .equ    TIM_TISEL_OFFSET,       0x5C
    .equ    TIM_AF1_OFFSET,         0x60
    .equ    TIM_AF2_OFFSET,         0x64
    .equ    TIM_OR1_OFFSET,         0x68

    .equ    TIM_DCR_OFFSET,         0x3DC
    .equ    TIM_DMAR_OFFSET,        0x3E0

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

#--- Genral Purpose Timer - TIM2 / address space:  0x4000_0000 .. 0x4000_03FF

    .equ    TIM2_BASE,              APB1_BASE

    .equ    TIM2_CR1,               TIM2_BASE + TIM_CR1_OFFSET
    .equ    TIM2_CR2,               TIM2_BASE + TIM_CR2_OFFSET
    .equ    TIM2_SMCR,              TIM2_BASE + TIM_SMCR_OFFSET
    .equ    TIM2_DIER,              TIM2_BASE + TIM_DIER_OFFSET
    .equ    TIM2_SR,                TIM2_BASE + TIM_SR_OFFSET
    .equ    TIM2_EGR,               TIM2_BASE + TIM_EGR_OFFSET
    .equ    TIM2_CCMR1,             TIM2_BASE + TIM_CCMR1_OFFSET
    .equ    TIM2_CCMR2,             TIM2_BASE + TIM_CCMR2_OFFSET
    .equ    TIM2_CCER,              TIM2_BASE + TIM_CCER_OFFSET
    .equ    TIM2_CNT,               TIM2_BASE + TIM_CNT_OFFSET
    .equ    TIM2_PSC,               TIM2_BASE + TIM_PSC_OFFSET
    .equ    TIM2_ARR,               TIM2_BASE + TIM_ARR_OFFSET

    .equ    TIM2_CCR1,              TIM2_BASE + TIM_CCR1_OFFSET
    .equ    TIM2_CCR2,              TIM2_BASE + TIM_CCR2_OFFSET
    .equ    TIM2_CCR3,              TIM2_BASE + TIM_CCR3_OFFSET
    .equ    TIM2_CCR4,              TIM2_BASE + TIM_CCR4_OFFSET

    .equ    TIM2_ECR,               TIM2_BASE + TIM_ECR_OFFSET
    .equ    TIM2_TISEL,             TIM2_BASE + TIM_TISEL_OFFSET
    .equ    TIM2_AF1,               TIM2_BASE + TIM_ECR_OFFSET
    .equ    TIM2_AF2,               TIM2_BASE + TIM_ECR_OFFSET

    .equ    TIM2_DCR,               TIM2_BASE + TIM_DCR_OFFSET
    .equ    TIM2_DMAR,              TIM2_BASE + TIM_DMAR_OFFSET

#--- Genral Purpose Timer - TIM3 / address space:  0x4000_0400 .. 0x4000_07FF

    .equ    TIM3_BASE,              APB1_BASE + 0x400

    .equ    TIM3_CR1,               TIM3_BASE + TIM_CR1_OFFSET
    .equ    TIM3_CR2,               TIM3_BASE + TIM_CR2_OFFSET
    .equ    TIM3_SMCR,              TIM3_BASE + TIM_SMCR_OFFSET
    .equ    TIM3_DIER,              TIM3_BASE + TIM_DIER_OFFSET
    .equ    TIM3_SR,                TIM3_BASE + TIM_SR_OFFSET
    .equ    TIM3_EGR,               TIM3_BASE + TIM_EGR_OFFSET
    .equ    TIM3_CCMR1,             TIM3_BASE + TIM_CCMR1_OFFSET
    .equ    TIM3_CCMR2,             TIM3_BASE + TIM_CCMR2_OFFSET
    .equ    TIM3_CCER,              TIM3_BASE + TIM_CCER_OFFSET
    .equ    TIM3_CNT,               TIM3_BASE + TIM_CNT_OFFSET
    .equ    TIM3_PSC,               TIM3_BASE + TIM_PSC_OFFSET
    .equ    TIM3_ARR,               TIM3_BASE + TIM_ARR_OFFSET

    .equ    TIM3_CCR1,              TIM3_BASE + TIM_CCR1_OFFSET
    .equ    TIM3_CCR2,              TIM3_BASE + TIM_CCR2_OFFSET
    .equ    TIM3_CCR3,              TIM3_BASE + TIM_CCR3_OFFSET
    .equ    TIM3_CCR4,              TIM3_BASE + TIM_CCR4_OFFSET

    .equ    TIM3_ECR,               TIM3_BASE + TIM_ECR_OFFSET
    .equ    TIM3_TISEL,             TIM3_BASE + TIM_TISEL_OFFSET
    .equ    TIM3_AF1,               TIM3_BASE + TIM_ECR_OFFSET
    .equ    TIM3_AF2,               TIM3_BASE + TIM_ECR_OFFSET

    .equ    TIM3_DCR,               TIM3_BASE + TIM_DCR_OFFSET
    .equ    TIM3_DMAR,              TIM3_BASE + TIM_DMAR_OFFSET

#--- Genral Purpose Timer - TIM4 / address space:  0x4000_0800 .. 0x4000_0BFF

    .equ    TIM4_BASE,              APB1_BASE + 0x800

    .equ    TIM4_CR1,               TIM4_BASE + TIM_CR1_OFFSET
    .equ    TIM4_CR2,               TIM4_BASE + TIM_CR2_OFFSET
    .equ    TIM4_SMCR,              TIM4_BASE + TIM_SMCR_OFFSET
    .equ    TIM4_DIER,              TIM4_BASE + TIM_DIER_OFFSET
    .equ    TIM4_SR,                TIM4_BASE + TIM_SR_OFFSET
    .equ    TIM4_EGR,               TIM4_BASE + TIM_EGR_OFFSET
    .equ    TIM4_CCMR1,             TIM4_BASE + TIM_CCMR1_OFFSET
    .equ    TIM4_CCMR2,             TIM4_BASE + TIM_CCMR2_OFFSET
    .equ    TIM4_CCER,              TIM4_BASE + TIM_CCER_OFFSET
    .equ    TIM4_CNT,               TIM4_BASE + TIM_CNT_OFFSET
    .equ    TIM4_PSC,               TIM4_BASE + TIM_PSC_OFFSET
    .equ    TIM4_ARR,               TIM4_BASE + TIM_ARR_OFFSET

    .equ    TIM4_CCR1,              TIM4_BASE + TIM_CCR1_OFFSET
    .equ    TIM4_CCR2,              TIM4_BASE + TIM_CCR2_OFFSET
    .equ    TIM4_CCR3,              TIM4_BASE + TIM_CCR3_OFFSET
    .equ    TIM4_CCR4,              TIM4_BASE + TIM_CCR4_OFFSET

    .equ    TIM4_ECR,               TIM4_BASE + TIM_ECR_OFFSET
    .equ    TIM4_TISEL,             TIM4_BASE + TIM_TISEL_OFFSET
    .equ    TIM4_AF1,               TIM4_BASE + TIM_ECR_OFFSET
    .equ    TIM4_AF2,               TIM4_BASE + TIM_ECR_OFFSET

    .equ    TIM4_DCR,               TIM4_BASE + TIM_DCR_OFFSET
    .equ    TIM4_DMAR,              TIM4_BASE + TIM_DMAR_OFFSET

#--- Genral Purpose Timer - TIM5 / address space:  0x4000_0C00 .. 0x4000_0FFF

    .equ    TIM5_BASE,              APB1_BASE + 0xC00

    .equ    TIM5_CR1,               TIM5_BASE + TIM_CR1_OFFSET
    .equ    TIM5_CR2,               TIM5_BASE + TIM_CR2_OFFSET
    .equ    TIM5_SMCR,              TIM5_BASE + TIM_SMCR_OFFSET
    .equ    TIM5_DIER,              TIM5_BASE + TIM_DIER_OFFSET
    .equ    TIM5_SR,                TIM5_BASE + TIM_SR_OFFSET
    .equ    TIM5_EGR,               TIM5_BASE + TIM_EGR_OFFSET
    .equ    TIM5_CCMR1,             TIM5_BASE + TIM_CCMR1_OFFSET
    .equ    TIM5_CCMR2,             TIM5_BASE + TIM_CCMR2_OFFSET
    .equ    TIM5_CCER,              TIM5_BASE + TIM_CCER_OFFSET
    .equ    TIM5_CNT,               TIM5_BASE + TIM_CNT_OFFSET
    .equ    TIM5_PSC,               TIM5_BASE + TIM_PSC_OFFSET
    .equ    TIM5_ARR,               TIM5_BASE + TIM_ARR_OFFSET

    .equ    TIM5_CCR1,              TIM5_BASE + TIM_CCR1_OFFSET
    .equ    TIM5_CCR2,              TIM5_BASE + TIM_CCR2_OFFSET
    .equ    TIM5_CCR3,              TIM5_BASE + TIM_CCR3_OFFSET
    .equ    TIM5_CCR4,              TIM5_BASE + TIM_CCR4_OFFSET

    .equ    TIM5_ECR,               TIM5_BASE + TIM_ECR_OFFSET
    .equ    TIM5_TISEL,             TIM5_BASE + TIM_TISEL_OFFSET
    .equ    TIM5_AF1,               TIM5_BASE + TIM_ECR_OFFSET
    .equ    TIM5_AF2,               TIM5_BASE + TIM_ECR_OFFSET

    .equ    TIM5_DCR,               TIM5_BASE + TIM_DCR_OFFSET
    .equ    TIM5_DMAR,              TIM5_BASE + TIM_DMAR_OFFSET

#--- Basic Timer - TIM6 / address space:  0x4000_1000 .. 0x4000_13FF

    .equ    TIM6_BASE,              APB1_BASE + 0x1000

    .equ    TIM6_CR1,               TIM6_BASE + TIM_CR1_OFFSET
    .equ    TIM6_CR2,               TIM6_BASE + TIM_CR2_OFFSET

    .equ    TIM6_DIER,              TIM6_BASE + TIM_DIER_OFFSET
    .equ    TIM6_SR,                TIM6_BASE + TIM_SR_OFFSET
    .equ    TIM6_EGR,               TIM6_BASE + TIM_EGR_OFFSET

    .equ    TIM6_CNT,               TIM6_BASE + TIM_CNT_OFFSET
    .equ    TIM6_PSC,               TIM6_BASE + TIM_PSC_OFFSET
    .equ    TIM6_ARR,               TIM6_BASE + TIM_ARR_OFFSET

#--- Basic Timer - TIM7 / address space:  0x4000_1400 .. 0x4000_17FF

    .equ    TIM7_BASE,              APB1_BASE + 0x1400

    .equ    TIM7_CR1,               TIM7_BASE + TIM_CR1_OFFSET
    .equ    TIM7_CR2,               TIM7_BASE + TIM_CR2_OFFSET

    .equ    TIM7_DIER,              TIM7_BASE + TIM_DIER_OFFSET
    .equ    TIM7_SR,                TIM7_BASE + TIM_SR_OFFSET
    .equ    TIM7_EGR,               TIM7_BASE + TIM_EGR_OFFSET

    .equ    TIM7_CNT,               TIM7_BASE + TIM_CNT_OFFSET
    .equ    TIM7_PSC,               TIM7_BASE + TIM_PSC_OFFSET
    .equ    TIM7_ARR,               TIM7_BASE + TIM_ARR_OFFSET

#--- Advanced Control Timer - TIM1 / address space:  0x4001_2C00 .. 0x4001_2FFF

    .equ    TIM1_BASE,              APB2_BASE + 0x2C00

    .equ    TIM1_CR1,               TIM1_BASE + TIM_CR1_OFFSET
    .equ    TIM1_CR2,               TIM1_BASE + TIM_CR2_OFFSET
    .equ    TIM1_SMCR,              TIM1_BASE + TIM_SMCR_OFFSET
    .equ    TIM1_DIER,              TIM1_BASE + TIM_DIER_OFFSET
    .equ    TIM1_SR,                TIM1_BASE + TIM_SR_OFFSET
    .equ    TIM1_EGR,               TIM1_BASE + TIM_EGR_OFFSET
    .equ    TIM1_CCMR1,             TIM1_BASE + TIM_CCMR1_OFFSET
    .equ    TIM1_CCMR2,             TIM1_BASE + TIM_CCMR2_OFFSET
    .equ    TIM1_CCER,              TIM1_BASE + TIM_CCER_OFFSET
    .equ    TIM1_CNT,               TIM1_BASE + TIM_CNT_OFFSET
    .equ    TIM1_PSC,               TIM1_BASE + TIM_PSC_OFFSET
    .equ    TIM1_ARR,               TIM1_BASE + TIM_ARR_OFFSET
    .equ    TIM1_RCR,               TIM1_BASE + TIM_RCR_OFFSET
    .equ    TIM1_CCR1,              TIM1_BASE + TIM_CCR1_OFFSET
    .equ    TIM1_CCR2,              TIM1_BASE + TIM_CCR2_OFFSET
    .equ    TIM1_CCR3,              TIM1_BASE + TIM_CCR3_OFFSET
    .equ    TIM1_CCR4,              TIM1_BASE + TIM_CCR4_OFFSET
    .equ    TIM1_BDTR,              TIM1_BASE + TIM_BDTR_OFFSET
    .equ    TIM1_CCR5,              TIM1_BASE + TIM_CCR5_OFFSET
    .equ    TIM1_CCR6,              TIM1_BASE + TIM_CCR6_OFFSET
    .equ    TIM1_CCMR3,             TIM1_BASE + TIM_CCMR3_OFFSET
    .equ    TIM1_DTR2,              TIM1_BASE + TIM_DTR2_OFFSET
    .equ    TIM1_ECR,               TIM1_BASE + TIM_ECR_OFFSET
    .equ    TIM1_TISEL,             TIM1_BASE + TIM_TISEL_OFFSET
    .equ    TIM1_AF1,               TIM1_BASE + TIM_AF1_OFFSET
    .equ    TIM1_AF2,               TIM1_BASE + TIM_AF2_OFFSET

    .equ    TIM1_DCR,               TIM1_BASE + TIM_DCR_OFFSET
    .equ    TIM1_DMAR,              TIM1_BASE + TIM_DMAR_OFFSET

#--- Advanced Control Timer - TIM8 / address space:  0x4001_3400 .. 0x4001_37FF

    .equ    TIM8_BASE,              APB2_BASE + 0x3400

    .equ    TIM8_CR1,               TIM8_BASE + TIM_CR1_OFFSET
    .equ    TIM8_CR2,               TIM8_BASE + TIM_CR2_OFFSET
    .equ    TIM8_SMCR,              TIM8_BASE + TIM_SMCR_OFFSET
    .equ    TIM8_DIER,              TIM8_BASE + TIM_DIER_OFFSET
    .equ    TIM8_SR,                TIM8_BASE + TIM_SR_OFFSET
    .equ    TIM8_EGR,               TIM8_BASE + TIM_EGR_OFFSET
    .equ    TIM8_CCMR1,             TIM8_BASE + TIM_CCMR1_OFFSET
    .equ    TIM8_CCMR2,             TIM8_BASE + TIM_CCMR2_OFFSET
    .equ    TIM8_CCER,              TIM8_BASE + TIM_CCER_OFFSET
    .equ    TIM8_CNT,               TIM8_BASE + TIM_CNT_OFFSET
    .equ    TIM8_PSC,               TIM8_BASE + TIM_PSC_OFFSET
    .equ    TIM8_ARR,               TIM8_BASE + TIM_ARR_OFFSET
    .equ    TIM8_RCR,               TIM8_BASE + TIM_RCR_OFFSET
    .equ    TIM8_CCR1,              TIM8_BASE + TIM_CCR1_OFFSET
    .equ    TIM8_CCR2,              TIM8_BASE + TIM_CCR2_OFFSET
    .equ    TIM8_CCR3,              TIM8_BASE + TIM_CCR3_OFFSET
    .equ    TIM8_CCR4,              TIM8_BASE + TIM_CCR4_OFFSET
    .equ    TIM8_BDTR,              TIM8_BASE + TIM_BDTR_OFFSET
    .equ    TIM8_CCR5,              TIM8_BASE + TIM_CCR5_OFFSET
    .equ    TIM8_CCR6,              TIM8_BASE + TIM_CCR6_OFFSET
    .equ    TIM8_CCMR3,             TIM8_BASE + TIM_CCMR3_OFFSET
    .equ    TIM8_DTR2,              TIM8_BASE + TIM_DTR2_OFFSET
    .equ    TIM8_ECR,               TIM8_BASE + TIM_ECR_OFFSET
    .equ    TIM8_TISEL,             TIM8_BASE + TIM_TISEL_OFFSET
    .equ    TIM8_AF1,               TIM8_BASE + TIM_AF1_OFFSET
    .equ    TIM8_AF2,               TIM8_BASE + TIM_AF2_OFFSET

    .equ    TIM8_DCR,               TIM8_BASE + TIM_DCR_OFFSET
    .equ    TIM8_DMAR,              TIM8_BASE + TIM_DMAR_OFFSET

#--- Advanced Control Timer - TIM20 / address space: 0x4001_5000 .. 0x4001_53FF

    .equ    TIM20_BASE,             APB2_BASE + 0x5000

    .equ    TIM20_CR1,               TIM20_BASE + TIM_CR1_OFFSET
    .equ    TIM20_CR2,               TIM20_BASE + TIM_CR2_OFFSET
    .equ    TIM20_SMCR,              TIM20_BASE + TIM_SMCR_OFFSET
    .equ    TIM20_DIER,              TIM20_BASE + TIM_DIER_OFFSET
    .equ    TIM20_SR,                TIM20_BASE + TIM_SR_OFFSET
    .equ    TIM20_EGR,               TIM20_BASE + TIM_EGR_OFFSET
    .equ    TIM20_CCMR1,             TIM20_BASE + TIM_CCMR1_OFFSET
    .equ    TIM20_CCMR2,             TIM20_BASE + TIM_CCMR2_OFFSET
    .equ    TIM20_CCER,              TIM20_BASE + TIM_CCER_OFFSET
    .equ    TIM20_CNT,               TIM20_BASE + TIM_CNT_OFFSET
    .equ    TIM20_PSC,               TIM20_BASE + TIM_PSC_OFFSET
    .equ    TIM20_ARR,               TIM20_BASE + TIM_ARR_OFFSET
    .equ    TIM20_RCR,               TIM20_BASE + TIM_RCR_OFFSET
    .equ    TIM20_CCR1,              TIM20_BASE + TIM_CCR1_OFFSET
    .equ    TIM20_CCR2,              TIM20_BASE + TIM_CCR2_OFFSET
    .equ    TIM20_CCR3,              TIM20_BASE + TIM_CCR3_OFFSET
    .equ    TIM20_CCR4,              TIM20_BASE + TIM_CCR4_OFFSET
    .equ    TIM20_BDTR,              TIM20_BASE + TIM_BDTR_OFFSET
    .equ    TIM20_CCR5,              TIM20_BASE + TIM_CCR5_OFFSET
    .equ    TIM20_CCR6,              TIM20_BASE + TIM_CCR6_OFFSET
    .equ    TIM20_CCMR3,             TIM20_BASE + TIM_CCMR3_OFFSET
    .equ    TIM20_DTR2,              TIM20_BASE + TIM_DTR2_OFFSET
    .equ    TIM20_ECR,               TIM20_BASE + TIM_ECR_OFFSET
    .equ    TIM20_TISEL,             TIM20_BASE + TIM_TISEL_OFFSET
    .equ    TIM20_AF1,               TIM20_BASE + TIM_AF1_OFFSET
    .equ    TIM20_AF2,               TIM20_BASE + TIM_AF2_OFFSET

    .equ    TIM20_DCR,               TIM20_BASE + TIM_DCR_OFFSET
    .equ    TIM20_DMAR,              TIM20_BASE + TIM_DMAR_OFFSET

#--- Genral Purpose Timer - TIM15 / address space:  0x4001_4000 .. 0x4001_43FF

    .equ    TIM15_BASE,              APB2_BASE + 0x4000

    .equ    TIM15_CR1,               TIM15_BASE + TIM_CR1_OFFSET
    .equ    TIM15_CR2,               TIM15_BASE + TIM_CR2_OFFSET
    .equ    TIM15_SMCR,              TIM15_BASE + TIM_SMCR_OFFSET
    .equ    TIM15_DIER,              TIM15_BASE + TIM_DIER_OFFSET
    .equ    TIM15_SR,                TIM15_BASE + TIM_SR_OFFSET
    .equ    TIM15_EGR,               TIM15_BASE + TIM_EGR_OFFSET
    .equ    TIM15_CCMR1,             TIM15_BASE + TIM_CCMR1_OFFSET

    .equ    TIM15_CCER,              TIM15_BASE + TIM_CCER_OFFSET
    .equ    TIM15_CNT,               TIM15_BASE + TIM_CNT_OFFSET
    .equ    TIM15_PSC,               TIM15_BASE + TIM_PSC_OFFSET
    .equ    TIM15_ARR,               TIM15_BASE + TIM_ARR_OFFSET
    .equ    TIM15_RCR,               TIM15_BASE + TIM_RCR_OFFSET
    .equ    TIM15_CCR1,              TIM15_BASE + TIM_CCR1_OFFSET
    .equ    TIM15_CCR2,              TIM15_BASE + TIM_CCR2_OFFSET

    .equ    TIM15_BDTR,              TIM15_BASE + TIM_BDTR_OFFSET

    .equ    TIM15_DTR2,              TIM15_BASE + TIM_DTR2_OFFSET

    .equ    TIM15_TISEL,             TIM15_BASE + TIM_TISEL_OFFSET
    .equ    TIM15_AF1,               TIM15_BASE + TIM_AF1_OFFSET
    .equ    TIM15_AF2,               TIM15_BASE + TIM_AF2_OFFSET

    .equ    TIM15_DCR,               TIM15_BASE + TIM_DCR_OFFSET
    .equ    TIM15_DMAR,              TIM15_BASE + TIM_DMAR_OFFSET

#--- Genral Purpose Timer - TIM16 / address space:  0x4001_4400 .. 0x4001_47FF

    .equ    TIM16_BASE,              APB2_BASE + 0x4400

    .equ    TIM16_CR1,               TIM16_BASE + TIM_CR1_OFFSET
    .equ    TIM16_CR2,               TIM16_BASE + TIM_CR2_OFFSET

    .equ    TIM16_DIER,              TIM16_BASE + TIM_DIER_OFFSET
    .equ    TIM16_SR,                TIM16_BASE + TIM_SR_OFFSET
    .equ    TIM16_EGR,               TIM16_BASE + TIM_EGR_OFFSET
    .equ    TIM16_CCMR1,             TIM16_BASE + TIM_CCMR1_OFFSET

    .equ    TIM16_CCER,              TIM16_BASE + TIM_CCER_OFFSET
    .equ    TIM16_CNT,               TIM16_BASE + TIM_CNT_OFFSET
    .equ    TIM16_PSC,               TIM16_BASE + TIM_PSC_OFFSET
    .equ    TIM16_ARR,               TIM16_BASE + TIM_ARR_OFFSET
    .equ    TIM16_RCR,               TIM16_BASE + TIM_RCR_OFFSET
    .equ    TIM16_CCR1,              TIM16_BASE + TIM_CCR1_OFFSET

    .equ    TIM16_BDTR,              TIM16_BASE + TIM_BDTR_OFFSET

    .equ    TIM16_DTR2,              TIM16_BASE + TIM_DTR2_OFFSET

    .equ    TIM16_TISEL,             TIM16_BASE + TIM_TISEL_OFFSET
    .equ    TIM16_AF1,               TIM16_BASE + TIM_AF1_OFFSET
    .equ    TIM16_AF2,               TIM16_BASE + TIM_AF2_OFFSET
    .equ    TIM16_OR1,               TIM16_BASE + TIM_OR1_OFFSET

    .equ    TIM16_DCR,               TIM16_BASE + TIM_DCR_OFFSET
    .equ    TIM16_DMAR,              TIM16_BASE + TIM_DMAR_OFFSET

#--- Genral Purpose Timer - TIM17 / address space:  0x4001_4800 .. 0x4001_4BFF

    .equ    TIM17_BASE,              APB2_BASE + 0x4800

    .equ    TIM17_CR1,               TIM17_BASE + TIM_CR1_OFFSET
    .equ    TIM17_CR2,               TIM17_BASE + TIM_CR2_OFFSET

    .equ    TIM17_DIER,              TIM17_BASE + TIM_DIER_OFFSET
    .equ    TIM17_SR,                TIM17_BASE + TIM_SR_OFFSET
    .equ    TIM17_EGR,               TIM17_BASE + TIM_EGR_OFFSET
    .equ    TIM17_CCMR1,             TIM17_BASE + TIM_CCMR1_OFFSET

    .equ    TIM17_CCER,              TIM17_BASE + TIM_CCER_OFFSET
    .equ    TIM17_CNT,               TIM17_BASE + TIM_CNT_OFFSET
    .equ    TIM17_PSC,               TIM17_BASE + TIM_PSC_OFFSET
    .equ    TIM17_ARR,               TIM17_BASE + TIM_ARR_OFFSET
    .equ    TIM17_RCR,               TIM17_BASE + TIM_RCR_OFFSET
    .equ    TIM17_CCR1,              TIM17_BASE + TIM_CCR1_OFFSET

    .equ    TIM17_BDTR,              TIM17_BASE + TIM_BDTR_OFFSET

    .equ    TIM17_DTR2,              TIM17_BASE + TIM_DTR2_OFFSET

    .equ    TIM17_TISEL,             TIM17_BASE + TIM_TISEL_OFFSET
    .equ    TIM17_AF1,               TIM17_BASE + TIM_AF1_OFFSET
    .equ    TIM17_AF2,               TIM17_BASE + TIM_AF2_OFFSET
    .equ    TIM17_OR1,               TIM17_BASE + TIM_OR1_OFFSET

    .equ    TIM17_DCR,               TIM17_BASE + TIM_DCR_OFFSET
    .equ    TIM17_DMAR,              TIM17_BASE + TIM_DMAR_OFFSET

#----------------------------------------------------------------------------------------#
#   Reset and Clock Control
#
#   address space:  0x4002_1000 .. 0x4002_13FF
#----------------------------------------------------------------------------------------#

    .equ    RCC_BASE,               AHB1_BASE + 0x1000

    .equ    RCC_CR,                 RCC_BASE + 0x00
    .equ    RCC_ICSCR,              RCC_BASE + 0x04
    .equ    RCC_CFGR,               RCC_BASE + 0x08
    .equ    RCC_PLLCFGR,            RCC_BASE + 0x0C

    .equ    RCC_CIER,               RCC_BASE + 0x18
    .equ    RCC_CIFR,               RCC_BASE + 0x1C
    .equ    RCC_CICR,               RCC_BASE + 0x20

    .equ    RCC_AHB1RSTR,           RCC_BASE + 0x28
    .equ    RCC_AHB2RSTR,           RCC_BASE + 0x2C
    .equ    RCC_AHB3RSTR,           RCC_BASE + 0x30

    .equ    RCC_APB1RSTR1,          RCC_BASE + 0x38
    .equ    RCC_APB1RSTR2,          RCC_BASE + 0x3C
    .equ    RCC_APB2RSTR,           RCC_BASE + 0x40

    .equ    RCC_AHB1ENR,            RCC_BASE + 0x48
    .equ    RCC_AHB2ENR,            RCC_BASE + 0x4C
    .equ    RCC_AHB3ENR,            RCC_BASE + 0x50

    .equ    RCC_APB1ENR1,           RCC_BASE + 0x58
    .equ    RCC_APB1ENR2,           RCC_BASE + 0x5C
    .equ    RCC_APB2ENR,            RCC_BASE + 0x60

    .equ    RCC_AHB1SMENR,          RCC_BASE + 0x68
    .equ    RCC_AHB2SMENR,          RCC_BASE + 0x6C
    .equ    RCC_AHB3SMENR,          RCC_BASE + 0x70

    .equ    RCC_APB1SMENR1,         RCC_BASE + 0x78
    .equ    RCC_APB1SMENR2,         RCC_BASE + 0x7C
    .equ    RCC_APB2SMENR,          RCC_BASE + 0x80

    .equ    RCC_CCIPR,              RCC_BASE + 0x88

    .equ    RCC_BDCR,               RCC_BASE + 0x90
    .equ    RCC_CSR,                RCC_BASE + 0x94
    .equ    RCC_CRRCR,              RCC_BASE + 0x98
    .equ    RCC_CCIPR2,             RCC_BASE + 0x9C

#----------------------------------------------------------------------------------------#
#   GPIO module common configuration
#
#   address space:  0x4800_0000 .. 0x4800_1FFF
#----------------------------------------------------------------------------------------#

    .equ    GPIO_BASE,              AHB2_BASE

    .equ    GPIO_MODER_OFFSET,      0x00
    .equ    GPIO_OTYPER_OFFSET,     0x04
    .equ    GPIO_OSPEEDR_OFFSET,    0x08
    .equ    GPIO_PUPDR_OFFSET,      0x0C
    .equ    GPIO_IDR_OFFSET,        0x10
    .equ    GPIO_ODR_OFFSET,        0x14
    .equ    GPIO_BSRR_OFFSET,       0x18
    .equ    GPIO_LCKR_OFFSET,       0x1C
    .equ    GPIO_AFRL_OFFSET,       0x20
    .equ    GPIO_AFRH_OFFSET,       0x24
    .equ    GPIO_BRR_OFFSET,        0x28

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

#--- Port A GPIO configuration / address space: 0x4800_0000 .. 0x4800_03FF

    .equ    GPIOA_BASE,             GPIO_BASE

    .equ    GPIOA_MODER,            GPIOA_BASE + GPIO_MODER_OFFSET
    .equ    GPIOA_OTYPER,           GPIOA_BASE + GPIO_OTYPER_OFFSET
    .equ    GPIOA_OSPEEDR,          GPIOA_BASE + GPIO_OSPEEDR_OFFSET
    .equ    GPIOA_PUPDR,            GPIOA_BASE + GPIO_PUPDR_OFFSET
    .equ    GPIOA_IDR,              GPIOA_BASE + GPIO_IDR_OFFSET
    .equ    GPIOA_ODR,              GPIOA_BASE + GPIO_ODR_OFFSET
    .equ    GPIOA_BSRR,             GPIOA_BASE + GPIO_BSRR_OFFSET
    .equ    GPIOA_LCKR,             GPIOA_BASE + GPIO_LCKR_OFFSET
    .equ    GPIOA_AFRL,             GPIOA_BASE + GPIO_AFRL_OFFSET
    .equ    GPIOA_AFRH,             GPIOA_BASE + GPIO_AFRH_OFFSET
    .equ    GPIOA_BRR,              GPIOA_BASE + GPIO_BRR_OFFSET

#--- Port B GPIO configuration / address space: 0x4800_0400 .. 0x4800_07FF

    .equ    GPIOB_BASE,             GPIO_BASE + 0x400

    .equ    GPIOB_MODER,            GPIOB_BASE + GPIO_MODER_OFFSET
    .equ    GPIOB_OTYPER,           GPIOB_BASE + GPIO_OTYPER_OFFSET
    .equ    GPIOB_OSPEEDR,          GPIOB_BASE + GPIO_OSPEEDR_OFFSET
    .equ    GPIOB_PUPDR,            GPIOB_BASE + GPIO_PUPDR_OFFSET
    .equ    GPIOB_IDR,              GPIOB_BASE + GPIO_IDR_OFFSET
    .equ    GPIOB_ODR,              GPIOB_BASE + GPIO_ODR_OFFSET
    .equ    GPIOB_BSRR,             GPIOB_BASE + GPIO_BSRR_OFFSET
    .equ    GPIOB_LCKR,             GPIOB_BASE + GPIO_LCKR_OFFSET
    .equ    GPIOB_AFRL,             GPIOB_BASE + GPIO_AFRL_OFFSET
    .equ    GPIOB_AFRH,             GPIOB_BASE + GPIO_AFRH_OFFSET
    .equ    GPIOB_BRR,              GPIOB_BASE + GPIO_BRR_OFFSET

#--- Port C GPIO configuration / address space: 0x4800_0800 .. 0x4800_0BFF

    .equ    GPIOC_BASE,             GPIO_BASE + 0x800

    .equ    GPIOC_MODER,            GPIOC_BASE + GPIO_MODER_OFFSET
    .equ    GPIOC_OTYPER,           GPIOC_BASE + GPIO_OTYPER_OFFSET
    .equ    GPIOC_OSPEEDR,          GPIOC_BASE + GPIO_OSPEEDR_OFFSET
    .equ    GPIOC_PUPDR,            GPIOC_BASE + GPIO_PUPDR_OFFSET
    .equ    GPIOC_IDR,              GPIOC_BASE + GPIO_IDR_OFFSET
    .equ    GPIOC_ODR,              GPIOC_BASE + GPIO_ODR_OFFSET
    .equ    GPIOC_BSRR,             GPIOC_BASE + GPIO_BSRR_OFFSET
    .equ    GPIOC_LCKR,             GPIOC_BASE + GPIO_LCKR_OFFSET
    .equ    GPIOC_AFRL,             GPIOC_BASE + GPIO_AFRL_OFFSET
    .equ    GPIOC_AFRH,             GPIOC_BASE + GPIO_AFRH_OFFSET
    .equ    GPIOC_BRR,              GPIOC_BASE + GPIO_BRR_OFFSET

#--- Port D GPIO configuration / address space: 0x4800_0C00 .. 0x4800_0FFF

    .equ    GPIOD_BASE,             GPIO_BASE + 0xC00

    .equ    GPIOD_MODER,            GPIOD_BASE + GPIO_MODER_OFFSET
    .equ    GPIOD_OTYPER,           GPIOD_BASE + GPIO_OTYPER_OFFSET
    .equ    GPIOD_OSPEEDR,          GPIOD_BASE + GPIO_OSPEEDR_OFFSET
    .equ    GPIOD_PUPDR,            GPIOD_BASE + GPIO_PUPDR_OFFSET
    .equ    GPIOD_IDR,              GPIOD_BASE + GPIO_IDR_OFFSET
    .equ    GPIOD_ODR,              GPIOD_BASE + GPIO_ODR_OFFSET
    .equ    GPIOD_BSRR,             GPIOD_BASE + GPIO_BSRR_OFFSET
    .equ    GPIOD_LCKR,             GPIOD_BASE + GPIO_LCKR_OFFSET
    .equ    GPIOD_AFRL,             GPIOD_BASE + GPIO_AFRL_OFFSET
    .equ    GPIOD_AFRH,             GPIOD_BASE + GPIO_AFRH_OFFSET
    .equ    GPIOD_BRR,              GPIOD_BASE + GPIO_BRR_OFFSET

#--- Port E GPIO configuration / address space: 0x4800_1000 .. 0x4800_13FF

    .equ    GPIOE_BASE,             GPIO_BASE + 0x1000

    .equ    GPIOE_MODER,            GPIOE_BASE + GPIO_MODER_OFFSET
    .equ    GPIOE_OTYPER,           GPIOE_BASE + GPIO_OTYPER_OFFSET
    .equ    GPIOE_OSPEEDR,          GPIOE_BASE + GPIO_OSPEEDR_OFFSET
    .equ    GPIOE_PUPDR,            GPIOE_BASE + GPIO_PUPDR_OFFSET
    .equ    GPIOE_IDR,              GPIOE_BASE + GPIO_IDR_OFFSET
    .equ    GPIOE_ODR,              GPIOE_BASE + GPIO_ODR_OFFSET
    .equ    GPIOE_BSRR,             GPIOE_BASE + GPIO_BSRR_OFFSET
    .equ    GPIOE_LCKR,             GPIOE_BASE + GPIO_LCKR_OFFSET
    .equ    GPIOE_AFRL,             GPIOE_BASE + GPIO_AFRL_OFFSET
    .equ    GPIOE_AFRH,             GPIOE_BASE + GPIO_AFRH_OFFSET
    .equ    GPIOE_BRR,              GPIOE_BASE + GPIO_BRR_OFFSET

#--- Port F GPIO configuration / address space: 0x4800_1400 .. 0x4800_17FF

    .equ    GPIOF_BASE,             GPIO_BASE + 0x1400

    .equ    GPIOF_MODER,            GPIOF_BASE + GPIO_MODER_OFFSET
    .equ    GPIOF_OTYPER,           GPIOF_BASE + GPIO_OTYPER_OFFSET
    .equ    GPIOF_OSPEEDR,          GPIOF_BASE + GPIO_OSPEEDR_OFFSET
    .equ    GPIOF_PUPDR,            GPIOF_BASE + GPIO_PUPDR_OFFSET
    .equ    GPIOF_IDR,              GPIOF_BASE + GPIO_IDR_OFFSET
    .equ    GPIOF_ODR,              GPIOF_BASE + GPIO_ODR_OFFSET
    .equ    GPIOF_BSRR,             GPIOF_BASE + GPIO_BSRR_OFFSET
    .equ    GPIOF_LCKR,             GPIOF_BASE + GPIO_LCKR_OFFSET
    .equ    GPIOF_AFRL,             GPIOF_BASE + GPIO_AFRL_OFFSET
    .equ    GPIOF_AFRH,             GPIOF_BASE + GPIO_AFRH_OFFSET
    .equ    GPIOF_BRR,              GPIOF_BASE + GPIO_BRR_OFFSET

#--- Port G GPIO configuration / address space: 0x4800_1800 .. 0x4800_1BFF

    .equ    GPIOG_BASE,             GPIO_BASE + 0x1800

    .equ    GPIOG_MODER,            GPIOG_BASE + GPIO_MODER_OFFSET
    .equ    GPIOG_OTYPER,           GPIOG_BASE + GPIO_OTYPER_OFFSET
    .equ    GPIOG_OSPEEDR,          GPIOG_BASE + GPIO_OSPEEDR_OFFSET
    .equ    GPIOG_PUPDR,            GPIOG_BASE + GPIO_PUPDR_OFFSET
    .equ    GPIOG_IDR,              GPIOG_BASE + GPIO_IDR_OFFSET
    .equ    GPIOG_ODR,              GPIOG_BASE + GPIO_ODR_OFFSET
    .equ    GPIOG_BSRR,             GPIOG_BASE + GPIO_BSRR_OFFSET
    .equ    GPIOG_LCKR,             GPIOG_BASE + GPIO_LCKR_OFFSET
    .equ    GPIOG_AFRL,             GPIOG_BASE + GPIO_AFRL_OFFSET
    .equ    GPIOG_AFRH,             GPIOG_BASE + GPIO_AFRH_OFFSET
    .equ    GPIOG_BRR,              GPIOG_BASE + GPIO_BRR_OFFSET

#----------------------------------------------------------------------------------------#
#   System Control Space
#
#   address space:  0xE000_E000 .. 0xE000_EFFF
#----------------------------------------------------------------------------------------#

    .equ    SCS_BASE,               PPB_BASE + 0xE000

#----------------------------------------------------------------------------------------#
#   System Timer (SysTick)
#
#   address space:  0xE000_E010 .. 0xE000_E01F
#----------------------------------------------------------------------------------------#

    .equ    STK_BASE,               SCS_BASE + 10       // 0xE000_E010

    .equ    STK_CTRL,               SCS_BASE + 0x00
    .equ    STK_LOAD,               SCS_BASE + 0x04
    .equ    STK_VAL,                SCS_BASE + 0x08
    .equ    STK_CALIB,              SCS_BASE + 0x0C

#----------------------------------------------------------------------------------------#
#   Nested Vector Interrupt Controller
#
#   address space:  0xE000_E100 .. 0xE000_E4EF
#----------------------------------------------------------------------------------------#

    .equ    NVIC_BASE,              SCS_BASE + 0x100    // 0xE000_E100

    .equ    NVIC_ISER0,             NVIC_BASE + 0x00
    .equ    NVIC_ISER1,             NVIC_BASE + 0x04
    .equ    NVIC_ISER2,             NVIC_BASE + 0x08
    .equ    NVIC_ISER3,             NVIC_BASE + 0x0C

    .equ    NVIC_ICER0,             NVIC_BASE + 0x80
    .equ    NVIC_ICER1,             NVIC_BASE + 0x84
    .equ    NVIC_ICER2,             NVIC_BASE + 0x88
    .equ    NVIC_ICER3,             NVIC_BASE + 0x8C

    .equ    NVIC_ISPR0,             NVIC_BASE + 0x100
    .equ    NVIC_ISPR1,             NVIC_BASE + 0x104
    .equ    NVIC_ISPR2,             NVIC_BASE + 0x108
    .equ    NVIC_ISPR3,             NVIC_BASE + 0x10C

    .equ    NVIC_ICPR0,             NVIC_BASE + 0x180
    .equ    NVIC_ICPR1,             NVIC_BASE + 0x184
    .equ    NVIC_ICPR2,             NVIC_BASE + 0x188
    .equ    NVIC_ICPR3,             NVIC_BASE + 0x18C

    .equ    NVIC_IABR0,             NVIC_BASE + 0x200
    .equ    NVIC_IABR1,             NVIC_BASE + 0x204
    .equ    NVIC_IABR2,             NVIC_BASE + 0x208
    .equ    NVIC_IABR3,             NVIC_BASE + 0x20C

    .equ    NVIC_IPR0,              NVIC_BASE + 0x300
    .equ    NVIC_IPR1,              NVIC_BASE + 0x304
    .equ    NVIC_IPR2,              NVIC_BASE + 0x308
    .equ    NVIC_IPR3,              NVIC_BASE + 0x30C
    .equ    NVIC_IPR4,              NVIC_BASE + 0x310
    .equ    NVIC_IPR5,              NVIC_BASE + 0x314
    .equ    NVIC_IPR6,              NVIC_BASE + 0x318
    .equ    NVIC_IPR7,              NVIC_BASE + 0x31C
    .equ    NVIC_IPR8,              NVIC_BASE + 0x320
    .equ    NVIC_IPR9,              NVIC_BASE + 0x324
    .equ    NVIC_IPR10,             NVIC_BASE + 0x328
    .equ    NVIC_IPR11,             NVIC_BASE + 0x32C
    .equ    NVIC_IPR12,             NVIC_BASE + 0x330
    .equ    NVIC_IPR13,             NVIC_BASE + 0x334
    .equ    NVIC_IPR14,             NVIC_BASE + 0x338
    .equ    NVIC_IPR15,             NVIC_BASE + 0x33C
    .equ    NVIC_IPR16,             NVIC_BASE + 0x340
    .equ    NVIC_IPR17,             NVIC_BASE + 0x344
    .equ    NVIC_IPR18,             NVIC_BASE + 0x348
    .equ    NVIC_IPR19,             NVIC_BASE + 0x34C
    .equ    NVIC_IPR20,             NVIC_BASE + 0x350
    .equ    NVIC_IPR21,             NVIC_BASE + 0x354
    .equ    NVIC_IPR22,             NVIC_BASE + 0x358
    .equ    NVIC_IPR23,             NVIC_BASE + 0x35C
    .equ    NVIC_IPR24,             NVIC_BASE + 0x360
    .equ    NVIC_IPR25,             NVIC_BASE + 0x364

    .equ    STIR,                   NVIC_BASE + 0xE00

#----------------------------------------------------------------------------------------#
#   MCU Debug Component
#
#   address space:  0xE004_2000 .. 0xE004_2013
#----------------------------------------------------------------------------------------#

    .equ    DBGMCU_BASE,            PPB_BASE + 0x42000

    .equ    DBGMCU_IDCODE,          DBGMCU_BASE + 0x00
    .equ    DBGMCU_CR,              DBGMCU_BASE + 0x04
    .equ    DBGMCU_APB1FZR1,        DBGMCU_BASE + 0x08
    .equ    DBGMCU_APB1FZR2,        DBGMCU_BASE + 0x0C
    .equ    DBGMCU_APB2DZR,         DBGMCU_BASE + 0x10
