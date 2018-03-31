/*
 * Filename: ButtonBaselineC.c
 * Date: 3/31/18
 * File Version: 0.1
 * 
 * Author: Gabriel Miller
 * 
 * Architecture: PIC Baseline
 * Processor: 12F509
 * Compiler: XC8 v1.45 Free
 * 
 * Description: Turns a led on (GP1) based on button (GP3)
 */
#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ 4000000

#pragma config MCLRE = OFF, CP = OFF, WDT = OFF, OSC = IntRC

/*Global Vars*/
uint8_t sGPIO;

void main() {
    uint8_t db_cnt;
    
    GPIO = 0;
    sGPIO = 0;
    TRIS = 0b111101;
    
    for (;;) {
        for (db_cnt = 0; db_cnt <= 10; db_cnt++) {
            __delay_ms(1);
            if (GPIObits.GP3 == 1)
                db_cnt = 0;
        }
        
        sGPIO ^= 0b000010;
        GPIO = sGPIO;
        
        for (db_cnt = 0; db_cnt <= 10; db_cnt++) {
            __delay_ms(1);
            if (GPIObits.GP3 == 0)
                db_cnt = 0;
        }
    }
}
