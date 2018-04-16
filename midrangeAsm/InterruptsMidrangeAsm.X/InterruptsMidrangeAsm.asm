;*******************************************************************************
;                                                                              *
;    Microchip licenses this software to you solely for use with Microchip     *
;    products. The software is owned by Microchip and/or its licensors, and is *
;    protected under applicable copyright laws.  All rights reserved.          *
;                                                                              *
;    This software and any accompanying information is for suggestion only.    *
;    It shall not be deemed to modify Microchip?s standard warranty for its    *
;    products.  It is your responsibility to ensure that this software meets   *
;    your requirements.                                                        *
;                                                                              *
;    SOFTWARE IS PROVIDED "AS IS".  MICROCHIP AND ITS LICENSORS EXPRESSLY      *
;    DISCLAIM ANY WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING  *
;    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS    *
;    FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL          *
;    MICROCHIP OR ITS LICENSORS BE LIABLE FOR ANY INCIDENTAL, SPECIAL,         *
;    INDIRECT OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, HARM TO     *
;    YOUR EQUIPMENT, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR    *
;    SERVICES, ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY   *
;    DEFENSE THEREOF), ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER      *
;    SIMILAR COSTS.                                                            *
;                                                                              *
;    To the fullest extend allowed by law, Microchip and its licensors         *
;    liability shall not exceed the amount of fee, if any, that you have paid  *
;    directly to Microchip to use this software.                               *
;                                                                              *
;    MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF    *
;    THESE TERMS.                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Filename: InterruptsMidrangeAsm.asm                                                                 *
;    Date: 4/14/18                                                                    *
;    File Version: 0.1                                                             *
;    Author: Gabriel Miller                                                                   *
;    Company:                                                                  *
;    Description:                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Notes: In the MPLAB X Help, refer to the MPASM Assembler documentation    *
;    for information on assembly instructions.                                 *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Known Issues: This template is designed for relocatable code.  As such,   *
;    build errors such as "Directive only allowed when generating an object    *
;    file" will result when the 'Build in Absolute Mode' checkbox is selected  *
;    in the project properties.  Designing code in absolute mode is            *
;    antiquated - use relocatable mode.                                        *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Revision History:                                                         *
;                                                                              *
;*******************************************************************************



;*******************************************************************************
; Processor Inclusion
;*******************************************************************************

list p=12F629
#include <p12F629.inc>
    
errorlevel -302
errorlevel -312
    
;*******************************************************************************
; Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_ON & _CP_OFF & _CPD_OFF & _BODEN_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT

;*******************************************************************************
; Variable Definitions
;*******************************************************************************
    
    constant nLED=2
    
CONTEXT UDATA_SHR
cs_W res 1
cs_STATUS res 1
 
GENVAR UDATA_SHR
sGPIO res 1

;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
pagesel START
GOTO    START                   ; go to beginning of program
  
;*******************************************************************************
; ISR
;*******************************************************************************
  
ISR CODE 0x0004
    movwf cs_W
    movf STATUS,w
    movwf cs_STATUS
    
    bcf INTCON,T0IF
    
    movf sGPIO,w
    xorlw 1<<nLED
    movwf sGPIO
    
isr_end 
    movf cs_STATUS,w
    movwf STATUS
    swapf cs_W,f
    swapf cs_W,w
    retfie

;*******************************************************************************
; MAIN PROGRAM
;****************x***************************************************************

MAIN_PROG CODE                      ; let linker place main program

START

    call 0x03FF
    banksel OSCCAL
    movwf OSCCAL
    
    banksel GPIO
    clrf GPIO
    clrf sGPIO
    movlw ~(1<<nLED)
    banksel TRISIO
    movwf TRISIO
    movlw b'11000111'
    banksel OPTION_REG
    movwf OPTION_REG
    
    movlw 1<<GIE|1<<T0IE
    movwf INTCON
main_loop
    movf sGPIO,w
    banksel GPIO
    movwf GPIO
    
    goto main_loop
    
    END