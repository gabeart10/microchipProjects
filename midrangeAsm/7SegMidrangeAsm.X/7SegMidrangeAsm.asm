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
;    Filename: 7SegMidrangeAsm.asm                                                                 *
;    Date: 4/17/18                                                                    *
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

list p=16F684
#include <p16F684.inc>
#include <generalmacrosmid.inc>
    
EXTERN delay10
    
errorlevel -302
errorlevel -312
    
;*******************************************************************************
; Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOD_OFF & _WDT_OFF & _PWRTE_ON & _INTOSCIO & _FCMEN_OFF & _IESO_OFF

;*******************************************************************************
; Variable Definitions
;*******************************************************************************
    
    UDATA_SHR 
digit res 1

;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
pagesel START
goto START

;*******************************************************************************
; MAIN PROGRAM
;****************x***************************************************************

MAIN_PROG CODE                      ; let linker place main program

START

    banksel TRISA
    clrf TRISA
    clrf TRISC
    
    clrf digit
    
main_loop
    Lookup tb7segA, digit
    banksel PORTA
    movwf PORTA
    Lookup tb7segC, digit
    movwf PORTC
    
    movlw .100
    call delay10
    
    incf digit,f
    movlw .10
    xorwf digit,w
    btfsc STATUS,Z
    clrf digit
    
    pagesel main_loop
    goto main_loop
    
;*******************************************************************************
; Lookup Tabels
;****************x***************************************************************   
TABLES CODE  
    
tb7segA movwf PCL
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
    
tb7segC movwf PCL
    retlw b'011110' ;0
    retlw b'010100' ;1
    retlw b'001110' ;2
    retlw b'011110' ;3
    retlw b'010100' ;4
    retlw b'011010' ;5
    retlw b'011010' ;6
    retlw b'010110' ;7
    retlw b'011110' ;8
    retlw b'011110' ;9
 
    END