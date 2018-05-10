; Architecture: Baseline PIC
; Processor: any

; Decription:
; N * 10ms (10ms - 2.55s)
; N sould be passed in W
    
    
#include <p16F684.inc>

GLOBAL delay10
 
; Variable Definitions
timer UDATA_SHR
dc1 res 1
dc2 res 1
dc3 res 1
 
; Subroutines
    CODE

delay10
    movwf dc3
    dly2 movlw .13
    movwf dc2
    clrf dc1
    dly1 decfsz dc1,f
    goto dly1
 
    decfsz dc2,f
    goto dly1
 
    decfsz dc3,f
    goto dly2
 
    retlw 0
END
 

