.386
DATA SEGMENT USE16                                                                                                                                                            ; Equivalent to .data in 32-bit ; Doctor Allowed using .386

    ;CarImage
    CarImg        DB  142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142
    
    ;CarDimensions
    CAR_SIZE      EQU 6
    PosX          DB  ?
    PosY          DB  ?

    ; Screen Info
    SCREEN_WIDTH  EQU 320
    SCREEN_HEIGHT EQU 200
    SCREEN_SIZE   EQU SCREEN_WIDTH*SCREEN_HEIGHT



DATA ENDS                                                                                                                                                                     ; It must be ended unlike .data in 32-bit

CODE SEGMENT USE16                 ; Equivalent to .code in 32-bit
         ASSUME CS:CODE,DS:DATA    ; To tell him to replace .data and .code with CODE and DATA


 CalculateBoxVertex macro 
                       mov    di, PosY
                       imul   di, SCREEN_WIDTH                       ; di = BOXY * SCREEN_WIDTH (two operand multiplication)
                       add    di, PosX
ENDM

DrawCar MACRO  

MOV ax , 0A000H
MOV es , ax

MOV DI , 0

MOV cx , CAR_SIZE
MOV SI , BYTE PTR CarImg
CALL CalculateBoxVertex

Rows:
    PUSH CX

    Col:
    MOV ES:[DI] , SI
    INC SI
    INC DI
    LOOP Col

    POP CX
    ADD DI, SCREEN_WIDTH-CAR_SIZE
    LOOP Rows

    
ENDM

Main PROC FAR
    
         MOV    AX,DATA
         MOV    DS,AX
    
            MOV ax , 0A000H
            MOV es , ax
    
    ; set initial pos of car in the game

    MOV PosX , (SCREEN_WIDTH-CAR_SIZE)/2
    MOV PosY , (SCREEN_HEIGHT-CAR_SIZE)/2

    CALL DrawCar 


CODE ENDS
Main ENDP
END Main