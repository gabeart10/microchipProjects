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
;    Filename: SimonSays.asm                                                                 *
;    Date: 4/20/18                                                                    *
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
    
extern delay10
    
errorlevel -302
errorlevel -312
    
;*******************************************************************************
; Configuration Word Setup
;*******************************************************************************

__CONFIG _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOD_OFF & _WDT_OFF & _PWRTE_ON & _INTOSCIO & _FCMEN_OFF & _IESO_OFF

;*******************************************************************************
; Variable Definitions
;*******************************************************************************
    
SeqMem UDATA ;Defining the mem that stores the seq of colors
seqmem res 25
 
GenVars UDATA_SHR ;Defining general vars for the program
sm_row res 1
sm_column res 1
counter res 1
counter2 res 1
rand res 1
column_count res 1
row_count res 1
rot_mem res 1
sub_var res 1
correct res 1
 
constant SEQ_SIZE=.25 ;Setting a constant for the max size of the seq
constant RED=b'00' ;Setting a constant for the code for each color
constant BLUE=b'01'
constant YELLOW=b'10'
constant GREEN=b'11'
 
; Pins
 
#define RED_B PORTC,4 ;Defining the location of the buttons
#define BLUE_B PORTA,2
#define YELLOW_B PORTA,4
#define GREEN_B PORTA,5
 
 
#define RED_L b'000001' ;Defininf the location of the LEDs
#define BLUE_L b'000010'
#define YELLOW_L b'000100'
#define GREEN_L b'001000'

;*******************************************************************************
; Reset Vector + RC Cal
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
GOTO    START                   ; go to beginning of program

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START

    banksel TRISC
    movlw b'11110000' ;Tris PortC
    movwf TRISC
    movlw b'111' ;Turning of analog inputs and comparators
    movwf CMCON0
    clrf ANSEL

    banksel PORTC ;Making sure all vars are clear
    clrf PORTC 
    clrf sm_row
    clrf sm_column
    clrf rand
    clrf counter
    clrf counter2
    clrf column_count
    clrf row_count
    clrf rot_mem
    clrf sub_var
    clrf correct
    
    banksel seqmem
    movlw seqmem ;Clear seqmem
    movwf FSR
seq_clr clrf INDF
    incf FSR,f
    movlw seqmem+SEQ_SIZE
    xorwf FSR,w
    btfss STATUS,Z
    goto seq_clr
    
    movlw (1<<2) ;Turn on TMR2 w/o Post/Prescaling and overflowing on 5
    banksel T2CON
    movwf T2CON
    movlw b'11'
    banksel PR2
    movwf PR2
    
    movlw b'11000100' ;Sets up TMR0 on timer mode with a 1:32 prescale 
    banksel OPTION_REG
    movwf OPTION_REG
    
main_loop
    banksel PORTA
start_b btfsc PORTA,2 ;Waiting for blue button to be pressed to start the game
    goto start_b
 
loop 
    call add_seq ;Adding a new color to the seq
    call display_lights ;Displaying all colors in the seq
    call user_test ;Testing for the correct button presses
    xorlw .1 ;Checking if right or wrong
    btfss STATUS,Z
    goto wrong ;Wrong
    incf correct,f ;Right
    movf sm_row ;Checking if the seq is at its max 
    xorlw SEQ_SIZE 
    btfsc STATUS,Z
    goto wrong
    goto loop
wrong
    banksel PORTC ;Display the lower half of correct
    movf correct,w
    movwf PORTC
    banksel PORTA
wrong_b btfsc PORTA,2 ;Waiting for blue button to be pressed to flip the halfs of correct
    goto wrong_b
    
    swapf correct,f   
wrong_b_up btfss PORTA,2
    goto wrong_b_up
    
    goto wrong
    
; Subroutines    
add_seq
    banksel TMR2
    movf TMR2,w ;Grabs "random" 2-bit number
    movwf rand
    
    movf sm_column,w ;Shifting the rand number to the right column
    bcf STATUS,C
    xorlw .0
    btfsc STATUS,Z
    goto col0
    movf sm_column,w
    xorlw .1
    btfsc STATUS,Z
    goto col1
    movf sm_column,w
    xorlw .2
    btfsc STATUS,Z
    goto col2
    
    rlf rand,f
    rlf rand,f
col2 rlf rand,f
    rlf rand,f
col1 rlf rand,f
    rlf rand,f
col0
    
    banksel seqmem ;Moving FSR to the right mem location
    movlw seqmem
    movwf FSR
    movf sm_row,w ;Checking if row is 0
    xorlw .0
    btfsc STATUS,Z
    goto row_m_end
    movf sm_row,w
    movwf counter
row_m incf FSR,f
    decfsz counter,f
    goto row_m
row_m_end
    
    movf rand,w ;Update row with new data
    xorwf INDF,f
    
    incf sm_column,w ;Inc column, if 5 set 0 and inc row
    xorlw .4
    btfss STATUS,Z
    goto inc_not0
    clrf sm_column
    incf sm_row,f 
    goto inc_0
inc_not0 incf sm_column,f
    
inc_0 retlw 0
    
display_light
    movwf sub_var
    xorlw RED ;Checking for color code to display
    btfsc STATUS,Z
    goto dis_red
    movf sub_var,w
    xorlw BLUE
    btfsc STATUS,Z
    goto dis_blue
    movf sub_var,w
    xorlw YELLOW
    btfsc STATUS,Z
    goto dis_yellow
    movf sub_var,w
    xorlw GREEN
    btfsc STATUS,Z
    goto dis_green
    goto dis_end
    
    dis_red movlw RED_L ;Display red
    movwf PORTC
    goto dis_end
    
    dis_blue movlw BLUE_L ;Display blue
    movwf PORTC
    goto dis_end
    
    dis_yellow movlw YELLOW_L ;Display yellow
    movwf PORTC
    goto dis_end
    
    dis_green movlw GREEN_L ;Display green
    movwf PORTC
    
    dis_end retlw 0
    
display_lights
    banksel seqmem ;Point at the start of seqmem
    movlw seqmem
    movwf FSR
    
    movf sm_row,w ;Checks if sm_row is zero and skips
    xorlw .0
    btfsc STATUS,Z
    goto end_row
    movwf row_count
row_l ;Displays all rows except for current one
    movlw .4
    movwf counter
    movf INDF,w
    movwf rot_mem
rowp_l movlw 0x03
    andwf rot_mem,w
    call display_light
    movlw .100
    call delay10
    banksel PORTC
    clrf PORTC
    movlw .25
    call delay10
    rrf rot_mem,f
    rrf rot_mem,f
    decfsz counter,f
    goto rowp_l
    incf FSR,f
    decfsz row_count,f
    goto row_l
end_row

    movf sm_column,w ;Checks if sm_column is zero and skips
    xorlw .0
    btfsc STATUS,Z
    goto end_col
    movf sm_column,w ;Grabs sm_column and current row
    movwf column_count
    movf INDF,w
    movwf rot_mem
col_l movlw 0x03 ;Displays light code in last row
    andwf rot_mem,w
    call display_light
    movlw .100
    call delay10
    banksel PORTC
    clrf PORTC
    movlw .25
    call delay10
    rrf rot_mem,f
    rrf rot_mem,f
    decfsz column_count,f
    goto col_l
    
end_col retlw 0
    
user_test
    banksel seqmem ;Point at the start of seqmem
    movlw seqmem
    movwf FSR
    
    movf sm_row,w ;Checks if sm_row is zero and skips
    xorlw .0
    btfsc STATUS,Z
    goto end_row_ut
    movwf row_count
row_l_ut ;Gets all rows except for current one and test them
    movlw .4
    movwf counter2
    movf INDF,w
    movwf rot_mem
rowp_l_ut movlw 0x03
    andwf rot_mem,w
    call user_input
    xorlw .0
    btfsc STATUS,Z
    goto fail_test
    rrf rot_mem,f
    rrf rot_mem,f
    decfsz counter2,f
    goto rowp_l_ut
    incf FSR,f
    decfsz row_count,f
    goto row_l_ut
end_row_ut

    movf sm_column,w ;Checks if sm_column is zero and skips
    xorlw .0
    btfsc STATUS,Z
    goto end_col_ut
    movf sm_column,w ;Grabs sm_column and current row
    movwf column_count
    movf INDF,w
    movwf rot_mem
col_l_ut movlw 0x03 ;Gets light code in last row and tests
    andwf rot_mem,w
    call user_input
    xorlw .0
    btfsc STATUS,Z
    goto fail_test
    rrf rot_mem,f
    rrf rot_mem,f
    decfsz column_count,f
    goto col_l_ut
    
end_col_ut retlw 1
    
fail_test retlw 0
    
user_input
    movwf sub_var
    clrf TMR0
    clrf counter
timer_loop ;Counting time while waiting for user input
    banksel TMR0
    movlw .250 ;250 * 32us/tick = 8ms
    subwf TMR0,w
    btfss STATUS,C
    goto button_test
    incf counter,f
    movf counter,w
    xorlw .125 ;8ms * 125 = 1000ms If timer hits 1 sec fail
    btfsc STATUS,Z
    goto fail
    clrf TMR0
button_test 
    banksel PORTA ;Test each button for presses
    btfss RED_B
    goto red_t
    btfss BLUE_B
    goto blue_t
    btfss YELLOW_B
    goto yellow_t
    btfss GREEN_B
    goto green_t
    goto timer_loop
    
red_t ;Red test
    movlw RED
    xorwf sub_var,w
    btfss STATUS,Z
    goto fail
red_up btfss RED_B
    goto red_up
    movlw .1
    call delay10
    retlw 1
blue_t ;Blue test
    movlw BLUE
    xorwf sub_var,w
    btfss STATUS,Z
    goto fail
blue_up btfss BLUE_B
    goto blue_up
    movlw .1
    call delay10
    retlw 1
yellow_t ;Yellow test
    movlw YELLOW
    xorwf sub_var,w
    btfss STATUS,Z
    goto fail
yellow_up btfss YELLOW_B
    goto yellow_up
    movlw .1
    call delay10
    retlw 1
green_t ;Green test
    movlw GREEN
    xorwf sub_var,w
    btfss STATUS,Z
    goto fail
green_up btfss GREEN_B
    goto green_up
    movlw .1
    call delay10
    retlw 1

fail
    retlw 0
    
    END