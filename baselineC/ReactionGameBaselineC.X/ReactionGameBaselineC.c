/*
 * Filename: ReactionGameBaselineC.c
 * Date: 3/31/18
 * File Version: 0.1
 * 
 * Author: Gabriel Miller 
 * 
 * Architecture: Baseline PIC
 * Processor: PIC12F509
 * Compiler: XC8 v1.45 Free
 * 
 * Description: Simple Button Game
 */

#include <xc.h>
#include <stdint.h>

#pragma config MCLRE = OFF, CP = OFF, WDT = OFF, OSC = IntRC

#define _XTAL_FREQ 4000000

#define START GPIObits.GP2
#define SUCCESS GPIObits.GP1

#define BUTTON GPIObits.GP3

#define MAXRT 200

void main() {
   uint8_t cnt_8ms;
   
   TRIS = 0b111001;
   OPTION = 0b11010100;
   
   for (;;) {
       GPIO = 0;
       
       __delay_ms(2000);
       
       START = 1;
       
       cnt_8ms = 0;
       while (BUTTON == 1 && cnt_8ms < 1000/8) {
           TMR0 = 0;
           while (TMR0 < 8000/32);
           ++cnt_8ms;
       }
       
       if (cnt_8ms < MAXRT/8) 
           SUCCESS = 1;
       
       __delay_ms(1000);
   }
}