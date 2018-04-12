#include <xc.h>
#include <stdint.h>

#define MINUTES PORTCbits.RC5
#define TENS PORTBbits.RB5
#define ONES PORTCbits.RC0

#pragma config MCLRE = ON, CP = OFF, WDT = OFF, IOSCFS = OFF, OSC = IntRC_RB4EN

void set7seg(uint8_t digit);

#define TMR0_2 (TMR0 & 1<<2)

void main() {
    uint8_t mpx_cnt;
    uint8_t mins, secs;
    
    TRISB = 0;
    TRISC = 0;
    ADCON0 = 0;
    CM1CON0bits.C1ON = 0;
    CM2CON0bits.C2ON = 0;
    
    OPTION = 0b11010111;
    
    for (;;) {
        for (mins = 0; mins < 10; mins++) {
            for (secs = 0; secs < 60; secs++) {
                for (mpx_cnt = 0; mpx_cnt < 1000000/2048/3; mpx_cnt++) {
                    while (!TMR0_2);
                    set7seg(mins);
                    MINUTES = 1;
                    while (TMR0_2);
                    
                    while (!TMR0_2);
                    set7seg(secs/10);
                    TENS = 1;
                    while (TMR0_2);
                    
                    while (!TMR0_2);
                    set7seg(secs%10);
                    ONES = 1;
                    while (TMR0_2);
                }
            }
        }
    }
}

void set7seg(uint8_t digit) {
    const uint8_t pat7segB[10] = {
        0b010010, //0 
        0b000000, //1 
        0b010001, //2 
        0b000001, //3 
        0b000011, //4 
        0b000011, //5 
        0b010011, //6 
        0b000000, //7 
        0b010011, //8 
        0b000011  //9
    };
    
    const uint8_t pat7segC[10] = {
        0b011110, //0 
        0b010100, //1 
        0b001110, //2 
        0b011110, //3 
        0b010100, //4 
        0b011010, //5 
        0b011010, //6 
        0b010110, //7 
        0b011110, //8 
        0b011110  //9
    };
    
    PORTB = 0;
    PORTC = 0;
    
    PORTB = pat7segB[digit];
    PORTC = pat7segC[digit];
}