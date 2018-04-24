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
    
    #define sMINS sPORTC,5
    #define sTENS sPORTA,5
    #define sONES sPORTC,0
    
CONTEXT UDATA_SHR 
cs_W res 1
cs_STATUS res 1
 
SHADOW UDATA_SHR
sPORTA res 1
sPORTC res 1
 
GENVAR UDATA
mpx_cnt res 1
mins res 1
secs res 1
digit res 1

;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
pagesel START
goto START
  
;*******************************************************************************
; ISR
;*******************************************************************************
ISR CODE 0x0004
    movwf cs_W
    movf STATUS,w
    movwf cs_STATUS
    
    bcf INTCON,T0IF
    
    banksel mpx_cnt
    incf mpx_cnt,f
    movf mpx_cnt,w
    addlw -1
    btfsc STATUS,Z
    goto dsp_ones
    addlw -1
    btfsc STATUS,Z
    goto dsp_tens
    clrf mpx_cnt
    goto dsp_mins
    
dsp_ones
    movf secs,w
    andlw 0x0F
    movwf digit
    Lookup tb7segA, digit
    movwf sPORTA
    Lookup tb7segC, digit
    movwf sPORTC
    bsf sONES
    goto dsp_end
dsp_tens
    swapf secs,w
    andlw 0x0F
    movwf digit
    Lookup tb7segA, digit
    movwf sPORTA
    Lookup tb7segC, digit
    movwf sPORTC
    bsf sTENS
    goto dsp_end
dsp_mins
    Lookup tb7segA, mins
    movwf sPORTA
    Lookup tb7segC, mins
    movwf sPORTC
    bsf sMINS
dsp_end
    banksel PORTA
    movf sPORTA,w
    movwf PORTA
    movf sPORTC,w
    movwf PORTC
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

    banksel TRISA
    clrf TRISA
    clrf TRISC
    
    movlw b'11000010'
    banksel OPTION_REG
    movwf OPTION_REG
    
    banksel mins
    clrf mins
    clrf secs
    clrf digit
    clrf mpx_cnt
    
    movlw 1<<GIE|1<<T0IE
    movwf INTCON
    
main_loop
    movlw .100
    call delay10
    
    banksel secs
    incf secs,f
    movf secs,w
    andlw 0x0F
    xorlw .10
    btfss STATUS,Z
    goto inc_end
    movlw .6
    addwf secs,f
    movlw 0x60
    xorwf secs,w
    btfss STATUS,Z
    goto inc_end
    clrf secs
    incf mins,f
    movlw .10
    xorwf mins,w
    btfsc STATUS,Z
    clrf mins
inc_end
    
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