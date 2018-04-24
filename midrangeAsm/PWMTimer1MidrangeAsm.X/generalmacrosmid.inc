; Lookup returns the value of table specified by off_var (8-bit)
Lookup MACRO table,off_var
    
    movlw HIGH (table+1)
    movwf PCLATH
    movlw LOW (table+1)
    addwf off_var,w
    btfsc STATUS,C
    incf PCLATH,f
    call table
ENDM


