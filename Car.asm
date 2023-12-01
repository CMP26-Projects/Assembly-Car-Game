.model small
.stack 64 


.data
message db "Hello World!$"

.CODE
main proc far
mov ax,@data
mov ds,ax

mov ah,9
lea dx,message
int 21h

main ENDP
END main