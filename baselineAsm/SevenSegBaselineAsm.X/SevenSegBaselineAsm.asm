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
;    Filename: SevenSegBaselineAsm.asm                                                                 *
;    Date: 3/24/18                                                                    *
;    File Version: 0.1                                                             *
;    Author: Gabriel Miller                                                                   *
;    Company:                                                                  *
;    Description: Turns a 7 seg display from 0-9 in 1 sec intervals                                                              *
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

list p=16F506
#include <p16F506.inc>
    
#include <generalmacros.inc>

EXTERN delay10_R
    
;*******************************************************************************
; Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

;*******************************************************************************
; Variable Definitions
;*******************************************************************************
    UDATA_SHR
digit res 1


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
; Subroutine Vector
;*******************************************************************************
    
delay10
    pagesel delay10_R
    goto delay10_R

set7seg
    pagesel set7seg_R
    goto set7seg_R

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START
    clrw
    tris PORTB
    tris PORTC
    clrf ADCON0
    bcf CM1CON0,C1ON
    bcf CM2CON0,C2ON
    
    clrf digit
main_loop
    pagesel set7seg
    call set7seg
    
    DelayMS 1000
    
    incf digit,f
    movlw .10
    xorwf digit,w
    btfsc STATUS,Z
    clrf digit
    
    pagesel main_loop
    goto main_loop
      
;*******************************************************************************
; Lookup Tables
;*******************************************************************************
TABLES	CODE  0x200 
    
  get7sB addwf PCL,f
    retlw b'010010' ;0
    retlw b'000000' ;1
    retlw b'010001' ;2
    retlw b'000001' ;3
    retlw b'000011' ;4
    retlw b'000011' ;5
    retlw b'010011' ;6
    retlw b'000000' ;7
    retlw b'010011' ;8
    retlw b'000011' ;9
    
  get7sC addwf PCL,f
    dt b'011110',b'010100',b'001110',b'011110',b'010100' ; 0,1,2,3,4 
    dt b'011010',b'011010',b'010110',b'011110',b'011110' ; 5,6,7,8,9
    
  set7seg_R 
    movf digit,w
    call get7sB
    movwf PORTB
    movf digit,w
    call get7sC
    movwf PORTC
    retlw 0
	
    END