.model compact
.stack 1024

.data

    ; Box Top left dimension & size
    Xpos         DB            ?
    Ypos         DB            ?
    BOX_SIZE     EQU           15

    ;Screen dimensions
    SCREEN_WIDTH DB            320
                 SCREEN_HEIGHT

.CODE
main proc far
         mov ax,@data
         mov ds,ax

         mov

main ENDP
END main