PROCESSOR 18F252
#include <xc.inc>
   
PSECT resetVect, class=CODE, reloc=2

ORG 0x0000             ; Set program counter to 0
GOTO main              ; Jump to main program

ORG 0x0004             ; Interrupt vector location
; Interrupt service routine code goes here

main:
; Configure oscillator for 16 MHz (internal oscillator, PLL enabled)
; Time delay is 250ns
BSF    OSCCON, 6      ; Enable 4x PLL
BSF    OSCCON, 5      ; Select internal oscillator block
BCF    OSCCON, 4      ; Internal oscillator frequency = 16 MHz


TRIS    PORTA   ; Set direction of PORTX as output
BCF     PORTA   ; Clear output initially
CLRWDT          ; Clear Watchdog timer



maskBit	    EQU 0x002
color	    EQU 0x004
ouput	    EQU 0x006
countHigh   EQU 0x008
countLow    EQU 0x010
	
//Test White
MOVLW 1
CALL LEDValueTable
MOVWF color

//initalize maskBit with 0x001
MOVLW 1
MOVWF maskBit


loop:
    MOVF    color , W	; WREG = color 24bit
    ANDWF   maskBit, W	; WREG = color AND maskBit
    
    ; if else to check if we need to output 1 or 0
    movf    WREG, W    ; move the contents of the WREG to W
    btfsc   STATUS,Z   ; check if the zero flag is set
    goto    else_label ; if it is set, jump to the else_label
    movlw   3          ; if the zero flag is not set, we output 1 bit
    movwf   countHigh   
    movlw   2
    movwf   countLow
    goto    end_if     ; jump to the end of the if-else statement
else_label:
    movlw   2          ; otherwise we output led protocal for 0 bit
    movwf   countHigh   
    movlw   3
    movwf   countLow
end_if:
    
    ; MODIFY so that we incorporate loop for countHigh and countLow
    BSF     PORTA   ; Set output to 1
    CALL    delay   ; Call delay subroutine
    BCF     PORTX   ; Set output to 0
    CALL    delay   ; Call delay subroutine
    GOTO    loop    ; Repeat indefinitely

delay:
    MOVLW   0xXX    ; Load W with delay value
    MOVWF   COUNT   ; Move delay value to COUNT register

delay_loop:
    DECFSZ  COUNT   ; Decrement COUNT and skip next instruction if zero
    GOTO    delay_loop  ; Repeat delay loop if COUNT is not zero
    RETURN          ; Return from delay subroutine
    
    
LEDValueTable:
    MULLW   2
    MOVFF   PRODL, WREG
    ADDWF   PCL
    RETLW   0xFFFFFF ;WHITE
    RETLW   0x0000FF ;BLUE
    RETLW   0x00FF00 ;RED
    RETLW   0xFF0000 ;GREEN
    RETLW   0x000000 ;BLACK
    
    RETURN ;Idk if i put this here

END
