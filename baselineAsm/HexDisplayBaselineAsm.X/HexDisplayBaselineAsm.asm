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
;    Filename: HexDisplayBaselineAsm.asm                                                                 *
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

list p=16F506
#include <p16F506.inc>
    
;*******************************************************************************
; Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN
    
#define TENS PORTC,5
#define ONES PORTB,5

;*******************************************************************************
; Variable Definitions
;*******************************************************************************
    UDATA_SHR
temp res 1

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
    
;***** Subroutine vectors
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
    clrf CM1CON0
    clrf CM2CON0
    clrf VRCON
    
    movlw b'01111001'
    movwf ADCON0
    
    movlw b'11010111'
    option
main_loop
    bsf ADCON0,GO
w_adc btfsc ADCON0,NOT_DONE
    goto w_adc
w10_hi btfss TMR0,2
    goto w10_hi
    swapf ADRES,w
    andlw 0x0F
    pagesel set7seg
    call set7seg
    pagesel $
    bsf TENS
w10_lo btfsc TMR0,2
    goto w10_lo
w1_hi btfss TMR0,2
    goto w1_hi
    movf ADRES,w
    andlw 0x0F
    pagesel set7seg
    call set7seg
    pagesel $
    bsf ONES
w1_lo btfsc TMR0,2
    goto w1_lo
    
    goto main_loop
    
;Lookup Tables 
TABLES CODE 0x200
 
get7sB addwf PCL,f
    retlw b'010010'
    retlw b'000000'
    retlw b'010001'
    retlw b'000001'
    retlw b'000011' ;0,1,2,3,4
    retlw b'000011'
    retlw b'010011'
    retlw b'000000'
    retlw b'010011'
    retlw b'000011' ;5,6,7,8,9
    retlw b'010011'
    retlw b'010011'
    retlw b'010010'
    retlw b'010001'
    retlw b'010011'
    retlw b'010011' ;A,b,C,d,E,F

get7sC addwf PCL,f
    dt b'011110', b'010100', b'001110', b'011110', b'010100' ;0,1,2,3,4
    dt b'011010', b'011010', b'010110', b'011110', b'011110' ;5,6,7,8,9
    dt b'010110', b'011000', b'001010', b'011100', b'001010', b'000010' ;A,b,C,d,E,F
set7seg_R
    clrf PORTB
    clrf PORTC
    
    movwf temp
    call get7sB
    movwf PORTB
    movf temp,w
    call get7sC
    movwf PORTC
    retlw 0

    END