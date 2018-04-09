/*
 Description: One LED blinks at a 50% duty cycle (GP2)
 * Another LED (GP1) responds to a button (GP3)
 */

#include <xc.h>
#include <stdint.h>

#pragma config MCLRE = OFF, CP = OFF, WDT = OFF, OSC = IntRC

#define sFLASH sGPIO.GP2
#define sPRESS sGPIO.GP1
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
    
    uint8_t dc;
    
    GPIO = 0;
    sGPIO.port = 0;
    TRIS = ~(1<<1|1<<2);
    
    OPTION = 0b11010100;
    
    for (;;) {
        for (dc = 0; dc < 125; dc++) {
            TMR0 = 0;
            while (TMR0 < 125) {
                sPRESS = !BUTTON;
                GPIO = sGPIO.port;
            }
        }
        sFLASH = !sFLASH;    
    }
}