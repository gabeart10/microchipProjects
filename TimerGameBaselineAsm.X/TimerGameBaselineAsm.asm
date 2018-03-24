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
;    Filename: TimerGameBaselineAsm.asm                                                                 *
;    Date: 3/24/18                                                                    *
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

list p=12F509
#include <p12F509.inc>

EXTERN delay10_R
    
;*******************************************************************************
; Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC

;*******************************************************************************
; Variable Definitions
;*******************************************************************************
    UDATA
cnt_8ms res 1


;*******************************************************************************
; RC Calibration
;*******************************************************************************
    
RCCAL CODE 0x3FF
    res 1
    
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
movwf OSCCAL
  pagesel START
    GOTO    START                   ; go to beginning of program
    
;*******************************************************************************
; Subroutie Vectors
;*******************************************************************************
    
delay10
    pagesel delay10_R
    goto delay10_R

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START
    movlw b'111001'
    tris GPIO
    movlw b'11010100'
    option
main_loop
    clrf GPIO
    
    movlw .200
    pagesel delay10
    call delay10
    pagesel $
    
    bsf GPIO,2
    
    banksel cnt_8ms
    clrf cnt_8ms
wait1s clrf TMR0
w_tmr0
    btfss GPIO,3
    goto wait1s_end
    movf TMR0,w 
    xorlw .250
    btfss STATUS,Z
    goto w_tmr0
    incf cnt_8ms,f
    movlw .125
    xorwf cnt_8ms,w 
    btfss STATUS,Z
    goto wait1s
wait1s_end
    movlw .25
    subwf cnt_8ms,w
    btfss STATUS,C
    bsf GPIO,1
    
    movlw .100
    pagesel delay10
    call delay10
    pagesel $
    
    goto main_loop

    END