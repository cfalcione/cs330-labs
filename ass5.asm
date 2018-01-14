; Caleb Falcione
; 2017-11-15
;
; Assignment 5
; Quadratic Formula


; Include helper library
%include "along32.inc"
; We want C's scanf and printf
extern scanf, printf

global _start
section .data
        ; Store some constant strings
        prompt: db 'Enter A, B, and C, separated by newlines:', 0
        invalidA: db 'A must not be zero', 0
        imaginary: db 'Imaginary roots', 0
        scanFormat: db "%f", 0
        result1: db "Roots: %f and ", 0
        result2: db "%f", 0XA, 0
        zero: dd 0.0
        
        

section .bss
        ; Declare some global variables
        ; Read as <name> reserve-bytes <number of bytes>
        a resb 4 
        b resb 4
        c resb 4

        denom resb 4

        center resb 4
        offset resb 4

        root_left resb 4
        root_right resb 4

section .text

_start:

        call ReadInput
        call ValidateA

        call CalculateDenom
        call CalculateCenter
        call CalculateOffset
        call CalculateRoots

        call Finish


ReadInput:
        ;; Write prompt
        mov edx, prompt
        call WriteString
        call Crlf ; newline

        ;; Read A, B, and C

        ; put pointers to a and the format string on the stack
        push a
        push scanFormat
        call scanf
        ; manually adjust the stack, effectively popping
        ; twice without storing anything
        add esp, 8

        push b
        push scanFormat
        call scanf
        add esp, 8

        push c
        push scanFormat
        call scanf
        add esp, 8

        jmp return

; Calculates 2a
CalculateDenom:
        fld dword [a] ; move a onto the float stack
        fadd st0 ; double by adding to itself
        fstp dword [denom] ; pop and store into denom
        
        jmp return


; Calculates -b/(2a)
CalculateCenter:
        fld dword [b] ; move b onto the float stack
        fchs ; negate b
        fdiv dword [denom] ; divide -b by 2a
        fstp dword [center] ; pop and store result

        jmp return


; Calculates sqrt(b^2 - 4ac) / 2a
CalculateOffset:

        ;; Calculate 4ac
        fld dword [a]
        fadd st0 ; double a
        fld dword [c]
        fadd st0 ; double c
        fmulp st1 ; multiply 2a by 2c and pop
          ; ^^^ Notice the use of fmulp here.
          ; fmul by itself would have correctly placed
          ; 4ac at the top of the stack but wouldn't
          ; have cleaned up the 2a unnecessarily hanging
          ; out beneath it in st1.
          ; fmulp stores the result in the operand (st1)
          ; and pops st0. Two birds with one stone.

        ;; Calculate b^2
        fld dword [b]
        fmul st0 ; multiply b by itself

        ;; Check for imaginary numbers
        fucomi
        jb ImaginaryError ; jump if b^2 < 4ac

        ;; Calculate b^2 - 4ac
        fsubrp st1
         ; fsubrp has the same elegance here as fmulp above,
         ; storing the result and cleaning up simultaneously.


        ;; Calculate sqrt( b^2 - 4ac )
        fsqrt

        fdiv dword [denom] ; divide by 2a

        fstp dword [offset] ; store result and pop

        jmp return

; Finishes the quadratic formula
CalculateRoots:

        ; push center once for each root
        fld dword [center]
        fld dword [center]

        ; calculate and pop the left root
        fsub dword [offset]
        fstp dword [root_left]

        ; calculate and pop the right root
        fadd dword [offset]
        fstp dword [root_right]
        

        jmp return

ValidateA:

        fld dword [a]
        fld dword [zero]

        fcomi
        finit ; reset the float stack
        jnz return ; return if valid

        ; otherwise print error message and bail out
        mov edx, invalidA
        call WriteString
        call Crlf

        jmp exit

ImaginaryError:
        mov edx, imaginary
        call WriteString
        call Crlf
        jmp exit


; Writes a float whose pointer is in ebx
; with the format string in edx
WriteF:

        ; We need to add 8 bytes of space to the top
        ; of the stack to fit our qword without overwriting
        ; whatever is currently at the top
        sub esp, 8  

        fld dword [ebx] ; push ebx to the float stack

        ; printf expects a double, but we have a float,
        ; so convert on the way off the stack
        fstp qword [esp]

        push edx ; push the format string on the stack
        call printf
        ; pop 3 variables off the stack without storing
        add esp, 12

        jmp return

Finish:
        mov ebx, root_left
        mov edx, result1
        call WriteF

        mov ebx, root_right
        mov edx, result2
        call WriteF

        jmp exit


exit:
        mov eax, 01h    ; exit
        mov ebx, 0h     ; errno

        int 80h


; Just a helper for conditional returns (and therefore cleaner-looking code)
return:
        ret