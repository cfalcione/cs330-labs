; Caleb Falcione
; 2017-09-15
;
; Assignment 2
; Average of arbitrarily many integers


; include helper library
%include "along32.inc"

global _start
section .data
        ;store some constant strings
        prompt: db 'Enter arbitrarily many integers (one per line):', 0
        countMessage: db 'Count: ', 0
        averageMessage: db 'Average: ', 0
        invalidCountMessage: db 'You must enter at least one number', 0

section .bss
        ;declare/reserve some 4-byte variables
        count resb 4
        sum resb 4
        result resb 4


section .text

_start:
        ; Write initial prompt to stdout
        mov edx, prompt
        call WriteString
        call Crlf

        ; Acquire all of the numbers
        jmp GetNextNum


;; NOTE: GetNextNum is essentially the following pseudocode
;     def getNextNum (nextInt):
;        if nextInt == 0:
;           self.calculate()
;        self.sum += nextInt
;        self.count += 1
;        getNextnum( self.readNextInt() )        
GetNextNum:

        ; Read in the next integer
        call ReadInt

        ; If they gave a zero, stop reading in numbers and move to calculation step
        cmp eax, 0
        je Calculate

        ; Add to the running sum
        add [sum], eax ; note that the read in number is in eax

        ; Increment the count
        inc dword [count] ; dword specifies that count is 32-bit
        
        ; Get the next integer
        jmp GetNextNum

Calculate:
        ; Check for zero count
        mov eax, [count]
        cmp eax, 0
        je InvalidCount

        ; Compute the average, respecting negatives
        mov eax, [sum]
        cdq ; sign-extend eax into edx
        idiv dword [count] ; dword specifies that count is 32-bit
        mov [result], eax

        ; Write results to stdout and exit
        jmp Finish

Finish:
        ; Display Count
        mov edx, countMessage
        call WriteString

        mov eax, [count]
        call WriteInt
        call Crlf

        ; Display average
        mov edx, averageMessage
        call WriteString

        mov eax, [result]
        call WriteInt
        call Crlf

        ; Exit
        jmp exit

InvalidCount:
        mov edx, invalidCountMessage
        call WriteString
        call Crlf
        jmp exit

exit:
        mov eax, 01h    ; exit
        mov ebx, 0h     ; errno

        int 80h