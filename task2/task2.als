 GNU assembler version 2.34.0 (arm-none-eabi)
	 using BFD version (GNU Tools for STM32 9-2020-q2-update.20201001-1621) 2.34.0.20200428.
 options passed	: -march=armv7-m -mcpu=cortex-m4 -adglns -g3 -mthumb --warn 
 input file    	: task2.s
 output file   	: task2.o
 target        	: arm-none-eabi
 time stamp    	: 

   1              	#****************************************************************************************#
   2              	#   Project:    task2 - switch triggered LEDs
   3              	#   File:       task2.s
   4              	#
   5              	#   Language:   ASM
   6              	#
   7              	#   Hardware:   STefi Light v1.1
   8              	#   Processor:  STM32G431KBT6U
   9              	#
  10              	#   Author:     Manuel Lederhofer
  11              	#   Datum:      31.10.2014
  12              	#
  13              	#   Version:    5.0
  14              	#   History:
  15              	#       31.10.2014  ML  create file
  16              	#       27.09.2018  ML  edit comments, extend vector table
  17              	#       18.12.2018  ML  port from MKL05Z32VLC4 to STM32L476RG
  18              	#       27.02.2019  ML  move section of exception handlers to bottom of file
  19              	#		25.09.2019	ML	minor changes for a better code and comment understanding
  20              	#       04.09.2020  HL  port from STM32L476RG to STM32F411xE
  21              	#       21.09.2020  ML  tidy up, comments and formatting
  22              	#       29.09.2021  ML  port from STM32F411xE to STM32F042K6T6
  23              	#       09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
  24              	#
  25              	#   Status:     working
  26              	#
  27              	#   Description:
  28              	#       See the description and requirements of the requested application
  29              	#       in the lab exercise guide.
  30              	#
  31              	#   Notes:
  32              	#       - MCU speed at startup is 16 MHz
  33              	#
  34              	#   ToDo:
  35              	#       - Change the example code to match the description and requirements
  36              	#          of the requested application in the lab exercise guide.
  37              	#****************************************************************************************#
  38              	
  39              	    .include "G431_addr.s"
   1              	#*****************************************************************************************
   2              	#   Project:    task2 - switch triggered LEDs
   3              	#   File:       G431_addr.s
   4              	#
   5              	#   Language:   ASM
   6              	#
   7              	#   Hardware:   STefi v1.1
   8              	#   Processor:  STM32G431KBT6U
   9              	#
  10              	#   Author:     Manuel Lederhofer
  11              	#   Datum:      20.08.2015
  12              	#
  13              	#   Version:    3.0
  14              	#   History:
  15              	#       20.08.2015  ML  create file
  16              	#       07.12.2018  ML  port from MKL05Z32VLC4 to STM32L476RG
  17              	#       27.02.2019  ML  change from absolute addresses to BASE + OFFSET notation and
  18              	#                           add more timer modules
  19              	#       09.03.2022  ML  port from STM32F042K6T6 to STM32G431KBT6U
  20              	#
  21              	#   Status:     working
  22              	#
  23              	#   Description:
  24              	#       Connects assembly addresses for STM32G431 MCU to symbolic register names
  25              	#       used in the datasheets.
  26              	#
  27              	#   Notes:
  28              	#       - default MCU speed at startup is 16 MHz.
  29              	#
  30              	#   ToDo:
  31              	#       - none -
  32              	#*****************************************************************************************
  33              	
  34              	
  35              	#----------------------------------------------------------------------------------------#
  36              	#   MCU Bus Base Addresses
  37              	#----------------------------------------------------------------------------------------#
  38              	
  39              	    .equ    APB1_BASE,              0x40000000
  40              	    .equ    APB2_BASE,              0x40010000
  41              	    .equ    AHB1_BASE,              0x40020000
  42              	    .equ    AHB2_BASE,              0x48000000
  43              	    .equ    AHB3_BASE,              0xA0000000  //!!! FSMC + QSPI registers = AHB3 ?
  44              	    .equ    PPB_BASE,               0xE0000000  /* Cortex M4 with FPU Internal Peripherals */
  45              	
  46              	#----------------------------------------------------------------------------------------#
  47              	#   System Configuration Controller
  48              	#
  49              	#   address space:  0x4001_0000 .. 0x4001_0029
  50              	#----------------------------------------------------------------------------------------#
  51              	
  52              	    .equ    SYSCFG_BASE,            APB2_BASE
  53              	
  54              	    .equ    SYSCFG_MEMRMP,          SYSCFG_BASE + 0x00
  55              	    .equ    SYSCFG_CFGR1,           SYSCFG_BASE + 0x04
  56              	    .equ    SYSCFG_EXTICR1,         SYSCFG_BASE + 0x08
  57              	    .equ    SYSCFG_EXTICR2,         SYSCFG_BASE + 0x0C
  58              	    .equ    SYSCFG_EXTICR3,         SYSCFG_BASE + 0x10
  59              	    .equ    SYSCFG_EXTICR4,         SYSCFG_BASE + 0x14
  60              	    .equ    SYSCFG_SCSR,            SYSCFG_BASE + 0x18
  61              	    .equ    SYSCFG_CFGR2,           SYSCFG_BASE + 0x1C
  62              	    .equ    SYSCFG_SWPR,            SYSCFG_BASE + 0x20
  63              	    .equ    SYSCFG_SKR,             SYSCFG_BASE + 0x24
  64              	
  65              	#----------------------------------------------------------------------------------------#
  66              	#   Extended Interrupts And Events Controller
  67              	#
  68              	#   address space:  0x4001_0400 .. 0x4001_07FF
  69              	#----------------------------------------------------------------------------------------#
  70              	
  71              	    .equ    EXTI_BASE,              APB2_BASE + 0x400
  72              	
  73              	    .equ    EXTI_IMR1,              EXTI_BASE + 0x00
  74              	    .equ    EXTI_EMR1,              EXTI_BASE + 0x04
  75              	    .equ    EXTI_RTSR1,             EXTI_BASE + 0x08
  76              	    .equ    EXTI_FTSR1,             EXTI_BASE + 0x0C
  77              	    .equ    EXTI_SWIER1,            EXTI_BASE + 0x10
  78              	    .equ    EXTI_PR1,               EXTI_BASE + 0x14
  79              	
  80              	    .equ    EXTI_IMR2,              EXTI_BASE + 0x20
  81              	    .equ    EXTI_EMR2,              EXTI_BASE + 0x24
  82              	    .equ    EXTI_RTSR2,             EXTI_BASE + 0x28
  83              	    .equ    EXTI_FTSR2,             EXTI_BASE + 0x2C
  84              	    .equ    EXTI_SWIER2,            EXTI_BASE + 0x30
  85              	    .equ    EXTI_PR2,               EXTI_BASE + 0x34
  86              	
  87              	#----------------------------------------------------------------------------------------#
  88              	#   TIM module common configuration
  89              	#
  90              	#   Every timer has 1 KB address space:
  91              	#
  92              	#   TIM2 .. TIM7:   0x4000_0000 .. 0x4000_17FF (APB1)
  93              	#   TIM1:           0x4001_2C00 .. 0x4001_2FFF (APB2)
  94              	#   TIM8:           0x4001_3400 .. 0x4001_37FF (APB2)
  95              	#   TIM15 .. TIM17: 0x4001_4000 .. 0x4001_4BFF (APB2)
  96              	#   TIM20:          0x4001_5000 .. 0x4001_53FF (APB2)
  97              	#
  98              	#   note:
  99              	#       TIM2 + TIM5 are 32 bit timers. All others have a width of 16 bit.
 100              	#       Below, the timers on one line share a common register set description.
 101              	#
 102              	#       TIM 1, 8, 20    advances control timers
 103              	#       TIM 2, 3, 4, 5  general purpose timers  (TIM2/5 = 32 bit)
 104              	#       TIM 15          general purpose timers
 105              	#       TIM 16, 17      general purpose timers
 106              	#       TIM 6, 7        basic timers
 107              	#----------------------------------------------------------------------------------------#
 108              	
 109              	    .equ    TIM_CR1_OFFSET,         0x00
 110              	    .equ    TIM_CR2_OFFSET,         0x04
 111              	    .equ    TIM_SMCR_OFFSET,        0x08
 112              	    .equ    TIM_DIER_OFFSET,        0x0C
 113              	    .equ    TIM_SR_OFFSET,          0x10
 114              	    .equ    TIM_EGR_OFFSET,         0x14
 115              	    .equ    TIM_CCMR1_OFFSET,       0x18
 116              	    .equ    TIM_CCMR2_OFFSET,       0x1C
 117              	    .equ    TIM_CCER_OFFSET,        0x20
 118              	    .equ    TIM_CNT_OFFSET,         0x24
 119              	    .equ    TIM_PSC_OFFSET,         0x28
 120              	    .equ    TIM_ARR_OFFSET,         0x2C
 121              	    .equ    TIM_RCR_OFFSET,         0x30
 122              	    .equ    TIM_CCR1_OFFSET,        0x34
 123              	    .equ    TIM_CCR2_OFFSET,        0x38
 124              	    .equ    TIM_CCR3_OFFSET,        0x3C
 125              	    .equ    TIM_CCR4_OFFSET,        0x40
 126              	    .equ    TIM_BDTR_OFFSET,        0x44
 127              	    .equ    TIM_CCR5_OFFSET,        0x48
 128              	    .equ    TIM_CCR6_OFFSET,        0x4C
 129              	    .equ    TIM_CCMR3_OFFSET,       0x50
 130              	    .equ    TIM_DTR2_OFFSET,        0x54
 131              	    .equ    TIM_ECR_OFFSET,         0x58
 132              	    .equ    TIM_TISEL_OFFSET,       0x5C
 133              	    .equ    TIM_AF1_OFFSET,         0x60
 134              	    .equ    TIM_AF2_OFFSET,         0x64
 135              	    .equ    TIM_OR1_OFFSET,         0x68
 136              	
 137              	    .equ    TIM_DCR_OFFSET,         0x3DC
 138              	    .equ    TIM_DMAR_OFFSET,        0x3E0
 139              	
 140              	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
 141              	
 142              	#--- Genral Purpose Timer - TIM2 / address space:  0x4000_0000 .. 0x4000_03FF
 143              	
 144              	    .equ    TIM2_BASE,              APB1_BASE
 145              	
 146              	    .equ    TIM2_CR1,               TIM2_BASE + TIM_CR1_OFFSET
 147              	    .equ    TIM2_CR2,               TIM2_BASE + TIM_CR2_OFFSET
 148              	    .equ    TIM2_SMCR,              TIM2_BASE + TIM_SMCR_OFFSET
 149              	    .equ    TIM2_DIER,              TIM2_BASE + TIM_DIER_OFFSET
 150              	    .equ    TIM2_SR,                TIM2_BASE + TIM_SR_OFFSET
 151              	    .equ    TIM2_EGR,               TIM2_BASE + TIM_EGR_OFFSET
 152              	    .equ    TIM2_CCMR1,             TIM2_BASE + TIM_CCMR1_OFFSET
 153              	    .equ    TIM2_CCMR2,             TIM2_BASE + TIM_CCMR2_OFFSET
 154              	    .equ    TIM2_CCER,              TIM2_BASE + TIM_CCER_OFFSET
 155              	    .equ    TIM2_CNT,               TIM2_BASE + TIM_CNT_OFFSET
 156              	    .equ    TIM2_PSC,               TIM2_BASE + TIM_PSC_OFFSET
 157              	    .equ    TIM2_ARR,               TIM2_BASE + TIM_ARR_OFFSET
 158              	
 159              	    .equ    TIM2_CCR1,              TIM2_BASE + TIM_CCR1_OFFSET
 160              	    .equ    TIM2_CCR2,              TIM2_BASE + TIM_CCR2_OFFSET
 161              	    .equ    TIM2_CCR3,              TIM2_BASE + TIM_CCR3_OFFSET
 162              	    .equ    TIM2_CCR4,              TIM2_BASE + TIM_CCR4_OFFSET
 163              	
 164              	    .equ    TIM2_ECR,               TIM2_BASE + TIM_ECR_OFFSET
 165              	    .equ    TIM2_TISEL,             TIM2_BASE + TIM_TISEL_OFFSET
 166              	    .equ    TIM2_AF1,               TIM2_BASE + TIM_ECR_OFFSET
 167              	    .equ    TIM2_AF2,               TIM2_BASE + TIM_ECR_OFFSET
 168              	
 169              	    .equ    TIM2_DCR,               TIM2_BASE + TIM_DCR_OFFSET
 170              	    .equ    TIM2_DMAR,              TIM2_BASE + TIM_DMAR_OFFSET
 171              	
 172              	#--- Genral Purpose Timer - TIM3 / address space:  0x4000_0400 .. 0x4000_07FF
 173              	
 174              	    .equ    TIM3_BASE,              APB1_BASE + 0x400
 175              	
 176              	    .equ    TIM3_CR1,               TIM3_BASE + TIM_CR1_OFFSET
 177              	    .equ    TIM3_CR2,               TIM3_BASE + TIM_CR2_OFFSET
 178              	    .equ    TIM3_SMCR,              TIM3_BASE + TIM_SMCR_OFFSET
 179              	    .equ    TIM3_DIER,              TIM3_BASE + TIM_DIER_OFFSET
 180              	    .equ    TIM3_SR,                TIM3_BASE + TIM_SR_OFFSET
 181              	    .equ    TIM3_EGR,               TIM3_BASE + TIM_EGR_OFFSET
 182              	    .equ    TIM3_CCMR1,             TIM3_BASE + TIM_CCMR1_OFFSET
 183              	    .equ    TIM3_CCMR2,             TIM3_BASE + TIM_CCMR2_OFFSET
 184              	    .equ    TIM3_CCER,              TIM3_BASE + TIM_CCER_OFFSET
 185              	    .equ    TIM3_CNT,               TIM3_BASE + TIM_CNT_OFFSET
 186              	    .equ    TIM3_PSC,               TIM3_BASE + TIM_PSC_OFFSET
 187              	    .equ    TIM3_ARR,               TIM3_BASE + TIM_ARR_OFFSET
 188              	
 189              	    .equ    TIM3_CCR1,              TIM3_BASE + TIM_CCR1_OFFSET
 190              	    .equ    TIM3_CCR2,              TIM3_BASE + TIM_CCR2_OFFSET
 191              	    .equ    TIM3_CCR3,              TIM3_BASE + TIM_CCR3_OFFSET
 192              	    .equ    TIM3_CCR4,              TIM3_BASE + TIM_CCR4_OFFSET
 193              	
 194              	    .equ    TIM3_ECR,               TIM3_BASE + TIM_ECR_OFFSET
 195              	    .equ    TIM3_TISEL,             TIM3_BASE + TIM_TISEL_OFFSET
 196              	    .equ    TIM3_AF1,               TIM3_BASE + TIM_ECR_OFFSET
 197              	    .equ    TIM3_AF2,               TIM3_BASE + TIM_ECR_OFFSET
 198              	
 199              	    .equ    TIM3_DCR,               TIM3_BASE + TIM_DCR_OFFSET
 200              	    .equ    TIM3_DMAR,              TIM3_BASE + TIM_DMAR_OFFSET
 201              	
 202              	#--- Genral Purpose Timer - TIM4 / address space:  0x4000_0800 .. 0x4000_0BFF
 203              	
 204              	    .equ    TIM4_BASE,              APB1_BASE + 0x800
 205              	
 206              	    .equ    TIM4_CR1,               TIM4_BASE + TIM_CR1_OFFSET
 207              	    .equ    TIM4_CR2,               TIM4_BASE + TIM_CR2_OFFSET
 208              	    .equ    TIM4_SMCR,              TIM4_BASE + TIM_SMCR_OFFSET
 209              	    .equ    TIM4_DIER,              TIM4_BASE + TIM_DIER_OFFSET
 210              	    .equ    TIM4_SR,                TIM4_BASE + TIM_SR_OFFSET
 211              	    .equ    TIM4_EGR,               TIM4_BASE + TIM_EGR_OFFSET
 212              	    .equ    TIM4_CCMR1,             TIM4_BASE + TIM_CCMR1_OFFSET
 213              	    .equ    TIM4_CCMR2,             TIM4_BASE + TIM_CCMR2_OFFSET
 214              	    .equ    TIM4_CCER,              TIM4_BASE + TIM_CCER_OFFSET
 215              	    .equ    TIM4_CNT,               TIM4_BASE + TIM_CNT_OFFSET
 216              	    .equ    TIM4_PSC,               TIM4_BASE + TIM_PSC_OFFSET
 217              	    .equ    TIM4_ARR,               TIM4_BASE + TIM_ARR_OFFSET
 218              	
 219              	    .equ    TIM4_CCR1,              TIM4_BASE + TIM_CCR1_OFFSET
 220              	    .equ    TIM4_CCR2,              TIM4_BASE + TIM_CCR2_OFFSET
 221              	    .equ    TIM4_CCR3,              TIM4_BASE + TIM_CCR3_OFFSET
 222              	    .equ    TIM4_CCR4,              TIM4_BASE + TIM_CCR4_OFFSET
 223              	
 224              	    .equ    TIM4_ECR,               TIM4_BASE + TIM_ECR_OFFSET
 225              	    .equ    TIM4_TISEL,             TIM4_BASE + TIM_TISEL_OFFSET
 226              	    .equ    TIM4_AF1,               TIM4_BASE + TIM_ECR_OFFSET
 227              	    .equ    TIM4_AF2,               TIM4_BASE + TIM_ECR_OFFSET
 228              	
 229              	    .equ    TIM4_DCR,               TIM4_BASE + TIM_DCR_OFFSET
 230              	    .equ    TIM4_DMAR,              TIM4_BASE + TIM_DMAR_OFFSET
 231              	
 232              	#--- Genral Purpose Timer - TIM5 / address space:  0x4000_0C00 .. 0x4000_0FFF
 233              	
 234              	    .equ    TIM5_BASE,              APB1_BASE + 0xC00
 235              	
 236              	    .equ    TIM5_CR1,               TIM5_BASE + TIM_CR1_OFFSET
 237              	    .equ    TIM5_CR2,               TIM5_BASE + TIM_CR2_OFFSET
 238              	    .equ    TIM5_SMCR,              TIM5_BASE + TIM_SMCR_OFFSET
 239              	    .equ    TIM5_DIER,              TIM5_BASE + TIM_DIER_OFFSET
 240              	    .equ    TIM5_SR,                TIM5_BASE + TIM_SR_OFFSET
 241              	    .equ    TIM5_EGR,               TIM5_BASE + TIM_EGR_OFFSET
 242              	    .equ    TIM5_CCMR1,             TIM5_BASE + TIM_CCMR1_OFFSET
 243              	    .equ    TIM5_CCMR2,             TIM5_BASE + TIM_CCMR2_OFFSET
 244              	    .equ    TIM5_CCER,              TIM5_BASE + TIM_CCER_OFFSET
 245              	    .equ    TIM5_CNT,               TIM5_BASE + TIM_CNT_OFFSET
 246              	    .equ    TIM5_PSC,               TIM5_BASE + TIM_PSC_OFFSET
 247              	    .equ    TIM5_ARR,               TIM5_BASE + TIM_ARR_OFFSET
 248              	
 249              	    .equ    TIM5_CCR1,              TIM5_BASE + TIM_CCR1_OFFSET
 250              	    .equ    TIM5_CCR2,              TIM5_BASE + TIM_CCR2_OFFSET
 251              	    .equ    TIM5_CCR3,              TIM5_BASE + TIM_CCR3_OFFSET
 252              	    .equ    TIM5_CCR4,              TIM5_BASE + TIM_CCR4_OFFSET
 253              	
 254              	    .equ    TIM5_ECR,               TIM5_BASE + TIM_ECR_OFFSET
 255              	    .equ    TIM5_TISEL,             TIM5_BASE + TIM_TISEL_OFFSET
 256              	    .equ    TIM5_AF1,               TIM5_BASE + TIM_ECR_OFFSET
 257              	    .equ    TIM5_AF2,               TIM5_BASE + TIM_ECR_OFFSET
 258              	
 259              	    .equ    TIM5_DCR,               TIM5_BASE + TIM_DCR_OFFSET
 260              	    .equ    TIM5_DMAR,              TIM5_BASE + TIM_DMAR_OFFSET
 261              	
 262              	#--- Basic Timer - TIM6 / address space:  0x4000_1000 .. 0x4000_13FF
 263              	
 264              	    .equ    TIM6_BASE,              APB1_BASE + 0x1000
 265              	
 266              	    .equ    TIM6_CR1,               TIM6_BASE + TIM_CR1_OFFSET
 267              	    .equ    TIM6_CR2,               TIM6_BASE + TIM_CR2_OFFSET
 268              	
 269              	    .equ    TIM6_DIER,              TIM6_BASE + TIM_DIER_OFFSET
 270              	    .equ    TIM6_SR,                TIM6_BASE + TIM_SR_OFFSET
 271              	    .equ    TIM6_EGR,               TIM6_BASE + TIM_EGR_OFFSET
 272              	
 273              	    .equ    TIM6_CNT,               TIM6_BASE + TIM_CNT_OFFSET
 274              	    .equ    TIM6_PSC,               TIM6_BASE + TIM_PSC_OFFSET
 275              	    .equ    TIM6_ARR,               TIM6_BASE + TIM_ARR_OFFSET
 276              	
 277              	#--- Basic Timer - TIM7 / address space:  0x4000_1400 .. 0x4000_17FF
 278              	
 279              	    .equ    TIM7_BASE,              APB1_BASE + 0x1400
 280              	
 281              	    .equ    TIM7_CR1,               TIM7_BASE + TIM_CR1_OFFSET
 282              	    .equ    TIM7_CR2,               TIM7_BASE + TIM_CR2_OFFSET
 283              	
 284              	    .equ    TIM7_DIER,              TIM7_BASE + TIM_DIER_OFFSET
 285              	    .equ    TIM7_SR,                TIM7_BASE + TIM_SR_OFFSET
 286              	    .equ    TIM7_EGR,               TIM7_BASE + TIM_EGR_OFFSET
 287              	
 288              	    .equ    TIM7_CNT,               TIM7_BASE + TIM_CNT_OFFSET
 289              	    .equ    TIM7_PSC,               TIM7_BASE + TIM_PSC_OFFSET
 290              	    .equ    TIM7_ARR,               TIM7_BASE + TIM_ARR_OFFSET
 291              	
 292              	#--- Advanced Control Timer - TIM1 / address space:  0x4001_2C00 .. 0x4001_2FFF
 293              	
 294              	    .equ    TIM1_BASE,              APB2_BASE + 0x2C00
 295              	
 296              	    .equ    TIM1_CR1,               TIM1_BASE + TIM_CR1_OFFSET
 297              	    .equ    TIM1_CR2,               TIM1_BASE + TIM_CR2_OFFSET
 298              	    .equ    TIM1_SMCR,              TIM1_BASE + TIM_SMCR_OFFSET
 299              	    .equ    TIM1_DIER,              TIM1_BASE + TIM_DIER_OFFSET
 300              	    .equ    TIM1_SR,                TIM1_BASE + TIM_SR_OFFSET
 301              	    .equ    TIM1_EGR,               TIM1_BASE + TIM_EGR_OFFSET
 302              	    .equ    TIM1_CCMR1,             TIM1_BASE + TIM_CCMR1_OFFSET
 303              	    .equ    TIM1_CCMR2,             TIM1_BASE + TIM_CCMR2_OFFSET
 304              	    .equ    TIM1_CCER,              TIM1_BASE + TIM_CCER_OFFSET
 305              	    .equ    TIM1_CNT,               TIM1_BASE + TIM_CNT_OFFSET
 306              	    .equ    TIM1_PSC,               TIM1_BASE + TIM_PSC_OFFSET
 307              	    .equ    TIM1_ARR,               TIM1_BASE + TIM_ARR_OFFSET
 308              	    .equ    TIM1_RCR,               TIM1_BASE + TIM_RCR_OFFSET
 309              	    .equ    TIM1_CCR1,              TIM1_BASE + TIM_CCR1_OFFSET
 310              	    .equ    TIM1_CCR2,              TIM1_BASE + TIM_CCR2_OFFSET
 311              	    .equ    TIM1_CCR3,              TIM1_BASE + TIM_CCR3_OFFSET
 312              	    .equ    TIM1_CCR4,              TIM1_BASE + TIM_CCR4_OFFSET
 313              	    .equ    TIM1_BDTR,              TIM1_BASE + TIM_BDTR_OFFSET
 314              	    .equ    TIM1_CCR5,              TIM1_BASE + TIM_CCR5_OFFSET
 315              	    .equ    TIM1_CCR6,              TIM1_BASE + TIM_CCR6_OFFSET
 316              	    .equ    TIM1_CCMR3,             TIM1_BASE + TIM_CCMR3_OFFSET
 317              	    .equ    TIM1_DTR2,              TIM1_BASE + TIM_DTR2_OFFSET
 318              	    .equ    TIM1_ECR,               TIM1_BASE + TIM_ECR_OFFSET
 319              	    .equ    TIM1_TISEL,             TIM1_BASE + TIM_TISEL_OFFSET
 320              	    .equ    TIM1_AF1,               TIM1_BASE + TIM_AF1_OFFSET
 321              	    .equ    TIM1_AF2,               TIM1_BASE + TIM_AF2_OFFSET
 322              	
 323              	    .equ    TIM1_DCR,               TIM1_BASE + TIM_DCR_OFFSET
 324              	    .equ    TIM1_DMAR,              TIM1_BASE + TIM_DMAR_OFFSET
 325              	
 326              	#--- Advanced Control Timer - TIM8 / address space:  0x4001_3400 .. 0x4001_37FF
 327              	
 328              	    .equ    TIM8_BASE,              APB2_BASE + 0x3400
 329              	
 330              	    .equ    TIM8_CR1,               TIM8_BASE + TIM_CR1_OFFSET
 331              	    .equ    TIM8_CR2,               TIM8_BASE + TIM_CR2_OFFSET
 332              	    .equ    TIM8_SMCR,              TIM8_BASE + TIM_SMCR_OFFSET
 333              	    .equ    TIM8_DIER,              TIM8_BASE + TIM_DIER_OFFSET
 334              	    .equ    TIM8_SR,                TIM8_BASE + TIM_SR_OFFSET
 335              	    .equ    TIM8_EGR,               TIM8_BASE + TIM_EGR_OFFSET
 336              	    .equ    TIM8_CCMR1,             TIM8_BASE + TIM_CCMR1_OFFSET
 337              	    .equ    TIM8_CCMR2,             TIM8_BASE + TIM_CCMR2_OFFSET
 338              	    .equ    TIM8_CCER,              TIM8_BASE + TIM_CCER_OFFSET
 339              	    .equ    TIM8_CNT,               TIM8_BASE + TIM_CNT_OFFSET
 340              	    .equ    TIM8_PSC,               TIM8_BASE + TIM_PSC_OFFSET
 341              	    .equ    TIM8_ARR,               TIM8_BASE + TIM_ARR_OFFSET
 342              	    .equ    TIM8_RCR,               TIM8_BASE + TIM_RCR_OFFSET
 343              	    .equ    TIM8_CCR1,              TIM8_BASE + TIM_CCR1_OFFSET
 344              	    .equ    TIM8_CCR2,              TIM8_BASE + TIM_CCR2_OFFSET
 345              	    .equ    TIM8_CCR3,              TIM8_BASE + TIM_CCR3_OFFSET
 346              	    .equ    TIM8_CCR4,              TIM8_BASE + TIM_CCR4_OFFSET
 347              	    .equ    TIM8_BDTR,              TIM8_BASE + TIM_BDTR_OFFSET
 348              	    .equ    TIM8_CCR5,              TIM8_BASE + TIM_CCR5_OFFSET
 349              	    .equ    TIM8_CCR6,              TIM8_BASE + TIM_CCR6_OFFSET
 350              	    .equ    TIM8_CCMR3,             TIM8_BASE + TIM_CCMR3_OFFSET
 351              	    .equ    TIM8_DTR2,              TIM8_BASE + TIM_DTR2_OFFSET
 352              	    .equ    TIM8_ECR,               TIM8_BASE + TIM_ECR_OFFSET
 353              	    .equ    TIM8_TISEL,             TIM8_BASE + TIM_TISEL_OFFSET
 354              	    .equ    TIM8_AF1,               TIM8_BASE + TIM_AF1_OFFSET
 355              	    .equ    TIM8_AF2,               TIM8_BASE + TIM_AF2_OFFSET
 356              	
 357              	    .equ    TIM8_DCR,               TIM8_BASE + TIM_DCR_OFFSET
 358              	    .equ    TIM8_DMAR,              TIM8_BASE + TIM_DMAR_OFFSET
 359              	
 360              	#--- Advanced Control Timer - TIM20 / address space: 0x4001_5000 .. 0x4001_53FF
 361              	
 362              	    .equ    TIM20_BASE,             APB2_BASE + 0x5000
 363              	
 364              	    .equ    TIM20_CR1,               TIM20_BASE + TIM_CR1_OFFSET
 365              	    .equ    TIM20_CR2,               TIM20_BASE + TIM_CR2_OFFSET
 366              	    .equ    TIM20_SMCR,              TIM20_BASE + TIM_SMCR_OFFSET
 367              	    .equ    TIM20_DIER,              TIM20_BASE + TIM_DIER_OFFSET
 368              	    .equ    TIM20_SR,                TIM20_BASE + TIM_SR_OFFSET
 369              	    .equ    TIM20_EGR,               TIM20_BASE + TIM_EGR_OFFSET
 370              	    .equ    TIM20_CCMR1,             TIM20_BASE + TIM_CCMR1_OFFSET
 371              	    .equ    TIM20_CCMR2,             TIM20_BASE + TIM_CCMR2_OFFSET
 372              	    .equ    TIM20_CCER,              TIM20_BASE + TIM_CCER_OFFSET
 373              	    .equ    TIM20_CNT,               TIM20_BASE + TIM_CNT_OFFSET
 374              	    .equ    TIM20_PSC,               TIM20_BASE + TIM_PSC_OFFSET
 375              	    .equ    TIM20_ARR,               TIM20_BASE + TIM_ARR_OFFSET
 376              	    .equ    TIM20_RCR,               TIM20_BASE + TIM_RCR_OFFSET
 377              	    .equ    TIM20_CCR1,              TIM20_BASE + TIM_CCR1_OFFSET
 378              	    .equ    TIM20_CCR2,              TIM20_BASE + TIM_CCR2_OFFSET
 379              	    .equ    TIM20_CCR3,              TIM20_BASE + TIM_CCR3_OFFSET
 380              	    .equ    TIM20_CCR4,              TIM20_BASE + TIM_CCR4_OFFSET
 381              	    .equ    TIM20_BDTR,              TIM20_BASE + TIM_BDTR_OFFSET
 382              	    .equ    TIM20_CCR5,              TIM20_BASE + TIM_CCR5_OFFSET
 383              	    .equ    TIM20_CCR6,              TIM20_BASE + TIM_CCR6_OFFSET
 384              	    .equ    TIM20_CCMR3,             TIM20_BASE + TIM_CCMR3_OFFSET
 385              	    .equ    TIM20_DTR2,              TIM20_BASE + TIM_DTR2_OFFSET
 386              	    .equ    TIM20_ECR,               TIM20_BASE + TIM_ECR_OFFSET
 387              	    .equ    TIM20_TISEL,             TIM20_BASE + TIM_TISEL_OFFSET
 388              	    .equ    TIM20_AF1,               TIM20_BASE + TIM_AF1_OFFSET
 389              	    .equ    TIM20_AF2,               TIM20_BASE + TIM_AF2_OFFSET
 390              	
 391              	    .equ    TIM20_DCR,               TIM20_BASE + TIM_DCR_OFFSET
 392              	    .equ    TIM20_DMAR,              TIM20_BASE + TIM_DMAR_OFFSET
 393              	
 394              	#--- Genral Purpose Timer - TIM15 / address space:  0x4001_4000 .. 0x4001_43FF
 395              	
 396              	    .equ    TIM15_BASE,              APB2_BASE + 0x4000
 397              	
 398              	    .equ    TIM15_CR1,               TIM15_BASE + TIM_CR1_OFFSET
 399              	    .equ    TIM15_CR2,               TIM15_BASE + TIM_CR2_OFFSET
 400              	    .equ    TIM15_SMCR,              TIM15_BASE + TIM_SMCR_OFFSET
 401              	    .equ    TIM15_DIER,              TIM15_BASE + TIM_DIER_OFFSET
 402              	    .equ    TIM15_SR,                TIM15_BASE + TIM_SR_OFFSET
 403              	    .equ    TIM15_EGR,               TIM15_BASE + TIM_EGR_OFFSET
 404              	    .equ    TIM15_CCMR1,             TIM15_BASE + TIM_CCMR1_OFFSET
 405              	
 406              	    .equ    TIM15_CCER,              TIM15_BASE + TIM_CCER_OFFSET
 407              	    .equ    TIM15_CNT,               TIM15_BASE + TIM_CNT_OFFSET
 408              	    .equ    TIM15_PSC,               TIM15_BASE + TIM_PSC_OFFSET
 409              	    .equ    TIM15_ARR,               TIM15_BASE + TIM_ARR_OFFSET
 410              	    .equ    TIM15_RCR,               TIM15_BASE + TIM_RCR_OFFSET
 411              	    .equ    TIM15_CCR1,              TIM15_BASE + TIM_CCR1_OFFSET
 412              	    .equ    TIM15_CCR2,              TIM15_BASE + TIM_CCR2_OFFSET
 413              	
 414              	    .equ    TIM15_BDTR,              TIM15_BASE + TIM_BDTR_OFFSET
 415              	
 416              	    .equ    TIM15_DTR2,              TIM15_BASE + TIM_DTR2_OFFSET
 417              	
 418              	    .equ    TIM15_TISEL,             TIM15_BASE + TIM_TISEL_OFFSET
 419              	    .equ    TIM15_AF1,               TIM15_BASE + TIM_AF1_OFFSET
 420              	    .equ    TIM15_AF2,               TIM15_BASE + TIM_AF2_OFFSET
 421              	
 422              	    .equ    TIM15_DCR,               TIM15_BASE + TIM_DCR_OFFSET
 423              	    .equ    TIM15_DMAR,              TIM15_BASE + TIM_DMAR_OFFSET
 424              	
 425              	#--- Genral Purpose Timer - TIM16 / address space:  0x4001_4400 .. 0x4001_47FF
 426              	
 427              	    .equ    TIM16_BASE,              APB2_BASE + 0x4400
 428              	
 429              	    .equ    TIM16_CR1,               TIM16_BASE + TIM_CR1_OFFSET
 430              	    .equ    TIM16_CR2,               TIM16_BASE + TIM_CR2_OFFSET
 431              	
 432              	    .equ    TIM16_DIER,              TIM16_BASE + TIM_DIER_OFFSET
 433              	    .equ    TIM16_SR,                TIM16_BASE + TIM_SR_OFFSET
 434              	    .equ    TIM16_EGR,               TIM16_BASE + TIM_EGR_OFFSET
 435              	    .equ    TIM16_CCMR1,             TIM16_BASE + TIM_CCMR1_OFFSET
 436              	
 437              	    .equ    TIM16_CCER,              TIM16_BASE + TIM_CCER_OFFSET
 438              	    .equ    TIM16_CNT,               TIM16_BASE + TIM_CNT_OFFSET
 439              	    .equ    TIM16_PSC,               TIM16_BASE + TIM_PSC_OFFSET
 440              	    .equ    TIM16_ARR,               TIM16_BASE + TIM_ARR_OFFSET
 441              	    .equ    TIM16_RCR,               TIM16_BASE + TIM_RCR_OFFSET
 442              	    .equ    TIM16_CCR1,              TIM16_BASE + TIM_CCR1_OFFSET
 443              	
 444              	    .equ    TIM16_BDTR,              TIM16_BASE + TIM_BDTR_OFFSET
 445              	
 446              	    .equ    TIM16_DTR2,              TIM16_BASE + TIM_DTR2_OFFSET
 447              	
 448              	    .equ    TIM16_TISEL,             TIM16_BASE + TIM_TISEL_OFFSET
 449              	    .equ    TIM16_AF1,               TIM16_BASE + TIM_AF1_OFFSET
 450              	    .equ    TIM16_AF2,               TIM16_BASE + TIM_AF2_OFFSET
 451              	    .equ    TIM16_OR1,               TIM16_BASE + TIM_OR1_OFFSET
 452              	
 453              	    .equ    TIM16_DCR,               TIM16_BASE + TIM_DCR_OFFSET
 454              	    .equ    TIM16_DMAR,              TIM16_BASE + TIM_DMAR_OFFSET
 455              	
 456              	#--- Genral Purpose Timer - TIM17 / address space:  0x4001_4800 .. 0x4001_4BFF
 457              	
 458              	    .equ    TIM17_BASE,              APB2_BASE + 0x4800
 459              	
 460              	    .equ    TIM17_CR1,               TIM17_BASE + TIM_CR1_OFFSET
 461              	    .equ    TIM17_CR2,               TIM17_BASE + TIM_CR2_OFFSET
 462              	
 463              	    .equ    TIM17_DIER,              TIM17_BASE + TIM_DIER_OFFSET
 464              	    .equ    TIM17_SR,                TIM17_BASE + TIM_SR_OFFSET
 465              	    .equ    TIM17_EGR,               TIM17_BASE + TIM_EGR_OFFSET
 466              	    .equ    TIM17_CCMR1,             TIM17_BASE + TIM_CCMR1_OFFSET
 467              	
 468              	    .equ    TIM17_CCER,              TIM17_BASE + TIM_CCER_OFFSET
 469              	    .equ    TIM17_CNT,               TIM17_BASE + TIM_CNT_OFFSET
 470              	    .equ    TIM17_PSC,               TIM17_BASE + TIM_PSC_OFFSET
 471              	    .equ    TIM17_ARR,               TIM17_BASE + TIM_ARR_OFFSET
 472              	    .equ    TIM17_RCR,               TIM17_BASE + TIM_RCR_OFFSET
 473              	    .equ    TIM17_CCR1,              TIM17_BASE + TIM_CCR1_OFFSET
 474              	
 475              	    .equ    TIM17_BDTR,              TIM17_BASE + TIM_BDTR_OFFSET
 476              	
 477              	    .equ    TIM17_DTR2,              TIM17_BASE + TIM_DTR2_OFFSET
 478              	
 479              	    .equ    TIM17_TISEL,             TIM17_BASE + TIM_TISEL_OFFSET
 480              	    .equ    TIM17_AF1,               TIM17_BASE + TIM_AF1_OFFSET
 481              	    .equ    TIM17_AF2,               TIM17_BASE + TIM_AF2_OFFSET
 482              	    .equ    TIM17_OR1,               TIM17_BASE + TIM_OR1_OFFSET
 483              	
 484              	    .equ    TIM17_DCR,               TIM17_BASE + TIM_DCR_OFFSET
 485              	    .equ    TIM17_DMAR,              TIM17_BASE + TIM_DMAR_OFFSET
 486              	
 487              	#----------------------------------------------------------------------------------------#
 488              	#   Reset and Clock Control
 489              	#
 490              	#   address space:  0x4002_1000 .. 0x4002_13FF
 491              	#----------------------------------------------------------------------------------------#
 492              	
 493              	    .equ    RCC_BASE,               AHB1_BASE + 0x1000
 494              	
 495              	    .equ    RCC_CR,                 RCC_BASE + 0x00
 496              	    .equ    RCC_ICSCR,              RCC_BASE + 0x04
 497              	    .equ    RCC_CFGR,               RCC_BASE + 0x08
 498              	    .equ    RCC_PLLCFGR,            RCC_BASE + 0x0C
 499              	
 500              	    .equ    RCC_CIER,               RCC_BASE + 0x18
 501              	    .equ    RCC_CIFR,               RCC_BASE + 0x1C
 502              	    .equ    RCC_CICR,               RCC_BASE + 0x20
 503              	
 504              	    .equ    RCC_AHB1RSTR,           RCC_BASE + 0x28
 505              	    .equ    RCC_AHB2RSTR,           RCC_BASE + 0x2C
 506              	    .equ    RCC_AHB3RSTR,           RCC_BASE + 0x30
 507              	
 508              	    .equ    RCC_APB1RSTR1,          RCC_BASE + 0x38
 509              	    .equ    RCC_APB1RSTR2,          RCC_BASE + 0x3C
 510              	    .equ    RCC_APB2RSTR,           RCC_BASE + 0x40
 511              	
 512              	    .equ    RCC_AHB1ENR,            RCC_BASE + 0x48
 513              	    .equ    RCC_AHB2ENR,            RCC_BASE + 0x4C
 514              	    .equ    RCC_AHB3ENR,            RCC_BASE + 0x50
 515              	
 516              	    .equ    RCC_APB1ENR1,           RCC_BASE + 0x58
 517              	    .equ    RCC_APB1ENR2,           RCC_BASE + 0x5C
 518              	    .equ    RCC_APB2ENR,            RCC_BASE + 0x60
 519              	
 520              	    .equ    RCC_AHB1SMENR,          RCC_BASE + 0x68
 521              	    .equ    RCC_AHB2SMENR,          RCC_BASE + 0x6C
 522              	    .equ    RCC_AHB3SMENR,          RCC_BASE + 0x70
 523              	
 524              	    .equ    RCC_APB1SMENR1,         RCC_BASE + 0x78
 525              	    .equ    RCC_APB1SMENR2,         RCC_BASE + 0x7C
 526              	    .equ    RCC_APB2SMENR,          RCC_BASE + 0x80
 527              	
 528              	    .equ    RCC_CCIPR,              RCC_BASE + 0x88
 529              	
 530              	    .equ    RCC_BDCR,               RCC_BASE + 0x90
 531              	    .equ    RCC_CSR,                RCC_BASE + 0x94
 532              	    .equ    RCC_CRRCR,              RCC_BASE + 0x98
 533              	    .equ    RCC_CCIPR2,             RCC_BASE + 0x9C
 534              	
 535              	#----------------------------------------------------------------------------------------#
 536              	#   GPIO module common configuration
 537              	#
 538              	#   address space:  0x4800_0000 .. 0x4800_1FFF
 539              	#----------------------------------------------------------------------------------------#
 540              	
 541              	    .equ    GPIO_BASE,              AHB2_BASE
 542              	
 543              	    .equ    GPIO_MODER_OFFSET,      0x00
 544              	    .equ    GPIO_OTYPER_OFFSET,     0x04
 545              	    .equ    GPIO_OSPEEDR_OFFSET,    0x08
 546              	    .equ    GPIO_PUPDR_OFFSET,      0x0C
 547              	    .equ    GPIO_IDR_OFFSET,        0x10
 548              	    .equ    GPIO_ODR_OFFSET,        0x14
 549              	    .equ    GPIO_BSRR_OFFSET,       0x18
 550              	    .equ    GPIO_LCKR_OFFSET,       0x1C
 551              	    .equ    GPIO_AFRL_OFFSET,       0x20
 552              	    .equ    GPIO_AFRH_OFFSET,       0x24
 553              	    .equ    GPIO_BRR_OFFSET,        0x28
 554              	
 555              	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
 556              	
 557              	#--- Port A GPIO configuration / address space: 0x4800_0000 .. 0x4800_03FF
 558              	
 559              	    .equ    GPIOA_BASE,             GPIO_BASE
 560              	
 561              	    .equ    GPIOA_MODER,            GPIOA_BASE + GPIO_MODER_OFFSET
 562              	    .equ    GPIOA_OTYPER,           GPIOA_BASE + GPIO_OTYPER_OFFSET
 563              	    .equ    GPIOA_OSPEEDR,          GPIOA_BASE + GPIO_OSPEEDR_OFFSET
 564              	    .equ    GPIOA_PUPDR,            GPIOA_BASE + GPIO_PUPDR_OFFSET
 565              	    .equ    GPIOA_IDR,              GPIOA_BASE + GPIO_IDR_OFFSET
 566              	    .equ    GPIOA_ODR,              GPIOA_BASE + GPIO_ODR_OFFSET
 567              	    .equ    GPIOA_BSRR,             GPIOA_BASE + GPIO_BSRR_OFFSET
 568              	    .equ    GPIOA_LCKR,             GPIOA_BASE + GPIO_LCKR_OFFSET
 569              	    .equ    GPIOA_AFRL,             GPIOA_BASE + GPIO_AFRL_OFFSET
 570              	    .equ    GPIOA_AFRH,             GPIOA_BASE + GPIO_AFRH_OFFSET
 571              	    .equ    GPIOA_BRR,              GPIOA_BASE + GPIO_BRR_OFFSET
 572              	
 573              	#--- Port B GPIO configuration / address space: 0x4800_0400 .. 0x4800_07FF
 574              	
 575              	    .equ    GPIOB_BASE,             GPIO_BASE + 0x400
 576              	
 577              	    .equ    GPIOB_MODER,            GPIOB_BASE + GPIO_MODER_OFFSET
 578              	    .equ    GPIOB_OTYPER,           GPIOB_BASE + GPIO_OTYPER_OFFSET
 579              	    .equ    GPIOB_OSPEEDR,          GPIOB_BASE + GPIO_OSPEEDR_OFFSET
 580              	    .equ    GPIOB_PUPDR,            GPIOB_BASE + GPIO_PUPDR_OFFSET
 581              	    .equ    GPIOB_IDR,              GPIOB_BASE + GPIO_IDR_OFFSET
 582              	    .equ    GPIOB_ODR,              GPIOB_BASE + GPIO_ODR_OFFSET
 583              	    .equ    GPIOB_BSRR,             GPIOB_BASE + GPIO_BSRR_OFFSET
 584              	    .equ    GPIOB_LCKR,             GPIOB_BASE + GPIO_LCKR_OFFSET
 585              	    .equ    GPIOB_AFRL,             GPIOB_BASE + GPIO_AFRL_OFFSET
 586              	    .equ    GPIOB_AFRH,             GPIOB_BASE + GPIO_AFRH_OFFSET
 587              	    .equ    GPIOB_BRR,              GPIOB_BASE + GPIO_BRR_OFFSET
 588              	
 589              	#--- Port C GPIO configuration / address space: 0x4800_0800 .. 0x4800_0BFF
 590              	
 591              	    .equ    GPIOC_BASE,             GPIO_BASE + 0x800
 592              	
 593              	    .equ    GPIOC_MODER,            GPIOC_BASE + GPIO_MODER_OFFSET
 594              	    .equ    GPIOC_OTYPER,           GPIOC_BASE + GPIO_OTYPER_OFFSET
 595              	    .equ    GPIOC_OSPEEDR,          GPIOC_BASE + GPIO_OSPEEDR_OFFSET
 596              	    .equ    GPIOC_PUPDR,            GPIOC_BASE + GPIO_PUPDR_OFFSET
 597              	    .equ    GPIOC_IDR,              GPIOC_BASE + GPIO_IDR_OFFSET
 598              	    .equ    GPIOC_ODR,              GPIOC_BASE + GPIO_ODR_OFFSET
 599              	    .equ    GPIOC_BSRR,             GPIOC_BASE + GPIO_BSRR_OFFSET
 600              	    .equ    GPIOC_LCKR,             GPIOC_BASE + GPIO_LCKR_OFFSET
 601              	    .equ    GPIOC_AFRL,             GPIOC_BASE + GPIO_AFRL_OFFSET
 602              	    .equ    GPIOC_AFRH,             GPIOC_BASE + GPIO_AFRH_OFFSET
 603              	    .equ    GPIOC_BRR,              GPIOC_BASE + GPIO_BRR_OFFSET
 604              	
 605              	#--- Port D GPIO configuration / address space: 0x4800_0C00 .. 0x4800_0FFF
 606              	
 607              	    .equ    GPIOD_BASE,             GPIO_BASE + 0xC00
 608              	
 609              	    .equ    GPIOD_MODER,            GPIOD_BASE + GPIO_MODER_OFFSET
 610              	    .equ    GPIOD_OTYPER,           GPIOD_BASE + GPIO_OTYPER_OFFSET
 611              	    .equ    GPIOD_OSPEEDR,          GPIOD_BASE + GPIO_OSPEEDR_OFFSET
 612              	    .equ    GPIOD_PUPDR,            GPIOD_BASE + GPIO_PUPDR_OFFSET
 613              	    .equ    GPIOD_IDR,              GPIOD_BASE + GPIO_IDR_OFFSET
 614              	    .equ    GPIOD_ODR,              GPIOD_BASE + GPIO_ODR_OFFSET
 615              	    .equ    GPIOD_BSRR,             GPIOD_BASE + GPIO_BSRR_OFFSET
 616              	    .equ    GPIOD_LCKR,             GPIOD_BASE + GPIO_LCKR_OFFSET
 617              	    .equ    GPIOD_AFRL,             GPIOD_BASE + GPIO_AFRL_OFFSET
 618              	    .equ    GPIOD_AFRH,             GPIOD_BASE + GPIO_AFRH_OFFSET
 619              	    .equ    GPIOD_BRR,              GPIOD_BASE + GPIO_BRR_OFFSET
 620              	
 621              	#--- Port E GPIO configuration / address space: 0x4800_1000 .. 0x4800_13FF
 622              	
 623              	    .equ    GPIOE_BASE,             GPIO_BASE + 0x1000
 624              	
 625              	    .equ    GPIOE_MODER,            GPIOE_BASE + GPIO_MODER_OFFSET
 626              	    .equ    GPIOE_OTYPER,           GPIOE_BASE + GPIO_OTYPER_OFFSET
 627              	    .equ    GPIOE_OSPEEDR,          GPIOE_BASE + GPIO_OSPEEDR_OFFSET
 628              	    .equ    GPIOE_PUPDR,            GPIOE_BASE + GPIO_PUPDR_OFFSET
 629              	    .equ    GPIOE_IDR,              GPIOE_BASE + GPIO_IDR_OFFSET
 630              	    .equ    GPIOE_ODR,              GPIOE_BASE + GPIO_ODR_OFFSET
 631              	    .equ    GPIOE_BSRR,             GPIOE_BASE + GPIO_BSRR_OFFSET
 632              	    .equ    GPIOE_LCKR,             GPIOE_BASE + GPIO_LCKR_OFFSET
 633              	    .equ    GPIOE_AFRL,             GPIOE_BASE + GPIO_AFRL_OFFSET
 634              	    .equ    GPIOE_AFRH,             GPIOE_BASE + GPIO_AFRH_OFFSET
 635              	    .equ    GPIOE_BRR,              GPIOE_BASE + GPIO_BRR_OFFSET
 636              	
 637              	#--- Port F GPIO configuration / address space: 0x4800_1400 .. 0x4800_17FF
 638              	
 639              	    .equ    GPIOF_BASE,             GPIO_BASE + 0x1400
 640              	
 641              	    .equ    GPIOF_MODER,            GPIOF_BASE + GPIO_MODER_OFFSET
 642              	    .equ    GPIOF_OTYPER,           GPIOF_BASE + GPIO_OTYPER_OFFSET
 643              	    .equ    GPIOF_OSPEEDR,          GPIOF_BASE + GPIO_OSPEEDR_OFFSET
 644              	    .equ    GPIOF_PUPDR,            GPIOF_BASE + GPIO_PUPDR_OFFSET
 645              	    .equ    GPIOF_IDR,              GPIOF_BASE + GPIO_IDR_OFFSET
 646              	    .equ    GPIOF_ODR,              GPIOF_BASE + GPIO_ODR_OFFSET
 647              	    .equ    GPIOF_BSRR,             GPIOF_BASE + GPIO_BSRR_OFFSET
 648              	    .equ    GPIOF_LCKR,             GPIOF_BASE + GPIO_LCKR_OFFSET
 649              	    .equ    GPIOF_AFRL,             GPIOF_BASE + GPIO_AFRL_OFFSET
 650              	    .equ    GPIOF_AFRH,             GPIOF_BASE + GPIO_AFRH_OFFSET
 651              	    .equ    GPIOF_BRR,              GPIOF_BASE + GPIO_BRR_OFFSET
 652              	
 653              	#--- Port G GPIO configuration / address space: 0x4800_1800 .. 0x4800_1BFF
 654              	
 655              	    .equ    GPIOG_BASE,             GPIO_BASE + 0x1800
 656              	
 657              	    .equ    GPIOG_MODER,            GPIOG_BASE + GPIO_MODER_OFFSET
 658              	    .equ    GPIOG_OTYPER,           GPIOG_BASE + GPIO_OTYPER_OFFSET
 659              	    .equ    GPIOG_OSPEEDR,          GPIOG_BASE + GPIO_OSPEEDR_OFFSET
 660              	    .equ    GPIOG_PUPDR,            GPIOG_BASE + GPIO_PUPDR_OFFSET
 661              	    .equ    GPIOG_IDR,              GPIOG_BASE + GPIO_IDR_OFFSET
 662              	    .equ    GPIOG_ODR,              GPIOG_BASE + GPIO_ODR_OFFSET
 663              	    .equ    GPIOG_BSRR,             GPIOG_BASE + GPIO_BSRR_OFFSET
 664              	    .equ    GPIOG_LCKR,             GPIOG_BASE + GPIO_LCKR_OFFSET
 665              	    .equ    GPIOG_AFRL,             GPIOG_BASE + GPIO_AFRL_OFFSET
 666              	    .equ    GPIOG_AFRH,             GPIOG_BASE + GPIO_AFRH_OFFSET
 667              	    .equ    GPIOG_BRR,              GPIOG_BASE + GPIO_BRR_OFFSET
 668              	
 669              	#----------------------------------------------------------------------------------------#
 670              	#   System Control Space
 671              	#
 672              	#   address space:  0xE000_E000 .. 0xE000_EFFF
 673              	#----------------------------------------------------------------------------------------#
 674              	
 675              	    .equ    SCS_BASE,               PPB_BASE + 0xE000
 676              	
 677              	#----------------------------------------------------------------------------------------#
 678              	#   System Timer (SysTick)
 679              	#
 680              	#   address space:  0xE000_E010 .. 0xE000_E01F
 681              	#----------------------------------------------------------------------------------------#
 682              	
 683              	    .equ    STK_BASE,               SCS_BASE + 10       // 0xE000_E010
 684              	
 685              	    .equ    STK_CTRL,               SCS_BASE + 0x00
 686              	    .equ    STK_LOAD,               SCS_BASE + 0x04
 687              	    .equ    STK_VAL,                SCS_BASE + 0x08
 688              	    .equ    STK_CALIB,              SCS_BASE + 0x0C
 689              	
 690              	#----------------------------------------------------------------------------------------#
 691              	#   Nested Vector Interrupt Controller
 692              	#
 693              	#   address space:  0xE000_E100 .. 0xE000_E4EF
 694              	#----------------------------------------------------------------------------------------#
 695              	
 696              	    .equ    NVIC_BASE,              SCS_BASE + 0x100    // 0xE000_E100
 697              	
 698              	    .equ    NVIC_ISER0,             NVIC_BASE + 0x00
 699              	    .equ    NVIC_ISER1,             NVIC_BASE + 0x04
 700              	    .equ    NVIC_ISER2,             NVIC_BASE + 0x08
 701              	    .equ    NVIC_ISER3,             NVIC_BASE + 0x0C
 702              	
 703              	    .equ    NVIC_ICER0,             NVIC_BASE + 0x80
 704              	    .equ    NVIC_ICER1,             NVIC_BASE + 0x84
 705              	    .equ    NVIC_ICER2,             NVIC_BASE + 0x88
 706              	    .equ    NVIC_ICER3,             NVIC_BASE + 0x8C
 707              	
 708              	    .equ    NVIC_ISPR0,             NVIC_BASE + 0x100
 709              	    .equ    NVIC_ISPR1,             NVIC_BASE + 0x104
 710              	    .equ    NVIC_ISPR2,             NVIC_BASE + 0x108
 711              	    .equ    NVIC_ISPR3,             NVIC_BASE + 0x10C
 712              	
 713              	    .equ    NVIC_ICPR0,             NVIC_BASE + 0x180
 714              	    .equ    NVIC_ICPR1,             NVIC_BASE + 0x184
 715              	    .equ    NVIC_ICPR2,             NVIC_BASE + 0x188
 716              	    .equ    NVIC_ICPR3,             NVIC_BASE + 0x18C
 717              	
 718              	    .equ    NVIC_IABR0,             NVIC_BASE + 0x200
 719              	    .equ    NVIC_IABR1,             NVIC_BASE + 0x204
 720              	    .equ    NVIC_IABR2,             NVIC_BASE + 0x208
 721              	    .equ    NVIC_IABR3,             NVIC_BASE + 0x20C
 722              	
 723              	    .equ    NVIC_IPR0,              NVIC_BASE + 0x300
 724              	    .equ    NVIC_IPR1,              NVIC_BASE + 0x304
 725              	    .equ    NVIC_IPR2,              NVIC_BASE + 0x308
 726              	    .equ    NVIC_IPR3,              NVIC_BASE + 0x30C
 727              	    .equ    NVIC_IPR4,              NVIC_BASE + 0x310
 728              	    .equ    NVIC_IPR5,              NVIC_BASE + 0x314
 729              	    .equ    NVIC_IPR6,              NVIC_BASE + 0x318
 730              	    .equ    NVIC_IPR7,              NVIC_BASE + 0x31C
 731              	    .equ    NVIC_IPR8,              NVIC_BASE + 0x320
 732              	    .equ    NVIC_IPR9,              NVIC_BASE + 0x324
 733              	    .equ    NVIC_IPR10,             NVIC_BASE + 0x328
 734              	    .equ    NVIC_IPR11,             NVIC_BASE + 0x32C
 735              	    .equ    NVIC_IPR12,             NVIC_BASE + 0x330
 736              	    .equ    NVIC_IPR13,             NVIC_BASE + 0x334
 737              	    .equ    NVIC_IPR14,             NVIC_BASE + 0x338
 738              	    .equ    NVIC_IPR15,             NVIC_BASE + 0x33C
 739              	    .equ    NVIC_IPR16,             NVIC_BASE + 0x340
 740              	    .equ    NVIC_IPR17,             NVIC_BASE + 0x344
 741              	    .equ    NVIC_IPR18,             NVIC_BASE + 0x348
 742              	    .equ    NVIC_IPR19,             NVIC_BASE + 0x34C
 743              	    .equ    NVIC_IPR20,             NVIC_BASE + 0x350
 744              	    .equ    NVIC_IPR21,             NVIC_BASE + 0x354
 745              	    .equ    NVIC_IPR22,             NVIC_BASE + 0x358
 746              	    .equ    NVIC_IPR23,             NVIC_BASE + 0x35C
 747              	    .equ    NVIC_IPR24,             NVIC_BASE + 0x360
 748              	    .equ    NVIC_IPR25,             NVIC_BASE + 0x364
 749              	
 750              	    .equ    STIR,                   NVIC_BASE + 0xE00
 751              	
 752              	#----------------------------------------------------------------------------------------#
 753              	#   MCU Debug Component
 754              	#
 755              	#   address space:  0xE004_2000 .. 0xE004_2013
 756              	#----------------------------------------------------------------------------------------#
 757              	
 758              	    .equ    DBGMCU_BASE,            PPB_BASE + 0x42000
 759              	
 760              	    .equ    DBGMCU_IDCODE,          DBGMCU_BASE + 0x00
 761              	    .equ    DBGMCU_CR,              DBGMCU_BASE + 0x04
 762              	    .equ    DBGMCU_APB1FZR1,        DBGMCU_BASE + 0x08
 763              	    .equ    DBGMCU_APB1FZR2,        DBGMCU_BASE + 0x0C
 764              	    .equ    DBGMCU_APB2DZR,         DBGMCU_BASE + 0x10
  40              	
  41              	
  42              	#----------------------------------------------------------------------------------------#
  43              	    .section .vectortable,"a"   // vector table at begin of ROM
  44              	#----------------------------------------------------------------------------------------#
  45              	
  46              	    .align  2
  47              	
  48 0000 00400020 	    .word   0x20004000          // initial Stack Pointer:   0x20000000 (RAM base) + 0x4000 (16K SRA
  49 0004 01040008 	    .word   0x08000401          // initial Program Counter
  50 0008 00000000 	    .word   _nmi                // NMI
  51 000c 00000000 	    .word   _hardf              // hard fault
  52              	
  53              	
  54              	#----------------------------------------------------------------------------------------#
  55              	    .text                       // section .text (default section for program code)
  56              	#----------------------------------------------------------------------------------------#
  57              	
  58              	    .align  2
  59              	    .syntax unified
  60              	    .thumb
  61              	    .thumb_func
  62              	    .global init
  64              	init:
  65 0000 72B6     	    CPSID   i                   // disable interrupts globally
  66              	
  67 0002 0020     	    MOVS    r0, #0              // safely initialize the GPRs
  68 0004 0021     	    MOVS    r1, #0
  69 0006 0022     	    MOVS    r2, #0
  70 0008 0023     	    MOVS    r3, #0
  71 000a 0024     	    MOVS    r4, #0
  72 000c 0025     	    MOVS    r5, #0
  73 000e 0026     	    MOVS    r6, #0
  74 0010 0027     	    MOVS    r7, #0
  75 0012 8046     	    MOV     r8, r0
  76 0014 8146     	    MOV     r9, r0
  77 0016 8246     	    MOV     r10, r0
  78 0018 8346     	    MOV     r11, r0
  79 001a 8446     	    MOV     r12, r0
  80              	
  81              	#--- enable port clocking
  82 001c 2649     	    LDR     r1, =RCC_AHB2ENR    // load address of RCC_AHB2ENR
  83 001e 4FF00302 	    MOV     r2, #0x03           // load mask for adjusting port clock gating (A and B: LEDs and but
  84 0022 0868     	    LDR     r0, [r1, #0]        // get current value of RCC_AHB2ENR
  85 0024 1043     	    ORRS    r0, r0, r2          // configure clock gating for ports
  86 0026 0860     	    STR     r0, [r1, #0]        // apply settings
  87              	
  88              	#--- port init
  89              	#- LEDs
  90 0028 4FF09041 	    LDR     r1, =GPIOA_MODER    // load port A mode register address
  91 002c FF22     	    MOVS    r2, #0xFF            // prepare mask Zero all
  92 002e 0868     	    LDR     r0, [r1, #0]        // get current value of port A mode register
  93 0030 9043     	    BICS    r0, r2              // delete bits
  94 0032 5522     	    MOVS    r2, #0x55           // load configuration mask Ouput All
  95 0034 1043     	    ORRS    r0, r0, r2          // apply mask
  96 0036 0860     	    STR     r0, [r1, #0]        // apply result to port A mode register
  97              	
  98              	#- switch LEDs off
  99 0038 2049     	    LDR     r1, =GPIOA_ODR      // load port A output data register
 100 003a 0F22     	    MOVS    r2, #0xF           // load mask for all LEDs
 101 003c 0868     	    LDR     r0, [r1, #0]        // get current value of GPIOA
 102 003e 1043     	    ORRS    r0, r0, r2          // configure pin state
 103 0040 0860     	    STR     r0, [r1, #0]        // apply settings
 104              	
 105              	
 106              	#- buttons
 107              	    //LDR
 108 0042 4FF00103 	    MOV     r3, #0x1
 109 0046 4FF00004 	    MOV     r4, #0x0
 110              	
 111 004a 1D49     	    LDR     r1, =GPIOB_MODER    // load port B mode register address
 112 004c 0322     	    MOVS    r2, #0x03           // prepare mask Zero all
 113 004e 0868     	    LDR     r0, [r1, #0]        // get current value of port A mode register
 114 0050 9043     	    BICS    r0, r2              // delete bits
 115 0052 4FEA8212 	    LSL		r2, r2, #6			// offset for S3
 116 0056 9043     	    BICS    r0, r2              // delete bits
 117              	
 118 0058 0860     	    STR     r0, [r1, #0]        // apply result to port A mode register
 119              	
 120              	
 121 005a 1A49     	    LDR     r1, =GPIOB_PUPDR    // load port B mode register address
 122 005c 0322     	    MOVS    r2, #0x03           // prepare mask Zero all
 123 005e 0868     	    LDR     r0, [r1, #0]        // get current value of port A mode register
 124 0060 9043     	    BICS    r0, r2              // delete bits
 125 0062 4FEA8212 	    LSL		r2, r2, #6			// offset for S3
 126 0066 9043     	    BICS    r0, r2              // delete bits
 127 0068 0122     	    MOVS    r2, #0x1           // load configuration mask Output All
 128 006a 1043     	    ORRS    r0, r0, r2          // apply mask
 129 006c 4FEA8212 	    LSL		r2, r2, #6			// offset for S3
 130 0070 1043     	    ORRS    r0, r0, r2          // apply mask
 131 0072 0860     	    STR     r0, [r1, #0]        // apply result to port A mode register
 132              	
 133              	
 134 0074 62B6     	    CPSIE   i                   // enable interrupts globally
 135              	
 136              	
 137              	#----------------------------------------------------------------------------------------#
 138              	
 139 0076 00BF     	    .align  2
 140              	    .syntax unified
 141              	    .thumb
 142              	    .thumb_func
 143              	    .global main
 145              	main:
 146 0078 1349     	    LDR     r1, =GPIOB_IDR 		//Load input data register
 147 007a 0868     	    LDR     r0,  [r1, #0]
 148 007c 4FF0F702 	    MOV     r2, #0xF7
 149 0080 9043     	    BICS    r0, r2
 150 0082 0828     	    CMP     r0, #0x8
 151 0084 08BF     	    IT      EQ
 152 0086 FFF7FEFF 	    BLEQ    todolight
 153              	
 154              	
 155 008a FFF7FEFF 	    BL      delay
 156              	
 157              	    /* ... replace current code here ... */
 158              	
 159 008e FFF7FEBF 	    B       main
 160              	
 161              	
 162              	#----------------------------------------------------------------------------------------#
 163 0092 00BF     	    .align  2
 164              	    .syntax unified
 165              	    .thumb
 166              	    .thumb_func
 167              	    .global todolight
 169              	
 170              	todolight:
 171 0094 0949     	    LDR     r1, =GPIOA_ODR      // load port A output data register
 172 0096 0868     	    LDR     r0, [r1, #0]        // get current value of GPIOA
 173 0098 0322     	    MOVS    r2, #0x03           // load mask for LED 0
 174 009a 5040     	    EORS    r0, r0, r2
 175 009c 0860     	    STR     r0, [r1, #0]
 176 009e 7047     	    BX      lr                  // ...
 177              	
 178              	#----------------------------------------------------------------------------------------#
 179              	    .align  2
 180              	    .syntax unified
 181              	    .thumb
 182              	    .thumb_func
 183              	    .global delay
 185              	
 186              	delay:
 187 00a0 0026     	    MOVS    r6, #0              // ...
 188 00a2 4FF48007 	    LDR     r7, =0x400000       // ...
 189              	.L1:
 190 00a6 0136     	    ADDS    r6, r6, #1          // ...
 191 00a8 BE42     	    CMP     r6, r7              // ...
 192 00aa FCD1     	    BNE     .L1                 // ...
 193 00ac 7047     	    BX      lr                  // ...
 194              	
 195              	
 196              	#----------------------------------------------------------------------------------------#
 197              	
 198 00ae 00BF     	    .align 2
 199              	    .global stop
 200              	stop:
 201 00b0 00BF     	    NOP                         // do nothing (NOP is here to avoid a debugger crash, only)
 202 00b2 FFF7FEBF 	    B       stop                // if this line is reached, something went wrong
 203              	
 204              	
 205              	#----------------------------------------------------------------------------------------#
 206              	.lp1:           // this label is only to nicify the line up in the .lst file
 207 00b6 00004C10 	    .ltorg
 207      02401400 
 207      00480004 
 207      00480C04 
 207      00481004 
 208              	#----------------------------------------------------------------------------------------#
 209              	
 210              	
 211              	#----------------------------------------------------------------------------------------#
 212              	    .section .exhand,"ax"       // section for exception handlers
 213              	#----------------------------------------------------------------------------------------#
 214              	
 215              	    .align  2
 216              	    .syntax unified
 217              	    .thumb
 219              	_nmi:
 220              	#--- enable clock
 221 0000 1349     	    LDR     r1, =RCC_AHB2ENR    // load address of RCC_AHB2ENR
 222 0002 4FF00102 	    MOV     r2, #0x01           // load mask
 223 0006 0868     	    LDR     r0, [r1, #0]        // get current value of RCC_AHB2ENR
 224 0008 1043     	    ORRS    r0, r0, r2          // configure clock gating for port
 225 000a 0860     	    STR     r0, [r1, #0]        // apply settings
 226              	
 227              	#--- init pins
 228 000c 4FF09041 	    LDR     r1, =GPIOA_MODER    // load port A mode register address
 229 0010 FF22     	    MOVS    r2, #0xFF           // prepare mask
 230 0012 0868     	    LDR     r0, [r1, #0]        // get current value of port A mode register
 231 0014 9043     	    BICS    r0, r0, r2          // delete bits
 232 0016 4422     	    MOVS    r2, #0x44           // load configuration mask
 233 0018 1043     	    ORRS    r0, r0, r2          // configure pins
 234 001a 0860     	    STR     r0, [r1, #0]        // apply settings to port A mode register
 235              	
 236              	#--- switch some LEDs on
 237 001c 0D49     	    LDR     r1, =GPIOA_ODR      // load port A data output register address
 238 001e 0A22     	    MOVS    r2, #0x0A           // load mask for blue and yellow LED
 239 0020 0868     	    LDR     r0, [r1, #0]
 240 0022 9043     	    BICS    r0, r0, r2
 241 0024 0860     	    STR     r0, [r1, #0]        // switch LEDs on
 242              	
 243 0026 EBE7     	    B   _nmi
 244              	
 245              	
 246              	#----------------------------------------------------------------------------------------#
 247              	
 248              	    .align  2
 249              	    .syntax unified
 250              	    .thumb
 252              	_hardf:
 253              	#--- enable clock
 254 0028 0949     	    LDR     r1, =RCC_AHB2ENR    // load address of RCC_AHB2ENR
 255 002a 4FF00102 	    MOV     r2, #0x01           // load mask
 256 002e 0868     	    LDR     r0, [r1, #0]        // get current value of RCC_AHB2ENR
 257 0030 1043     	    ORRS    r0, r0, r2          // configure clock gating for port
 258 0032 0860     	    STR     r0, [r1, #0]        // apply settings
 259              	
 260              	#--- init pins
 261 0034 4FF09041 	    LDR     r1, =GPIOA_MODER    // load port A mode register address
 262 0038 FF22     	    MOVS    r2, #0xFF           // prepare mask
 263 003a 0868     	    LDR     r0, [r1, #0]        // get current value of port A mode register
 264 003c 9043     	    BICS    r0, r0, r2          // delete bits
 265 003e 1122     	    MOVS    r2, #0x11           // load configuration mask
 266 0040 1043     	    ORRS    r0, r0, r2          // configure pins
 267 0042 0860     	    STR     r0, [r1, #0]        // apply settings to port A mode register
 268              	
 269              	#--- switch some LEDs on
 270 0044 0349     	    LDR     r1, =GPIOA_ODR      // load port A data output register address
 271 0046 0522     	    MOVS    r2, #0x05           // load mask for red and green LED
 272 0048 0868     	    LDR     r0, [r1, #0]
 273 004a 9043     	    BICS    r0, r0, r2
 274 004c 0860     	    STR     r0, [r1, #0]        // switch LEDs on
 275              	
 276 004e EBE7     	    B       _hardf
 277              	
 278              	
 279              	#----------------------------------------------------------------------------------------#
 280              	.lp2:           // this label is only to nicify the line up in the .lst file
 281 0050 4C100240 	    .ltorg
 281      14000048 
 282              	#----------------------------------------------------------------------------------------#
 283              	
 284              	    .end
DEFINED SYMBOLS
         G431_addr.s:39     *ABS*:0000000040000000 APB1_BASE
         G431_addr.s:40     *ABS*:0000000040010000 APB2_BASE
         G431_addr.s:41     *ABS*:0000000040020000 AHB1_BASE
         G431_addr.s:42     *ABS*:0000000048000000 AHB2_BASE
         G431_addr.s:43     *ABS*:00000000a0000000 AHB3_BASE
         G431_addr.s:44     *ABS*:00000000e0000000 PPB_BASE
         G431_addr.s:52     *ABS*:0000000040010000 SYSCFG_BASE
         G431_addr.s:54     *ABS*:0000000040010000 SYSCFG_MEMRMP
         G431_addr.s:55     *ABS*:0000000040010004 SYSCFG_CFGR1
         G431_addr.s:56     *ABS*:0000000040010008 SYSCFG_EXTICR1
         G431_addr.s:57     *ABS*:000000004001000c SYSCFG_EXTICR2
         G431_addr.s:58     *ABS*:0000000040010010 SYSCFG_EXTICR3
         G431_addr.s:59     *ABS*:0000000040010014 SYSCFG_EXTICR4
         G431_addr.s:60     *ABS*:0000000040010018 SYSCFG_SCSR
         G431_addr.s:61     *ABS*:000000004001001c SYSCFG_CFGR2
         G431_addr.s:62     *ABS*:0000000040010020 SYSCFG_SWPR
         G431_addr.s:63     *ABS*:0000000040010024 SYSCFG_SKR
         G431_addr.s:71     *ABS*:0000000040010400 EXTI_BASE
         G431_addr.s:73     *ABS*:0000000040010400 EXTI_IMR1
         G431_addr.s:74     *ABS*:0000000040010404 EXTI_EMR1
         G431_addr.s:75     *ABS*:0000000040010408 EXTI_RTSR1
         G431_addr.s:76     *ABS*:000000004001040c EXTI_FTSR1
         G431_addr.s:77     *ABS*:0000000040010410 EXTI_SWIER1
         G431_addr.s:78     *ABS*:0000000040010414 EXTI_PR1
         G431_addr.s:80     *ABS*:0000000040010420 EXTI_IMR2
         G431_addr.s:81     *ABS*:0000000040010424 EXTI_EMR2
         G431_addr.s:82     *ABS*:0000000040010428 EXTI_RTSR2
         G431_addr.s:83     *ABS*:000000004001042c EXTI_FTSR2
         G431_addr.s:84     *ABS*:0000000040010430 EXTI_SWIER2
         G431_addr.s:85     *ABS*:0000000040010434 EXTI_PR2
         G431_addr.s:109    *ABS*:0000000000000000 TIM_CR1_OFFSET
         G431_addr.s:110    *ABS*:0000000000000004 TIM_CR2_OFFSET
         G431_addr.s:111    *ABS*:0000000000000008 TIM_SMCR_OFFSET
         G431_addr.s:112    *ABS*:000000000000000c TIM_DIER_OFFSET
         G431_addr.s:113    *ABS*:0000000000000010 TIM_SR_OFFSET
         G431_addr.s:114    *ABS*:0000000000000014 TIM_EGR_OFFSET
         G431_addr.s:115    *ABS*:0000000000000018 TIM_CCMR1_OFFSET
         G431_addr.s:116    *ABS*:000000000000001c TIM_CCMR2_OFFSET
         G431_addr.s:117    *ABS*:0000000000000020 TIM_CCER_OFFSET
         G431_addr.s:118    *ABS*:0000000000000024 TIM_CNT_OFFSET
         G431_addr.s:119    *ABS*:0000000000000028 TIM_PSC_OFFSET
         G431_addr.s:120    *ABS*:000000000000002c TIM_ARR_OFFSET
         G431_addr.s:121    *ABS*:0000000000000030 TIM_RCR_OFFSET
         G431_addr.s:122    *ABS*:0000000000000034 TIM_CCR1_OFFSET
         G431_addr.s:123    *ABS*:0000000000000038 TIM_CCR2_OFFSET
         G431_addr.s:124    *ABS*:000000000000003c TIM_CCR3_OFFSET
         G431_addr.s:125    *ABS*:0000000000000040 TIM_CCR4_OFFSET
         G431_addr.s:126    *ABS*:0000000000000044 TIM_BDTR_OFFSET
         G431_addr.s:127    *ABS*:0000000000000048 TIM_CCR5_OFFSET
         G431_addr.s:128    *ABS*:000000000000004c TIM_CCR6_OFFSET
         G431_addr.s:129    *ABS*:0000000000000050 TIM_CCMR3_OFFSET
         G431_addr.s:130    *ABS*:0000000000000054 TIM_DTR2_OFFSET
         G431_addr.s:131    *ABS*:0000000000000058 TIM_ECR_OFFSET
         G431_addr.s:132    *ABS*:000000000000005c TIM_TISEL_OFFSET
         G431_addr.s:133    *ABS*:0000000000000060 TIM_AF1_OFFSET
         G431_addr.s:134    *ABS*:0000000000000064 TIM_AF2_OFFSET
         G431_addr.s:135    *ABS*:0000000000000068 TIM_OR1_OFFSET
         G431_addr.s:137    *ABS*:00000000000003dc TIM_DCR_OFFSET
         G431_addr.s:138    *ABS*:00000000000003e0 TIM_DMAR_OFFSET
         G431_addr.s:144    *ABS*:0000000040000000 TIM2_BASE
         G431_addr.s:146    *ABS*:0000000040000000 TIM2_CR1
         G431_addr.s:147    *ABS*:0000000040000004 TIM2_CR2
         G431_addr.s:148    *ABS*:0000000040000008 TIM2_SMCR
         G431_addr.s:149    *ABS*:000000004000000c TIM2_DIER
         G431_addr.s:150    *ABS*:0000000040000010 TIM2_SR
         G431_addr.s:151    *ABS*:0000000040000014 TIM2_EGR
         G431_addr.s:152    *ABS*:0000000040000018 TIM2_CCMR1
         G431_addr.s:153    *ABS*:000000004000001c TIM2_CCMR2
         G431_addr.s:154    *ABS*:0000000040000020 TIM2_CCER
         G431_addr.s:155    *ABS*:0000000040000024 TIM2_CNT
         G431_addr.s:156    *ABS*:0000000040000028 TIM2_PSC
         G431_addr.s:157    *ABS*:000000004000002c TIM2_ARR
         G431_addr.s:159    *ABS*:0000000040000034 TIM2_CCR1
         G431_addr.s:160    *ABS*:0000000040000038 TIM2_CCR2
         G431_addr.s:161    *ABS*:000000004000003c TIM2_CCR3
         G431_addr.s:162    *ABS*:0000000040000040 TIM2_CCR4
         G431_addr.s:164    *ABS*:0000000040000058 TIM2_ECR
         G431_addr.s:165    *ABS*:000000004000005c TIM2_TISEL
         G431_addr.s:166    *ABS*:0000000040000058 TIM2_AF1
         G431_addr.s:167    *ABS*:0000000040000058 TIM2_AF2
         G431_addr.s:169    *ABS*:00000000400003dc TIM2_DCR
         G431_addr.s:170    *ABS*:00000000400003e0 TIM2_DMAR
         G431_addr.s:174    *ABS*:0000000040000400 TIM3_BASE
         G431_addr.s:176    *ABS*:0000000040000400 TIM3_CR1
         G431_addr.s:177    *ABS*:0000000040000404 TIM3_CR2
         G431_addr.s:178    *ABS*:0000000040000408 TIM3_SMCR
         G431_addr.s:179    *ABS*:000000004000040c TIM3_DIER
         G431_addr.s:180    *ABS*:0000000040000410 TIM3_SR
         G431_addr.s:181    *ABS*:0000000040000414 TIM3_EGR
         G431_addr.s:182    *ABS*:0000000040000418 TIM3_CCMR1
         G431_addr.s:183    *ABS*:000000004000041c TIM3_CCMR2
         G431_addr.s:184    *ABS*:0000000040000420 TIM3_CCER
         G431_addr.s:185    *ABS*:0000000040000424 TIM3_CNT
         G431_addr.s:186    *ABS*:0000000040000428 TIM3_PSC
         G431_addr.s:187    *ABS*:000000004000042c TIM3_ARR
         G431_addr.s:189    *ABS*:0000000040000434 TIM3_CCR1
         G431_addr.s:190    *ABS*:0000000040000438 TIM3_CCR2
         G431_addr.s:191    *ABS*:000000004000043c TIM3_CCR3
         G431_addr.s:192    *ABS*:0000000040000440 TIM3_CCR4
         G431_addr.s:194    *ABS*:0000000040000458 TIM3_ECR
         G431_addr.s:195    *ABS*:000000004000045c TIM3_TISEL
         G431_addr.s:196    *ABS*:0000000040000458 TIM3_AF1
         G431_addr.s:197    *ABS*:0000000040000458 TIM3_AF2
         G431_addr.s:199    *ABS*:00000000400007dc TIM3_DCR
         G431_addr.s:200    *ABS*:00000000400007e0 TIM3_DMAR
         G431_addr.s:204    *ABS*:0000000040000800 TIM4_BASE
         G431_addr.s:206    *ABS*:0000000040000800 TIM4_CR1
         G431_addr.s:207    *ABS*:0000000040000804 TIM4_CR2
         G431_addr.s:208    *ABS*:0000000040000808 TIM4_SMCR
         G431_addr.s:209    *ABS*:000000004000080c TIM4_DIER
         G431_addr.s:210    *ABS*:0000000040000810 TIM4_SR
         G431_addr.s:211    *ABS*:0000000040000814 TIM4_EGR
         G431_addr.s:212    *ABS*:0000000040000818 TIM4_CCMR1
         G431_addr.s:213    *ABS*:000000004000081c TIM4_CCMR2
         G431_addr.s:214    *ABS*:0000000040000820 TIM4_CCER
         G431_addr.s:215    *ABS*:0000000040000824 TIM4_CNT
         G431_addr.s:216    *ABS*:0000000040000828 TIM4_PSC
         G431_addr.s:217    *ABS*:000000004000082c TIM4_ARR
         G431_addr.s:219    *ABS*:0000000040000834 TIM4_CCR1
         G431_addr.s:220    *ABS*:0000000040000838 TIM4_CCR2
         G431_addr.s:221    *ABS*:000000004000083c TIM4_CCR3
         G431_addr.s:222    *ABS*:0000000040000840 TIM4_CCR4
         G431_addr.s:224    *ABS*:0000000040000858 TIM4_ECR
         G431_addr.s:225    *ABS*:000000004000085c TIM4_TISEL
         G431_addr.s:226    *ABS*:0000000040000858 TIM4_AF1
         G431_addr.s:227    *ABS*:0000000040000858 TIM4_AF2
         G431_addr.s:229    *ABS*:0000000040000bdc TIM4_DCR
         G431_addr.s:230    *ABS*:0000000040000be0 TIM4_DMAR
         G431_addr.s:234    *ABS*:0000000040000c00 TIM5_BASE
         G431_addr.s:236    *ABS*:0000000040000c00 TIM5_CR1
         G431_addr.s:237    *ABS*:0000000040000c04 TIM5_CR2
         G431_addr.s:238    *ABS*:0000000040000c08 TIM5_SMCR
         G431_addr.s:239    *ABS*:0000000040000c0c TIM5_DIER
         G431_addr.s:240    *ABS*:0000000040000c10 TIM5_SR
         G431_addr.s:241    *ABS*:0000000040000c14 TIM5_EGR
         G431_addr.s:242    *ABS*:0000000040000c18 TIM5_CCMR1
         G431_addr.s:243    *ABS*:0000000040000c1c TIM5_CCMR2
         G431_addr.s:244    *ABS*:0000000040000c20 TIM5_CCER
         G431_addr.s:245    *ABS*:0000000040000c24 TIM5_CNT
         G431_addr.s:246    *ABS*:0000000040000c28 TIM5_PSC
         G431_addr.s:247    *ABS*:0000000040000c2c TIM5_ARR
         G431_addr.s:249    *ABS*:0000000040000c34 TIM5_CCR1
         G431_addr.s:250    *ABS*:0000000040000c38 TIM5_CCR2
         G431_addr.s:251    *ABS*:0000000040000c3c TIM5_CCR3
         G431_addr.s:252    *ABS*:0000000040000c40 TIM5_CCR4
         G431_addr.s:254    *ABS*:0000000040000c58 TIM5_ECR
         G431_addr.s:255    *ABS*:0000000040000c5c TIM5_TISEL
         G431_addr.s:256    *ABS*:0000000040000c58 TIM5_AF1
         G431_addr.s:257    *ABS*:0000000040000c58 TIM5_AF2
         G431_addr.s:259    *ABS*:0000000040000fdc TIM5_DCR
         G431_addr.s:260    *ABS*:0000000040000fe0 TIM5_DMAR
         G431_addr.s:264    *ABS*:0000000040001000 TIM6_BASE
         G431_addr.s:266    *ABS*:0000000040001000 TIM6_CR1
         G431_addr.s:267    *ABS*:0000000040001004 TIM6_CR2
         G431_addr.s:269    *ABS*:000000004000100c TIM6_DIER
         G431_addr.s:270    *ABS*:0000000040001010 TIM6_SR
         G431_addr.s:271    *ABS*:0000000040001014 TIM6_EGR
         G431_addr.s:273    *ABS*:0000000040001024 TIM6_CNT
         G431_addr.s:274    *ABS*:0000000040001028 TIM6_PSC
         G431_addr.s:275    *ABS*:000000004000102c TIM6_ARR
         G431_addr.s:279    *ABS*:0000000040001400 TIM7_BASE
         G431_addr.s:281    *ABS*:0000000040001400 TIM7_CR1
         G431_addr.s:282    *ABS*:0000000040001404 TIM7_CR2
         G431_addr.s:284    *ABS*:000000004000140c TIM7_DIER
         G431_addr.s:285    *ABS*:0000000040001410 TIM7_SR
         G431_addr.s:286    *ABS*:0000000040001414 TIM7_EGR
         G431_addr.s:288    *ABS*:0000000040001424 TIM7_CNT
         G431_addr.s:289    *ABS*:0000000040001428 TIM7_PSC
         G431_addr.s:290    *ABS*:000000004000142c TIM7_ARR
         G431_addr.s:294    *ABS*:0000000040012c00 TIM1_BASE
         G431_addr.s:296    *ABS*:0000000040012c00 TIM1_CR1
         G431_addr.s:297    *ABS*:0000000040012c04 TIM1_CR2
         G431_addr.s:298    *ABS*:0000000040012c08 TIM1_SMCR
         G431_addr.s:299    *ABS*:0000000040012c0c TIM1_DIER
         G431_addr.s:300    *ABS*:0000000040012c10 TIM1_SR
         G431_addr.s:301    *ABS*:0000000040012c14 TIM1_EGR
         G431_addr.s:302    *ABS*:0000000040012c18 TIM1_CCMR1
         G431_addr.s:303    *ABS*:0000000040012c1c TIM1_CCMR2
         G431_addr.s:304    *ABS*:0000000040012c20 TIM1_CCER
         G431_addr.s:305    *ABS*:0000000040012c24 TIM1_CNT
         G431_addr.s:306    *ABS*:0000000040012c28 TIM1_PSC
         G431_addr.s:307    *ABS*:0000000040012c2c TIM1_ARR
         G431_addr.s:308    *ABS*:0000000040012c30 TIM1_RCR
         G431_addr.s:309    *ABS*:0000000040012c34 TIM1_CCR1
         G431_addr.s:310    *ABS*:0000000040012c38 TIM1_CCR2
         G431_addr.s:311    *ABS*:0000000040012c3c TIM1_CCR3
         G431_addr.s:312    *ABS*:0000000040012c40 TIM1_CCR4
         G431_addr.s:313    *ABS*:0000000040012c44 TIM1_BDTR
         G431_addr.s:314    *ABS*:0000000040012c48 TIM1_CCR5
         G431_addr.s:315    *ABS*:0000000040012c4c TIM1_CCR6
         G431_addr.s:316    *ABS*:0000000040012c50 TIM1_CCMR3
         G431_addr.s:317    *ABS*:0000000040012c54 TIM1_DTR2
         G431_addr.s:318    *ABS*:0000000040012c58 TIM1_ECR
         G431_addr.s:319    *ABS*:0000000040012c5c TIM1_TISEL
         G431_addr.s:320    *ABS*:0000000040012c60 TIM1_AF1
         G431_addr.s:321    *ABS*:0000000040012c64 TIM1_AF2
         G431_addr.s:323    *ABS*:0000000040012fdc TIM1_DCR
         G431_addr.s:324    *ABS*:0000000040012fe0 TIM1_DMAR
         G431_addr.s:328    *ABS*:0000000040013400 TIM8_BASE
         G431_addr.s:330    *ABS*:0000000040013400 TIM8_CR1
         G431_addr.s:331    *ABS*:0000000040013404 TIM8_CR2
         G431_addr.s:332    *ABS*:0000000040013408 TIM8_SMCR
         G431_addr.s:333    *ABS*:000000004001340c TIM8_DIER
         G431_addr.s:334    *ABS*:0000000040013410 TIM8_SR
         G431_addr.s:335    *ABS*:0000000040013414 TIM8_EGR
         G431_addr.s:336    *ABS*:0000000040013418 TIM8_CCMR1
         G431_addr.s:337    *ABS*:000000004001341c TIM8_CCMR2
         G431_addr.s:338    *ABS*:0000000040013420 TIM8_CCER
         G431_addr.s:339    *ABS*:0000000040013424 TIM8_CNT
         G431_addr.s:340    *ABS*:0000000040013428 TIM8_PSC
         G431_addr.s:341    *ABS*:000000004001342c TIM8_ARR
         G431_addr.s:342    *ABS*:0000000040013430 TIM8_RCR
         G431_addr.s:343    *ABS*:0000000040013434 TIM8_CCR1
         G431_addr.s:344    *ABS*:0000000040013438 TIM8_CCR2
         G431_addr.s:345    *ABS*:000000004001343c TIM8_CCR3
         G431_addr.s:346    *ABS*:0000000040013440 TIM8_CCR4
         G431_addr.s:347    *ABS*:0000000040013444 TIM8_BDTR
         G431_addr.s:348    *ABS*:0000000040013448 TIM8_CCR5
         G431_addr.s:349    *ABS*:000000004001344c TIM8_CCR6
         G431_addr.s:350    *ABS*:0000000040013450 TIM8_CCMR3
         G431_addr.s:351    *ABS*:0000000040013454 TIM8_DTR2
         G431_addr.s:352    *ABS*:0000000040013458 TIM8_ECR
         G431_addr.s:353    *ABS*:000000004001345c TIM8_TISEL
         G431_addr.s:354    *ABS*:0000000040013460 TIM8_AF1
         G431_addr.s:355    *ABS*:0000000040013464 TIM8_AF2
         G431_addr.s:357    *ABS*:00000000400137dc TIM8_DCR
         G431_addr.s:358    *ABS*:00000000400137e0 TIM8_DMAR
         G431_addr.s:362    *ABS*:0000000040015000 TIM20_BASE
         G431_addr.s:364    *ABS*:0000000040015000 TIM20_CR1
         G431_addr.s:365    *ABS*:0000000040015004 TIM20_CR2
         G431_addr.s:366    *ABS*:0000000040015008 TIM20_SMCR
         G431_addr.s:367    *ABS*:000000004001500c TIM20_DIER
         G431_addr.s:368    *ABS*:0000000040015010 TIM20_SR
         G431_addr.s:369    *ABS*:0000000040015014 TIM20_EGR
         G431_addr.s:370    *ABS*:0000000040015018 TIM20_CCMR1
         G431_addr.s:371    *ABS*:000000004001501c TIM20_CCMR2
         G431_addr.s:372    *ABS*:0000000040015020 TIM20_CCER
         G431_addr.s:373    *ABS*:0000000040015024 TIM20_CNT
         G431_addr.s:374    *ABS*:0000000040015028 TIM20_PSC
         G431_addr.s:375    *ABS*:000000004001502c TIM20_ARR
         G431_addr.s:376    *ABS*:0000000040015030 TIM20_RCR
         G431_addr.s:377    *ABS*:0000000040015034 TIM20_CCR1
         G431_addr.s:378    *ABS*:0000000040015038 TIM20_CCR2
         G431_addr.s:379    *ABS*:000000004001503c TIM20_CCR3
         G431_addr.s:380    *ABS*:0000000040015040 TIM20_CCR4
         G431_addr.s:381    *ABS*:0000000040015044 TIM20_BDTR
         G431_addr.s:382    *ABS*:0000000040015048 TIM20_CCR5
         G431_addr.s:383    *ABS*:000000004001504c TIM20_CCR6
         G431_addr.s:384    *ABS*:0000000040015050 TIM20_CCMR3
         G431_addr.s:385    *ABS*:0000000040015054 TIM20_DTR2
         G431_addr.s:386    *ABS*:0000000040015058 TIM20_ECR
         G431_addr.s:387    *ABS*:000000004001505c TIM20_TISEL
         G431_addr.s:388    *ABS*:0000000040015060 TIM20_AF1
         G431_addr.s:389    *ABS*:0000000040015064 TIM20_AF2
         G431_addr.s:391    *ABS*:00000000400153dc TIM20_DCR
         G431_addr.s:392    *ABS*:00000000400153e0 TIM20_DMAR
         G431_addr.s:396    *ABS*:0000000040014000 TIM15_BASE
         G431_addr.s:398    *ABS*:0000000040014000 TIM15_CR1
         G431_addr.s:399    *ABS*:0000000040014004 TIM15_CR2
         G431_addr.s:400    *ABS*:0000000040014008 TIM15_SMCR
         G431_addr.s:401    *ABS*:000000004001400c TIM15_DIER
         G431_addr.s:402    *ABS*:0000000040014010 TIM15_SR
         G431_addr.s:403    *ABS*:0000000040014014 TIM15_EGR
         G431_addr.s:404    *ABS*:0000000040014018 TIM15_CCMR1
         G431_addr.s:406    *ABS*:0000000040014020 TIM15_CCER
         G431_addr.s:407    *ABS*:0000000040014024 TIM15_CNT
         G431_addr.s:408    *ABS*:0000000040014028 TIM15_PSC
         G431_addr.s:409    *ABS*:000000004001402c TIM15_ARR
         G431_addr.s:410    *ABS*:0000000040014030 TIM15_RCR
         G431_addr.s:411    *ABS*:0000000040014034 TIM15_CCR1
         G431_addr.s:412    *ABS*:0000000040014038 TIM15_CCR2
         G431_addr.s:414    *ABS*:0000000040014044 TIM15_BDTR
         G431_addr.s:416    *ABS*:0000000040014054 TIM15_DTR2
         G431_addr.s:418    *ABS*:000000004001405c TIM15_TISEL
         G431_addr.s:419    *ABS*:0000000040014060 TIM15_AF1
         G431_addr.s:420    *ABS*:0000000040014064 TIM15_AF2
         G431_addr.s:422    *ABS*:00000000400143dc TIM15_DCR
         G431_addr.s:423    *ABS*:00000000400143e0 TIM15_DMAR
         G431_addr.s:427    *ABS*:0000000040014400 TIM16_BASE
         G431_addr.s:429    *ABS*:0000000040014400 TIM16_CR1
         G431_addr.s:430    *ABS*:0000000040014404 TIM16_CR2
         G431_addr.s:432    *ABS*:000000004001440c TIM16_DIER
         G431_addr.s:433    *ABS*:0000000040014410 TIM16_SR
         G431_addr.s:434    *ABS*:0000000040014414 TIM16_EGR
         G431_addr.s:435    *ABS*:0000000040014418 TIM16_CCMR1
         G431_addr.s:437    *ABS*:0000000040014420 TIM16_CCER
         G431_addr.s:438    *ABS*:0000000040014424 TIM16_CNT
         G431_addr.s:439    *ABS*:0000000040014428 TIM16_PSC
         G431_addr.s:440    *ABS*:000000004001442c TIM16_ARR
         G431_addr.s:441    *ABS*:0000000040014430 TIM16_RCR
         G431_addr.s:442    *ABS*:0000000040014434 TIM16_CCR1
         G431_addr.s:444    *ABS*:0000000040014444 TIM16_BDTR
         G431_addr.s:446    *ABS*:0000000040014454 TIM16_DTR2
         G431_addr.s:448    *ABS*:000000004001445c TIM16_TISEL
         G431_addr.s:449    *ABS*:0000000040014460 TIM16_AF1
         G431_addr.s:450    *ABS*:0000000040014464 TIM16_AF2
         G431_addr.s:451    *ABS*:0000000040014468 TIM16_OR1
         G431_addr.s:453    *ABS*:00000000400147dc TIM16_DCR
         G431_addr.s:454    *ABS*:00000000400147e0 TIM16_DMAR
         G431_addr.s:458    *ABS*:0000000040014800 TIM17_BASE
         G431_addr.s:460    *ABS*:0000000040014800 TIM17_CR1
         G431_addr.s:461    *ABS*:0000000040014804 TIM17_CR2
         G431_addr.s:463    *ABS*:000000004001480c TIM17_DIER
         G431_addr.s:464    *ABS*:0000000040014810 TIM17_SR
         G431_addr.s:465    *ABS*:0000000040014814 TIM17_EGR
         G431_addr.s:466    *ABS*:0000000040014818 TIM17_CCMR1
         G431_addr.s:468    *ABS*:0000000040014820 TIM17_CCER
         G431_addr.s:469    *ABS*:0000000040014824 TIM17_CNT
         G431_addr.s:470    *ABS*:0000000040014828 TIM17_PSC
         G431_addr.s:471    *ABS*:000000004001482c TIM17_ARR
         G431_addr.s:472    *ABS*:0000000040014830 TIM17_RCR
         G431_addr.s:473    *ABS*:0000000040014834 TIM17_CCR1
         G431_addr.s:475    *ABS*:0000000040014844 TIM17_BDTR
         G431_addr.s:477    *ABS*:0000000040014854 TIM17_DTR2
         G431_addr.s:479    *ABS*:000000004001485c TIM17_TISEL
         G431_addr.s:480    *ABS*:0000000040014860 TIM17_AF1
         G431_addr.s:481    *ABS*:0000000040014864 TIM17_AF2
         G431_addr.s:482    *ABS*:0000000040014868 TIM17_OR1
         G431_addr.s:484    *ABS*:0000000040014bdc TIM17_DCR
         G431_addr.s:485    *ABS*:0000000040014be0 TIM17_DMAR
         G431_addr.s:493    *ABS*:0000000040021000 RCC_BASE
         G431_addr.s:495    *ABS*:0000000040021000 RCC_CR
         G431_addr.s:496    *ABS*:0000000040021004 RCC_ICSCR
         G431_addr.s:497    *ABS*:0000000040021008 RCC_CFGR
         G431_addr.s:498    *ABS*:000000004002100c RCC_PLLCFGR
         G431_addr.s:500    *ABS*:0000000040021018 RCC_CIER
         G431_addr.s:501    *ABS*:000000004002101c RCC_CIFR
         G431_addr.s:502    *ABS*:0000000040021020 RCC_CICR
         G431_addr.s:504    *ABS*:0000000040021028 RCC_AHB1RSTR
         G431_addr.s:505    *ABS*:000000004002102c RCC_AHB2RSTR
         G431_addr.s:506    *ABS*:0000000040021030 RCC_AHB3RSTR
         G431_addr.s:508    *ABS*:0000000040021038 RCC_APB1RSTR1
         G431_addr.s:509    *ABS*:000000004002103c RCC_APB1RSTR2
         G431_addr.s:510    *ABS*:0000000040021040 RCC_APB2RSTR
         G431_addr.s:512    *ABS*:0000000040021048 RCC_AHB1ENR
         G431_addr.s:513    *ABS*:000000004002104c RCC_AHB2ENR
         G431_addr.s:514    *ABS*:0000000040021050 RCC_AHB3ENR
         G431_addr.s:516    *ABS*:0000000040021058 RCC_APB1ENR1
         G431_addr.s:517    *ABS*:000000004002105c RCC_APB1ENR2
         G431_addr.s:518    *ABS*:0000000040021060 RCC_APB2ENR
         G431_addr.s:520    *ABS*:0000000040021068 RCC_AHB1SMENR
         G431_addr.s:521    *ABS*:000000004002106c RCC_AHB2SMENR
         G431_addr.s:522    *ABS*:0000000040021070 RCC_AHB3SMENR
         G431_addr.s:524    *ABS*:0000000040021078 RCC_APB1SMENR1
         G431_addr.s:525    *ABS*:000000004002107c RCC_APB1SMENR2
         G431_addr.s:526    *ABS*:0000000040021080 RCC_APB2SMENR
         G431_addr.s:528    *ABS*:0000000040021088 RCC_CCIPR
         G431_addr.s:530    *ABS*:0000000040021090 RCC_BDCR
         G431_addr.s:531    *ABS*:0000000040021094 RCC_CSR
         G431_addr.s:532    *ABS*:0000000040021098 RCC_CRRCR
         G431_addr.s:533    *ABS*:000000004002109c RCC_CCIPR2
         G431_addr.s:541    *ABS*:0000000048000000 GPIO_BASE
         G431_addr.s:543    *ABS*:0000000000000000 GPIO_MODER_OFFSET
         G431_addr.s:544    *ABS*:0000000000000004 GPIO_OTYPER_OFFSET
         G431_addr.s:545    *ABS*:0000000000000008 GPIO_OSPEEDR_OFFSET
         G431_addr.s:546    *ABS*:000000000000000c GPIO_PUPDR_OFFSET
         G431_addr.s:547    *ABS*:0000000000000010 GPIO_IDR_OFFSET
         G431_addr.s:548    *ABS*:0000000000000014 GPIO_ODR_OFFSET
         G431_addr.s:549    *ABS*:0000000000000018 GPIO_BSRR_OFFSET
         G431_addr.s:550    *ABS*:000000000000001c GPIO_LCKR_OFFSET
         G431_addr.s:551    *ABS*:0000000000000020 GPIO_AFRL_OFFSET
         G431_addr.s:552    *ABS*:0000000000000024 GPIO_AFRH_OFFSET
         G431_addr.s:553    *ABS*:0000000000000028 GPIO_BRR_OFFSET
         G431_addr.s:559    *ABS*:0000000048000000 GPIOA_BASE
         G431_addr.s:561    *ABS*:0000000048000000 GPIOA_MODER
         G431_addr.s:562    *ABS*:0000000048000004 GPIOA_OTYPER
         G431_addr.s:563    *ABS*:0000000048000008 GPIOA_OSPEEDR
         G431_addr.s:564    *ABS*:000000004800000c GPIOA_PUPDR
         G431_addr.s:565    *ABS*:0000000048000010 GPIOA_IDR
         G431_addr.s:566    *ABS*:0000000048000014 GPIOA_ODR
         G431_addr.s:567    *ABS*:0000000048000018 GPIOA_BSRR
         G431_addr.s:568    *ABS*:000000004800001c GPIOA_LCKR
         G431_addr.s:569    *ABS*:0000000048000020 GPIOA_AFRL
         G431_addr.s:570    *ABS*:0000000048000024 GPIOA_AFRH
         G431_addr.s:571    *ABS*:0000000048000028 GPIOA_BRR
         G431_addr.s:575    *ABS*:0000000048000400 GPIOB_BASE
         G431_addr.s:577    *ABS*:0000000048000400 GPIOB_MODER
         G431_addr.s:578    *ABS*:0000000048000404 GPIOB_OTYPER
         G431_addr.s:579    *ABS*:0000000048000408 GPIOB_OSPEEDR
         G431_addr.s:580    *ABS*:000000004800040c GPIOB_PUPDR
         G431_addr.s:581    *ABS*:0000000048000410 GPIOB_IDR
         G431_addr.s:582    *ABS*:0000000048000414 GPIOB_ODR
         G431_addr.s:583    *ABS*:0000000048000418 GPIOB_BSRR
         G431_addr.s:584    *ABS*:000000004800041c GPIOB_LCKR
         G431_addr.s:585    *ABS*:0000000048000420 GPIOB_AFRL
         G431_addr.s:586    *ABS*:0000000048000424 GPIOB_AFRH
         G431_addr.s:587    *ABS*:0000000048000428 GPIOB_BRR
         G431_addr.s:591    *ABS*:0000000048000800 GPIOC_BASE
         G431_addr.s:593    *ABS*:0000000048000800 GPIOC_MODER
         G431_addr.s:594    *ABS*:0000000048000804 GPIOC_OTYPER
         G431_addr.s:595    *ABS*:0000000048000808 GPIOC_OSPEEDR
         G431_addr.s:596    *ABS*:000000004800080c GPIOC_PUPDR
         G431_addr.s:597    *ABS*:0000000048000810 GPIOC_IDR
         G431_addr.s:598    *ABS*:0000000048000814 GPIOC_ODR
         G431_addr.s:599    *ABS*:0000000048000818 GPIOC_BSRR
         G431_addr.s:600    *ABS*:000000004800081c GPIOC_LCKR
         G431_addr.s:601    *ABS*:0000000048000820 GPIOC_AFRL
         G431_addr.s:602    *ABS*:0000000048000824 GPIOC_AFRH
         G431_addr.s:603    *ABS*:0000000048000828 GPIOC_BRR
         G431_addr.s:607    *ABS*:0000000048000c00 GPIOD_BASE
         G431_addr.s:609    *ABS*:0000000048000c00 GPIOD_MODER
         G431_addr.s:610    *ABS*:0000000048000c04 GPIOD_OTYPER
         G431_addr.s:611    *ABS*:0000000048000c08 GPIOD_OSPEEDR
         G431_addr.s:612    *ABS*:0000000048000c0c GPIOD_PUPDR
         G431_addr.s:613    *ABS*:0000000048000c10 GPIOD_IDR
         G431_addr.s:614    *ABS*:0000000048000c14 GPIOD_ODR
         G431_addr.s:615    *ABS*:0000000048000c18 GPIOD_BSRR
         G431_addr.s:616    *ABS*:0000000048000c1c GPIOD_LCKR
         G431_addr.s:617    *ABS*:0000000048000c20 GPIOD_AFRL
         G431_addr.s:618    *ABS*:0000000048000c24 GPIOD_AFRH
         G431_addr.s:619    *ABS*:0000000048000c28 GPIOD_BRR
         G431_addr.s:623    *ABS*:0000000048001000 GPIOE_BASE
         G431_addr.s:625    *ABS*:0000000048001000 GPIOE_MODER
         G431_addr.s:626    *ABS*:0000000048001004 GPIOE_OTYPER
         G431_addr.s:627    *ABS*:0000000048001008 GPIOE_OSPEEDR
         G431_addr.s:628    *ABS*:000000004800100c GPIOE_PUPDR
         G431_addr.s:629    *ABS*:0000000048001010 GPIOE_IDR
         G431_addr.s:630    *ABS*:0000000048001014 GPIOE_ODR
         G431_addr.s:631    *ABS*:0000000048001018 GPIOE_BSRR
         G431_addr.s:632    *ABS*:000000004800101c GPIOE_LCKR
         G431_addr.s:633    *ABS*:0000000048001020 GPIOE_AFRL
         G431_addr.s:634    *ABS*:0000000048001024 GPIOE_AFRH
         G431_addr.s:635    *ABS*:0000000048001028 GPIOE_BRR
         G431_addr.s:639    *ABS*:0000000048001400 GPIOF_BASE
         G431_addr.s:641    *ABS*:0000000048001400 GPIOF_MODER
         G431_addr.s:642    *ABS*:0000000048001404 GPIOF_OTYPER
         G431_addr.s:643    *ABS*:0000000048001408 GPIOF_OSPEEDR
         G431_addr.s:644    *ABS*:000000004800140c GPIOF_PUPDR
         G431_addr.s:645    *ABS*:0000000048001410 GPIOF_IDR
         G431_addr.s:646    *ABS*:0000000048001414 GPIOF_ODR
         G431_addr.s:647    *ABS*:0000000048001418 GPIOF_BSRR
         G431_addr.s:648    *ABS*:000000004800141c GPIOF_LCKR
         G431_addr.s:649    *ABS*:0000000048001420 GPIOF_AFRL
         G431_addr.s:650    *ABS*:0000000048001424 GPIOF_AFRH
         G431_addr.s:651    *ABS*:0000000048001428 GPIOF_BRR
         G431_addr.s:655    *ABS*:0000000048001800 GPIOG_BASE
         G431_addr.s:657    *ABS*:0000000048001800 GPIOG_MODER
         G431_addr.s:658    *ABS*:0000000048001804 GPIOG_OTYPER
         G431_addr.s:659    *ABS*:0000000048001808 GPIOG_OSPEEDR
         G431_addr.s:660    *ABS*:000000004800180c GPIOG_PUPDR
         G431_addr.s:661    *ABS*:0000000048001810 GPIOG_IDR
         G431_addr.s:662    *ABS*:0000000048001814 GPIOG_ODR
         G431_addr.s:663    *ABS*:0000000048001818 GPIOG_BSRR
         G431_addr.s:664    *ABS*:000000004800181c GPIOG_LCKR
         G431_addr.s:665    *ABS*:0000000048001820 GPIOG_AFRL
         G431_addr.s:666    *ABS*:0000000048001824 GPIOG_AFRH
         G431_addr.s:667    *ABS*:0000000048001828 GPIOG_BRR
         G431_addr.s:675    *ABS*:00000000e000e000 SCS_BASE
         G431_addr.s:683    *ABS*:00000000e000e00a STK_BASE
         G431_addr.s:685    *ABS*:00000000e000e000 STK_CTRL
         G431_addr.s:686    *ABS*:00000000e000e004 STK_LOAD
         G431_addr.s:687    *ABS*:00000000e000e008 STK_VAL
         G431_addr.s:688    *ABS*:00000000e000e00c STK_CALIB
         G431_addr.s:696    *ABS*:00000000e000e100 NVIC_BASE
         G431_addr.s:698    *ABS*:00000000e000e100 NVIC_ISER0
         G431_addr.s:699    *ABS*:00000000e000e104 NVIC_ISER1
         G431_addr.s:700    *ABS*:00000000e000e108 NVIC_ISER2
         G431_addr.s:701    *ABS*:00000000e000e10c NVIC_ISER3
         G431_addr.s:703    *ABS*:00000000e000e180 NVIC_ICER0
         G431_addr.s:704    *ABS*:00000000e000e184 NVIC_ICER1
         G431_addr.s:705    *ABS*:00000000e000e188 NVIC_ICER2
         G431_addr.s:706    *ABS*:00000000e000e18c NVIC_ICER3
         G431_addr.s:708    *ABS*:00000000e000e200 NVIC_ISPR0
         G431_addr.s:709    *ABS*:00000000e000e204 NVIC_ISPR1
         G431_addr.s:710    *ABS*:00000000e000e208 NVIC_ISPR2
         G431_addr.s:711    *ABS*:00000000e000e20c NVIC_ISPR3
         G431_addr.s:713    *ABS*:00000000e000e280 NVIC_ICPR0
         G431_addr.s:714    *ABS*:00000000e000e284 NVIC_ICPR1
         G431_addr.s:715    *ABS*:00000000e000e288 NVIC_ICPR2
         G431_addr.s:716    *ABS*:00000000e000e28c NVIC_ICPR3
         G431_addr.s:718    *ABS*:00000000e000e300 NVIC_IABR0
         G431_addr.s:719    *ABS*:00000000e000e304 NVIC_IABR1
         G431_addr.s:720    *ABS*:00000000e000e308 NVIC_IABR2
         G431_addr.s:721    *ABS*:00000000e000e30c NVIC_IABR3
         G431_addr.s:723    *ABS*:00000000e000e400 NVIC_IPR0
         G431_addr.s:724    *ABS*:00000000e000e404 NVIC_IPR1
         G431_addr.s:725    *ABS*:00000000e000e408 NVIC_IPR2
         G431_addr.s:726    *ABS*:00000000e000e40c NVIC_IPR3
         G431_addr.s:727    *ABS*:00000000e000e410 NVIC_IPR4
         G431_addr.s:728    *ABS*:00000000e000e414 NVIC_IPR5
         G431_addr.s:729    *ABS*:00000000e000e418 NVIC_IPR6
         G431_addr.s:730    *ABS*:00000000e000e41c NVIC_IPR7
         G431_addr.s:731    *ABS*:00000000e000e420 NVIC_IPR8
         G431_addr.s:732    *ABS*:00000000e000e424 NVIC_IPR9
         G431_addr.s:733    *ABS*:00000000e000e428 NVIC_IPR10
         G431_addr.s:734    *ABS*:00000000e000e42c NVIC_IPR11
         G431_addr.s:735    *ABS*:00000000e000e430 NVIC_IPR12
         G431_addr.s:736    *ABS*:00000000e000e434 NVIC_IPR13
         G431_addr.s:737    *ABS*:00000000e000e438 NVIC_IPR14
         G431_addr.s:738    *ABS*:00000000e000e43c NVIC_IPR15
         G431_addr.s:739    *ABS*:00000000e000e440 NVIC_IPR16
         G431_addr.s:740    *ABS*:00000000e000e444 NVIC_IPR17
         G431_addr.s:741    *ABS*:00000000e000e448 NVIC_IPR18
         G431_addr.s:742    *ABS*:00000000e000e44c NVIC_IPR19
         G431_addr.s:743    *ABS*:00000000e000e450 NVIC_IPR20
         G431_addr.s:744    *ABS*:00000000e000e454 NVIC_IPR21
         G431_addr.s:745    *ABS*:00000000e000e458 NVIC_IPR22
         G431_addr.s:746    *ABS*:00000000e000e45c NVIC_IPR23
         G431_addr.s:747    *ABS*:00000000e000e460 NVIC_IPR24
         G431_addr.s:748    *ABS*:00000000e000e464 NVIC_IPR25
         G431_addr.s:750    *ABS*:00000000e000ef00 STIR
         G431_addr.s:758    *ABS*:00000000e0042000 DBGMCU_BASE
         G431_addr.s:760    *ABS*:00000000e0042000 DBGMCU_IDCODE
         G431_addr.s:761    *ABS*:00000000e0042004 DBGMCU_CR
         G431_addr.s:762    *ABS*:00000000e0042008 DBGMCU_APB1FZR1
         G431_addr.s:763    *ABS*:00000000e004200c DBGMCU_APB1FZR2
         G431_addr.s:764    *ABS*:00000000e0042010 DBGMCU_APB2DZR
             task2.s:46     .vectortable:0000000000000000 $d
             task2.s:219    .exhand:0000000000000000 _nmi
             task2.s:252    .exhand:0000000000000028 _hardf
             task2.s:58     .text:0000000000000000 $t
             task2.s:64     .text:0000000000000000 init
             task2.s:145    .text:0000000000000078 main
             task2.s:170    .text:0000000000000094 todolight
             task2.s:186    .text:00000000000000a0 delay
             task2.s:200    .text:00000000000000b0 stop
             task2.s:206    .text:00000000000000b6 .lp1
             task2.s:207    .text:00000000000000b6 $d
             task2.s:207    .text:00000000000000b8 $d
             task2.s:215    .exhand:0000000000000000 $t
             task2.s:280    .exhand:0000000000000050 .lp2
             task2.s:281    .exhand:0000000000000050 $d

NO UNDEFINED SYMBOLS
