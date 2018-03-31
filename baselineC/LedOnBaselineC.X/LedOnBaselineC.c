/*
 * Filename: LedOnBaselineC.c 
 * Date: 3/31/18
 * File Version: 0.1
 * 
 * Author: Gabriel Miller
 * 
 * Architecture: Baseline Pic
 * Processor: PIC10F200
 * Compiler: XC8 v1.45 Free
 * 
 * Description: Turns on led on pin GP1
 */

#include <xc.h>
#pragma config MCLRE = ON, CP = OFF, WDTE = OFF

void main() {
    TRIS = 0b1101;
    
    GPIO = 0b0010;
    
    for (;;) {
        ;
    }
}