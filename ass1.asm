; Caleb Falcione
; 2017-09-05
;
; Assignment 1
; A * B - ( A + B ) / (A - B) with error on A == B
;

; include helper library
%include "along32.inc"

global _start
section .data
        ;store some constant strings
        promptA: db 'A?:', 0 ; String terminated with null (the 0) stored in 'promptA'
        promptB: db 'B?:', 0
        invalidOperandMessage: db 'A and B cannot be equal.', 0

section .bss
        ;declare/reserve some 4-byte variables
        A resb 4
        B resb 4
        AtimesB resb 4
        AplusB resb 4
        AminusB resb 4
        quotient resb 4
        result resb 4


section .text

_start:
        ; prompt for A
        mov edx, promptA
        call WriteString
        ; read in A
        call ReadInt
        mov [A], eax

        ; prompt for B
        mov edx, promptB
        call WriteString
        ; read in B
        call ReadInt
        mov [B], eax

        ; compare A and B
        cmp eax, [A] ; note that B is in eax at this point
        je InvalidOperands ; if they're equal, print an error message and exit

        ;;;; BEGIN CALCULATIONS

        ;;Calculate A * B
        mov eax, [B] ;B (the last thing read in) is already in eax, but let's be explicit
        mov ebx, [A] ; put A in ebx
        imul ebx ; B (eax) times A (ebx) stored in eax
        ;  store result
        mov [AtimesB], eax

        ;;Calculate A + B
        mov eax, [A]
        mov ebx, [B]
        add eax, ebx
        mov [AplusB], eax

        ;;Calculate A - B
        mov eax, [A]
        mov ebx, [B]
        sub eax, ebx
        mov [AminusB], eax

        ;;Calculate the quotient (A+B) / (A-B)
        ;   the numerator is stored in edx and eax, and is 64 bit
        ;   the first 32 bits are in edx and the last 32 are in eax
        ;   we have a signed 32 bit numerator, so we sign extend
        ;   the sign bit of eax into edx to respect negatives
        mov eax, [AplusB]
        cdq

        ;   the denominator is 32 bit, and is in an arbitrary register
        mov ebx, [AminusB]
        ;   divide edx:eax (AplusB) by ebx (AminusB)
        idiv ebx
        ;   store the result
        mov [quotient], eax

        ;;Calculate the result
        mov eax, [AtimesB]
        mov ebx, [quotient]
        sub eax, ebx
        mov [result], eax

        ;;;; END CALCULATIONS

        mov eax, [result]
        ;Write the result (in eax) to stdout
        call WriteInt
        ; newline for aesthetics
        call Crlf

        ; last line of code
        jmp exit

InvalidOperands:
        mov edx, invalidOperandMessage
        call WriteString
        call Crlf
        jmp exit

exit:
        mov eax, 01h    ; exitC)
        mov ebx, 0h     ; errno

        int 80h