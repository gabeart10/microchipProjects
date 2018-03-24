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
;    Filename: LEDBlinkBaselineAsm.asm                                                                *
;    Date:  3/23/18                                                                   *
;    File Version: 0.1                                                            *
;    Author: Gabriel Miller                                                                   *
;    Company:                                                                  *
;    Description: Blinks LED on on pin GP1                                                              *
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

list p=10F200
#include <p10F200.inc>

;*******************************************************************************
;Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC
    
;*******************************************************************************
;Configuration Word Setup
;*******************************************************************************
    
    UDATA
sGPIO res 1
 dc1 res 1
 dc2 res 1
    
;*******************************************************************************
;RC Calibration
;*******************************************************************************
    
RCCAL CODE 0x0FF
 res 1
    
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
movwf OSCCAL
GOTO    START                   ; go to beginning of program

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START
 movlw b'1101'
 tris GPIO
 
 clrf sGPIO
mainLoop
 movf sGPIO,w
 xorlw b'0010'
 movwf sGPIO
 movwf GPIO
 
 ;delay 500ms
 movlw .244
 movwf dc2
 clrf dc1
dly1 nop
 decfsz dc1,f
 goto dc1
dly2 nop
 decfsz dc1,f
 goto dly2
 decfsz dc2,f
 goto dly1
 
 goto mainLoop
 
    END