/*
 Description: Counting from 0-9
 */

#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ 4000000

#pragma config MCLRE = ON, CP = OFF, WDT = OFF, IOSCFS = OFF, OSC = IntRC_RB4EN

const uint8_t pat7seg[10] = {
    0b1111110, // 0
    0b1010000, // 1
    0b0111101, // 2
    0b1111001, // 3
    0b1010011, // 4
    0b1101011, // 5
    0b1101111, // 6
    0b1011000, // 7
    0b1111111, // 8
    0b1111011  // 9
};

void main() {
    uint8_t digit;
    
    TRISB = 0;
    TRISC = 0;
    ADCON0 = 0;
    CM1CON0bits.C1ON = 0;
    CM2CON0bits.C2ON = 0;
    
    for (;;) {
        for (digit = 0; digit < 10; digit++) {
            PORTB = (pat7seg[digit] & 1<<2) << 2 |
                    (pat7seg[digit] & 0b00000011);
            PORTC = (pat7seg[digit] >> 2) & 0b011110;
            
            __delay_ms(1000);
        }
    }
}