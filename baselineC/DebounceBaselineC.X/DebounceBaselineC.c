/*
 Description: LED (GP1) is toggled by a button (GP3) which is debounced 
 */

#include <xc.h>
#include <stdint.h>

#pragma config MCLRE = OFF, CP = OFF, WDT = OFF, OSC = IntRC

#define sFLASH sGPIO.GP1
#define BUTTON GPIObits.GP3

union {
    uint8_t port;
    struct {
        unsigned GP0 : 1;
        unsigned GP1 : 1;
        unsigned GP2 : 1;
        unsigned GP3 : 1;
        unsigned GP4 : 1;
        unsigned GP5 : 1;
    };
} sGPIO;

void main() {
    GPIO = 0;
    sGPIO.port = 0;
    TRIS = 0b111101;
    
    OPTION = 0b11010101;
    
    for (;;) {
        TMR0 = 0;
        while (TMR0 < 157)
            if (BUTTON == 1)
                TMR0 = 0;
        
        sFLASH = !sFLASH;
        GPIO = sGPIO.port;
        
        TMR0 = 0;
        while (TMR0 < 157)
            if (BUTTON == 0)
                TMR0 = 0;
    }
}
