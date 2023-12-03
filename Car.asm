;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    MACROS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    DATA    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Model compact
.STACK  64


.data

    
    ;CarImage
    CarImg        DB  142, 142, 142, 142, 0, 0, 0, 0, 142, 142, 142, 142, 142, 142, 142, 142, 0, 0, 0, 0, 142, 142, 142, 142, 142, 142, 46, 46, 46, 46, 46, 46, 46, 46, 142, 142, 142, 142, 46, 46
                  DB  46, 46, 46, 46, 46, 46, 142, 142, 0, 0, 46, 46, 16, 16, 112, 112, 46, 46, 0, 0, 0, 0, 46, 46, 16, 16, 112, 112, 46, 46, 0, 0, 0, 0, 46, 46, 112, 112, 16, 16
                  DB  46, 46, 0, 0, 0, 0, 46, 46, 112, 112, 16, 16, 46, 46, 0, 0, 142, 142, 46, 46, 46, 46, 46, 46, 46, 46, 142, 142, 142, 142, 46, 46, 46, 46, 46, 46, 46, 46, 142, 142
                  DB  142, 142, 142, 142, 0, 0, 0, 0, 142, 142, 142, 142, 142, 142, 142, 142, 0, 0, 0, 0, 142, 142, 142, 142
    ;CarDimensions
    CAR_SIZE      EQU 12
    PosX          DB  ?
    PosY          DB  ?

    ; Screen Info
    SCREEN_WIDTH  EQU 320
    SCREEN_HEIGHT EQU 200
    SCREEN_SIZE   EQU SCREEN_WIDTH*SCREEN_HEIGHT


;     ;Reserving a block for buffer
; section .bss
;         BackBufferCar1 resb    CAR_SIZE*CAR_SIZE

.CODE

CalculateBoxVertex PROC
                       MOV  AH , 0
                       MOV  Al , PosY
                       MOV  BX , SCREEN_WIDTH
                       MUL  BX

                       MOV  DH , 0
                       MOV  DL , PosX
                       Add  AX , DX
                       MOV  DI , AX
                       RET
CalculateBoxVertex ENDP

    ;Drawing in back buffer to avoid flickering
DrawInBackBuffer PROC
    ;Taking segment 0881H as our Back Buffer

                       MOV  ax , 0A000H
                       MOV  es , ax 

                       CALL CalculateBoxVertex
                       MOV  cx , CAR_SIZE
                       MOV  SI , OFFSET CarImg
                       MOV  DL , 0
                       MOV  BX , 0                                 ;counter for back buffer

    Rows:              
                       PUSH CX
                       MOV  CX , CAR_SIZE

    Cols:              
                       MOV  DL , BYTE PTR [SI]
                       MOV  BYTE PTR ES:[DI] , DL
                       INC  SI
                       INC  DI
                       LOOP Cols

                       POP  CX
                       ADD  DI, SCREEN_WIDTH-CAR_SIZE
                       LOOP Rows
                      ; CALL MoveBackToFront
                       RET
DrawInBackBuffer ENDP


    ;This procedure moves back buffer into front buffer
MoveBackToFront Proc
                       
                    ;    PUSH DS
                    ;    XOR  SI , SI                                ;CLEARING SI
                    ;    XOR
                    ;    MOV  DS , ES
                    ;    POP  DS


    ;This procedure moves back buffer into front buffer
MoveBackToFront ENDP



MAIN PROC FAR
    
                       MOV  AX,@DATA
                       MOV  DS,AX
                       MOV  ax , 0A000H
                       MOV  es , ax
    ;video mode
                       MOV  AH , 0
                       MOV  AL , 13H
                       INT  10H

    ; set initial pos of car in the game
                       MOV  PosX , (SCREEN_WIDTH - CAR_SIZE)/2
                       MOV  PosY , (SCREEN_HEIGHT - CAR_SIZE)/2

                       CALL DrawInBackBuffer

MAIN ENDP
END MAIN
