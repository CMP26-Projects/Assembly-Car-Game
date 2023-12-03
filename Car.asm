
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    DATA    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Model compact
.STACK  1024

.data

    ;CarImage
    CarImg        DB   142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142

    ;CarDimensions
    CAR_SIZE      EQU  6
    PosX          DW   ?
    PosY          DW   ?


    ;CarTodraw  info
    CarToDrawSize DW   ?
    CarToDraw     DW   ?
    CarToDrawX    DW   ?
    CarToDrawY    DW   ?

    ; Screen Info
    SCREEN_WIDTH  EQU  320
    SCREEN_HEIGHT EQU  200
    SCREEN_SIZE   EQU  SCREEN_WIDTH*SCREEN_HEIGHT


    ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    MACRO    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAW MACRO Img, CarSize, StartPosX, StartPosY
                  MOV  AX, OFFSET Img
                  MOV  CarToDraw, AX

                  MOV  AX, CarSize
                  MOV  CarToDrawSize, AX

                  MOV  AX, StartPosX
                  MOV  CarToDrawX, AX

                  MOV  AX, StartPosY
                  MOV  CarToDrawY, AX

                  CALL DrawCar
ENDM

CLEAR MACRO ClearedSize, ClearedPosX, ClearedPosY
                  MOV  AX , ClearedSize
                  MOV  CarToDraw , ClearedSize

                  MOV  AX , ClearedPosX
                  MOV  CarToDrawX, AX

                  MOV  AX , ClearedPosY
                  MOV  CarToDrawY , AX
                  CALL ClearCarArea
ENDM

.CODE

    ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    PROC    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CalculateBoxVertex PROC
                       MOV  DI , 0
                       MOV  AX , CarToDrawY
                       MOV  BX , SCREEN_WIDTH
                       MUL  BX
                       ADD  AX , CarToDrawX
                       MOV  DI , AX
                       RET
CalculateBoxVertex ENDP


DrawCar PROC
                       MOV  ax , 0A000H
                       MOV  es , ax
                       MOV  DI , 0
                       MOV  cx , CarToDrawSize
                       MOV  SI ,  CarToDraw
                       MOV  DL , 0
                       CALL CalculateBoxVertex

    ROWS_DRAW:         
                       PUSH CX
                       PUSH DI
                       MOV  CX , CarToDrawSize

    COLS_DRAW:         
                       MOV  DL , BYTE PTR [SI]
                       MOV  BYTE PTR ES:[DI] , DL
                       INC  SI
                       INC  DI
                       LOOP COLS_DRAW
                       POP  DI
                       POP  CX
                       ADD  DI, SCREEN_WIDTH
                       LOOP ROWS_DRAW
                       RET
DrawCar ENDP

    ;clear the car's image from the screen
ClearCarArea PROC
                       MOV  ax , 0A000H
                       MOV  es , ax
                       MOV  cx , CarToDrawSize
                       CALL CalculateBoxVertex
    ROWS_CLEAR:        
                       PUSH CX
                       PUSH DI
                       MOV  CX , CarToDrawSize
    COLS_CLEAR:        
                       MOV  BYTE PTR ES:[DI] , 04H
                       INC  DI
                       LOOP COLS_CLEAR

                       POP  DI
                       POP  CX
                       ADD  DI, SCREEN_WIDTH
                       LOOP ROWS_CLEAR
                       RET
ClearCarArea ENDP


MAIN PROC FAR
    
                       MOV  AX,@DATA
                       MOV  DS,AX
                       MOV  ax , 0A000H
              
    ;video mode
                       MOV  es , ax
                       MOV  AH , 0
                       MOV  AL , 13H
                       INT  10H

    ; set initial pos of car in the game
                       MOV  PosX , (SCREEN_WIDTH-CAR_SIZE)/2
                       MOV  PosY , (SCREEN_HEIGHT-CAR_SIZE)/2
                       Draw CarImg, CAR_SIZE, PosX , PosY

    mainLoop:          
                       mov  DI,0H
                       mov  ah, 00h
                       int  16h                                  ; wait for key press - store key in ah
    ; Handle arrow keys (ah stores the scan code of the key not the ASCII code)
                       cmp  ah, 48h                              ; up arrow
                       je   moveUp
                       cmp  ah, 50h                              ; down arrow
                       je   moveDown
                       cmp  ah, 4bh                              ; left arrow
                       je   moveLeft
                       cmp  ah, 4dh                              ; right arrow
                       je   moveRight
                       cmp  ah, 01h                              ; escape
                       jne  bridge
                       jmp  exit
    bridge:            
                       jmp  mainLoop                             ; keep looping

    moveUp:            
                       CALL ClearCarArea

                       SUB  PosY , 1
                       Draw CarImg, CAR_SIZE, PosX , PosY

                       jmp  mainLoop
    moveDown:          
                       CALL ClearCarArea

                       ADD  PosY , 1
                       Draw CarImg, CAR_SIZE, PosX , PosY

                       jmp  mainLoop
                     
    moveLeft:          
                       CALL ClearCarArea

                       SUB  PosX , 1
                       Draw CarImg, CAR_SIZE, PosX , PosY

                       jmp  mainLoop
    moveRight:         
                       CALL ClearCarArea

                       ADD  PosX , 1
                       Draw CarImg, CAR_SIZE, PosX , PosY

                       jmp  mainLoop
    exit:              
                       HLT
MAIN ENDP
END MAIN