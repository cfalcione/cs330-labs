; Caleb Falcione
; 2017-12-07
;
; Assignment 6
; Number sign counts


; Include helper library
%include "along32.inc"

global _start
section .data
        ; Store some constant strings
        prompt: db 'Enter integers separated by newlines (two consecutive zeros to terminate):', 0
        resultPos:  db "Positive: ", 0
        resultNeg:  db "Negative: ", 0
        resultZero: db "Zeroes:   ", 0


section .bss
        ; Declare some global variables
        ; Read as <name> reserve-bytes <number of bytes>
        posCount   resb 4
        negCount   resb 4
        zeroCount  resb 4
        zeroBuffer resb 4


section .text

_start:
        call ReadInput
        call Finish

ReadInput:
        ; write prompt
        mov edx, prompt
        call WriteString
        call Crlf ; newline

        ; actually read input
        call ReadInput_Loop
        
        jmp return

ReadInput_Loop:
        call ReadInt

        cmp eax, 0

        jl readNeg
        jg readPos
        je readZero

;; Finishes reading input
ReadInput_End:
        jmp return

;; We read in a zero
readZero:
        inc dword [zeroBuffer]

        ; stop reading input if we've read in two successive zeroes
        cmp dword [zeroBuffer], 2
        jge ReadInput_End

        ; otherwise ask for next input
        jmp ReadInput_Loop

;; We read in a negative
readNeg:
        inc dword [negCount]

        call clearZeroBuffer ; count any previously-read zeros
        
        ; ask for next input
        jmp ReadInput_Loop

;; We read in a positive
readPos:
        inc dword [posCount]
        
        call clearZeroBuffer ; count any previously-read zeroes

        ; ask for next input
        jmp ReadInput_Loop

;; Adds the zero buffer to the zero count and resets the zero buffer
clearZeroBuffer:
        mov ebx, [zeroBuffer]
        add [zeroCount], ebx
        mov dword [zeroBuffer], 0
        jmp return

;; Writes results to stdout and stops execution
Finish:
        ; write the positive count
        mov eax, [posCount]
        mov edx, resultPos
        call WriteString
        call WriteInt
        call Crlf

        ; write the negative count
        mov eax, [negCount]
        mov edx, resultNeg
        call WriteString
        call WriteInt
        call Crlf

        ; write the zero count
        mov eax, [zeroCount]
        mov edx, resultZero
        call WriteString
        call WriteInt
        call Crlf

        jmp exit


exit:
        mov eax, 01h    ; exit
        mov ebx, 0h     ; errno

        int 80h


; Just a helper for conditional returns (and therefore cleaner-looking code)
return:
        ret