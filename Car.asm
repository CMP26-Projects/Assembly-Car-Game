; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    MACRO    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    DATA    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Model compact
.STACK  1024

.data

    ;CarImage
    CarImg        DB  142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142

    ;CarDimensions
    CAR_SIZE      EQU 6
    PosX          DW  ?
    PosY          DW  ?


    ;CarTodraw  info
    CarToDrawSize DB  ?
    CarToDraw     DB  ?
    CarToDrawX    DB  ?
    CarToDrawY    DB  ?

    ; Screen Info
    SCREEN_WIDTH  EQU 320
    SCREEN_HEIGHT EQU 200
    SCREEN_SIZE   EQU SCREEN_WIDTH*SCREEN_HEIGHT



.CODE

CalculateBoxVertex PROC
                       MOV  DI , 0
                       MOV  AX , PosY
                       MOV  BX , SCREEN_WIDTH
                       MUL  BX
                       ADD  AX , PosX
                       MOV  DI , AX
                       RET
CalculateBoxVertex ENDP


DrawCar PROC
                       MOV  ax , 0A000H
                       MOV  es , ax
                       MOV  DI , 0
                       MOV  cx , CAR_SIZE
                       LEA  SI ,  CarImg
                       MOV  DL , 0
                       CALL CalculateBoxVertex

    ROWS_DRAW:         
                       PUSH CX
                       MOV  CX , CAR_SIZE

    COLS_DRAW:         
                       MOV  DL , BYTE PTR [SI]
                       MOV  BYTE PTR ES:[DI] , DL
                       INC  SI
                       INC  DI
                       LOOP COLS_DRAW
                       POP  CX
                       ADD  DI, SCREEN_WIDTH-CAR_SIZE
                       LOOP ROWS_DRAW
                       RET
DrawCar ENDP

    ;clear the car's image from the screen
CLEAR_CAR_AREA PROC
                       MOV  ax , 0A000H
                       MOV  es , ax
                       MOV  cx , CAR_SIZE
                       CALL CalculateBoxVertex
    ROWS_CLEAR:        
                       PUSH CX
                       MOV  CX , CAR_SIZE
    COLS_CLEAR:        
                       MOV  BYTE PTR ES:[DI] , 04H
                       INC  DI
                       LOOP COLS_CLEAR

                       POP  CX
                       ADD  DI, SCREEN_WIDTH-CAR_SIZE
                       LOOP ROWS_CLEAR
                       RET
CLEAR_CAR_AREA ENDP


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
                       CALL DrawCar

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
                       je   exit
                       jmp  mainLoop                             ; keep looping

    moveUp:            
                       CALL CLEAR_CAR_AREA

                       SUB  PosY , 1
                       CALL DrawCar
                       jmp  mainLoop
    moveDown:          
                       CALL CLEAR_CAR_AREA

                       ADD  PosY , 1
                       CALL DrawCar
                       jmp  mainLoop
                     
    moveLeft:          
                       CALL CLEAR_CAR_AREA

                       SUB  PosX , 1
                       CALL DrawCar
                       jmp  mainLoop
    moveRight:         
                       CALL CLEAR_CAR_AREA

                       ADD  PosX , 1
                       CALL DrawCar
                       jmp  mainLoop
    exit:              
                       HLT
MAIN ENDP
END MAIN