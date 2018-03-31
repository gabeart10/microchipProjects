/*
 * Filename: LedBlinkBaselineC.c
 * Date: 3/31/18
 * File Version: 0.1v
 * 
 * Author: Gabriel Miller
 * 
 * Architecture: Baseline PIC
 * Processor: PIC12F509
 * Compiler: XC8 v1.45 Free
 * 
 * Description: LED Blink 50% duty cycle GP1
 */
#include <xc.h>
#include <stdint.h>
#pragma config MCLRE = ON, CP = OFF, WDT = OFF, OSC = IntRC

#define _XTAL_FREQ 4000000

/* Global Vars */
uint8_t sGPIO = 0;

void main() {
    TRIS = 0b111101;
    
    for(;;) {
        sGPIO ^= 0b000010;
        GPIO = sGPIO;
        
        __delay_ms(500);
    }
}