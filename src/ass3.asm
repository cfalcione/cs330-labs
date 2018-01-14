; Caleb Falcione
; 2017-09-28
;
; Assignment 3
; MSB, LSB, and number of set bits


; Include helper library
%include "along32.inc"

global _start
section .data
        ; Store some constant strings
        prompt: db 'Enter a 32-bit hexadecimal number and press Enter:', 0
        lsbMessage: db 'The index of the least significant bit is: ', 0
        msbMessage: db 'The index of the most significant bit is: ', 0
        bitCountMessage: db 'The number of bits set is: ', 0

        

section .bss
        ; Declare/reserve some 4-byte variables
        number resb 4
        lsb resb 4
        ; numShiftLsb is a hack to work around the fact that it's a pain in the ass to
        ; shift by a variable amount. It is number except shifted such that the lsb is
        ; at index 0.
        numShiftLsb resb 4
        msb resb 4
        bitCount resb 4


section .text

_start:

        call ReadInput 

        call FindLSB
        call FindMSB
        call FindBitCount

        call Finish

ReadInput:
        ; Write initial prompt to stdout
        mov edx, prompt
        call WriteString
        call Crlf

        ; Read Their input, show the binary for reference,
        ; and carriage return
        call ReadHex
        call WriteBin
        call Crlf

        ; Store input and return
        mov [number], eax

        ret



FindLSB:
        ;; Store eax and ebx
        push eax
        push ebx

        ; eax is the number
        mov eax, [number]
        ; ebx is the counter
        mov ebx, 0

        ; Call the meat and potatoes
        call DoFindLSB
        
        ; store result
        mov [numShiftLsb], eax
        mov [lsb], ebx

        ;; Restore eax and ebx then return
        pop eax
        pop ebx
        ret

DoFindLSB:

        ; If our number has no bits, return
        cmp eax, 0
        je return

        ; When we encounter our first bit at position zero, return
        test eax, 1
        jnz return

        ; Shift our number one to the right and increment our counter
        shr eax, 1
        inc ebx
        
        ; If we get to here, move back up to the top of the loop
        jmp DoFindLSB

FindMSB:

        ;; Save eax and ebx
        push eax
        push ebx

        ; eax is the original number, shifted such that the lsb is
        ; at position 0
        mov eax, [numShiftLsb]
        ; our counter is initialized to lsb - 1
        mov ebx, [lsb]
        dec ebx

        ; Call the meat and potatoes.
        call DoFindMSB
        
        ; Store the result
        mov [msb], ebx

        ;; Restore eax and ebx then return
        pop eax
        pop ebx
        ret

DoFindMSB:
        ; Shift our number to the right and increment the counter
        shr eax, 1
        inc ebx

        ; If we're out of bits, return
        cmp eax, 0
        jne DoFindMSB

        ret

;; FindBitCount is functionally similar to the following C snippet
; int bitCount(int number) {
; 	int count = 0;
; 	while (number != 0) {
; 		if (number & 1 == 1) {
; 			count++;
; 		}
; 		number = number >> 1;
; 	}
; 	return count;
; }
FindBitCount:
        ;; Save eax and ebx
        push    eax
        push    ebx

        ; ebx is the number we shift repeatedly
        mov     ebx, [number]
        ; eax is the bit count
        mov     eax, 0

        ; Call the entry-point into the functional code
        call FindBitCountWhile1

        ; Store result
        mov [bitCount], eax

        ;; Restore eax and ebx then return
        pop     eax
        pop     ebx
        ret

FindBitCountWhile1:
        ;; Only continue while ebx is not zero
        cmp     ebx, 0
        je      return
        ; If the rightmost bit of the number is not 0, skip to the end
        ; of the while loop
        test    ebx, 1
        jz      FindBitCountWhile2
        ; If the rightmost bit is zero, then increment the bit count
        inc     eax
FindBitCountWhile2:
        ; Bit-shift the number to the right once and
        ; jump to the top of the loop
        shr     ebx, 1
        jmp     FindBitCountWhile1



Finish:
        ; Display LSB
        mov edx, lsbMessage
        call WriteString

        mov eax, [lsb]
        call WriteInt
        call Crlf


        ; Display MSB
        mov edx, msbMessage
        call WriteString

        mov eax, [msb]
        call WriteInt
        call Crlf
        
        ; Display Count
        mov edx, bitCountMessage
        call WriteString

        mov eax, [bitCount]
        call WriteInt
        call Crlf

        ; Exit
        jmp exit

exit:
        mov eax, 01h    ; exit
        mov ebx, 0h     ; errno

        int 80h


;Just a helper for conditional returns (and therefore cleaner-looking code)
return:
        ret