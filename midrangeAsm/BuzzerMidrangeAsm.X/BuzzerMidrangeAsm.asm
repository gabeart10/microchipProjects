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
;    Filename: LedOnMidrangeAsm.asm                                                                 *
;    Date: 4/12/18                                                                    *
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
    
errorlevel -302
errorlevel -312
    
;*******************************************************************************
; Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOD_OFF & _WDT_OFF & _PWRTE_ON & _INTOSCIO & _FCMEN_OFF & _IESO_OFF

;*******************************************************************************
; Variable Definitions
;*******************************************************************************

SHRVAR UDATA_SHR
period res 1
    
;*******************************************************************************
; Reset Vector + RC Cal
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
pagesel START
GOTO    START                   ; go to beginning of program

;*******************************************************************************
; MAIN PROGRAM
;****************x***************************************************************

MAIN_PROG CODE                      ; let linker place main program

START

    banksel TRISC
    movlw ~(1<<5)
    movwf TRISC
    movlw 1<<0
    banksel ANSEL
    movwf ANSEL
    
    movlw b'00010000'
    banksel ADCON1
    movwf ADCON1
    movlw b'00000001'
    banksel ADCON0
    movwf ADCON0
    
    movlw b'00000110'
    banksel T2CON
    movwf T2CON
    movlw b'00001100'
    banksel CCP1CON
    movwf CCP1CON
     
main_loop
    banksel ADCON0
    bsf ADCON0,GO
w_adc btfsc ADCON0,NOT_DONE
    goto w_adc
    
    banksel PIR1
    bcf PIR1,TMR2IF
w_pwm btfss PIR1, TMR2IF
    goto w_pwm
    
    banksel ADRESH
    movf ADRESH,w
    banksel PR2
    movwf PR2
    
    incf PR2,w
    
    btfss STATUS,Z
    goto duty_calc
    movlw .128
    banksel CCPR1L
    movwf CCPR1L
    bcf CCP1CON,DC1B1
    goto duty_end
duty_calc
    movwf period
    bcf STATUS,C
    rrf period,w
    banksel CCPR1L
    movwf CCPR1L
    bsf CCP1CON,DC1B1
    btfss STATUS,C
    bcf CCP1CON,DC1B1
duty_end
    
    goto main_loop
    
    END