; Caleb Falcione
; 2017-10-05
;
; Assignment 4
; Sort N integers


; Include helper library
%include "along32.inc"

global _start
section .data
        ; Store some constant strings
        prompt: db 'Enter at most 1024 integers separated by newlines, followed by a zero:', 0
        space: db ' ', 0
        array times 1024 db 0 ; note that I just happened to name it 'array'. I could have named it anything
        

section .bss
        ; Declare/reserve some 4-byte variables
        count resb 4


section .text

_start:

        call ReadInput
        call Finish


ReadInput:
        ; Write prompt
        mov edx, prompt
        call WriteString
        call Crlf

        ; Read
        call DoReadInput
        jmp return

DoReadInput:
        ; Read in the next integer
        call ReadInt

        ; If they gave a zero, stop reading in numbers
        cmp eax, 0
        je return

        call InsertIntoArray

        ; If we have space for another input, read in another
        cmp dword [count], 1024
        jl DoReadInput

        ; If we're out of space, don't read anything else
        jmp return


;; Insert the value eax into the array, such that it is sorted
InsertIntoArray:
        ; Find the index to insert at
        call FindInsertIndex

        ; Shift the array to the right to accomodate the new value
        call ShiftRight

        ; Actually insert the new value
        mov [array + ebx * 4], eax

        ; Increment count and return
        inc dword [count]
        jmp return


;; Functionaly similar to the following Python3 snippet:
; def findInsertIndex(nums, target):
;       for i, num in enumerate(nums):
;               if target >= num: 
;                        return i
;       return len(nums)
FindInsertIndex:
        ; Save ecx
        push ecx

        ; ecx is our counter
        mov ecx, 0

        ; Jump to the meat and potatoes
        call FindInsertIndex_LoopCondition

        ; Store result in ebx
        mov ebx, ecx

        ; Restore ecx and return
        pop ecx
        jmp return

FindInsertIndex_LoopBody:
        ; Return if the current number is less than the target
        cmp eax, [array + ecx * 4]
        jl return
        ; Otherwise increment the counter and continue
        inc ecx

FindInsertIndex_LoopCondition:
        ; Execute loop body while the counter is less than the size
        cmp ecx, [count]
        jl FindInsertIndex_LoopBody
        jmp return


;; Functionally similar to the following Java snippet:
; void shiftRight(int[] array, int start) {
;       for (int i = array.length; i > start; i--) {
;               array[i] = array[i - 1];
;       }
; }
ShiftRight:
        ; Store eax and ecx
        push eax
        push ecx

        ; ecx is the loop counter
        mov ecx, [count]
        
        call ShiftRight_LoopCondition

        ; Restore ecx and eax then return
        pop ecx
        pop eax
        jmp return
        

ShiftRight_LoopBody:
        ; Move the left index's value into the current index
        mov eax, [array + (ecx * 4) - 4]
        mov [array + ecx*4], eax
        ; Decrement the loop counter and continue
        dec ecx

ShiftRight_LoopCondition:
        ; Execute the loop body iff the loop counter is greater than the target
        cmp ecx, ebx
        jg ShiftRight_LoopBody

        jmp return

;; Functionally similar to the following C++ snippet:
; void printArray(int array[], int size){
;       for(int i = 0; i < size; i++) {
;               printf("%d", array[i]);
;        }
;       printf("\n");
; }
PrintArray:
        ; Store ecx and edx
        push ecx
        push edx

        ; ecx is the loopcounter
        mov ecx, 0
        ; Go ahead and move the space string to edx for later calls
        ; to WriteString
        mov edx, space

        call PrintArray_LoopCondition
        call Crlf

        ; Restore ecx and edx then return
        pop ecx
        pop edx
        jmp return

PrintArray_LoopBody:
        ; Print the integer at the current index
        mov eax, [array + ecx * 4]
        call WriteInt
        ; Write the delimeter string
        call WriteString
        ; Increment the loop counter
        inc ecx

PrintArray_LoopCondition:
        ; Execute the loop body for each index in the array
        cmp ecx, [count]
        jl PrintArray_LoopBody
        jmp return

Finish:
        ; Print the array
        call PrintArray
        ; Exit
        jmp exit


exit:
        mov eax, 01h    ; exit
        mov ebx, 0h     ; errno

        int 80h


; Just a helper for conditional returns (and therefore cleaner-looking code)
return:
        ret