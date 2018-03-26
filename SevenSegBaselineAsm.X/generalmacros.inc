; DelayMS ms
; Waits for ms (10 < ms < 2000)
DelayMS MACRO ms
    movlw ms/.10
    pagesel delay10
    call delay10
    pagesel $
ENDM


