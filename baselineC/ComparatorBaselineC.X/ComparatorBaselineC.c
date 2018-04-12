/*
 Description: Sets LED based on Comparator 1 Out
 */

#include <xc.h>

#pragma config MCLRE = ON, CP = OFF, WDT = OFF, IOSCFS = OFF, OSC = IntRC_RB4EN

#define LED PORTCbits.RC3
#define nLED 3

void main() {
    TRISC = ~(1<<nLED);
    
    CM1CON0bits.C1PREF = 1;
    CM1CON0bits.C1NREF = 1;
    CM1CON0bits.C1POL = 0;
    CM1CON0bits.C1ON = 1;
    
    for (;;) {
        LED = CM1CON0bits.C1OUT;
    }
}