.Model compact
.STACK  1024

.data                                                                                                                                                        

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    MACROS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DRAWIMAGE MACRO IMG, WID, HEI, STARX, STARY
              LOCAL ROWS, COLS
              PUSH  CX
    ;VIDEO MEMORY
              MOV   AX, 0A000H
              MOV   ES, AX

              MOV   DI, STARY
              MOV   AX, SCREEN_WIDTH
              MUL   DI
              MOV   DI, AX
              ADD   DI, STARX
    
              MOV   CX, HEI
              MOV   SI, OFFSET IMG

    ROWS:     
              PUSH  CX
              PUSH  DI
              MOV   CX, WID
    COLS:     
              MOV   DL, BYTE PTR [SI]
              MOV   ES:[DI], DL
              INC   SI
              INC   DI
              LOOP  COLS
              POP   DI
              POP   CX
              ADD   DI, SCREEN_WIDTH
              LOOP  ROWS
              MOV   DI, STARY
              MOV   AX, SCREEN_WIDTH
              MUL   DI
              MOV   DI, AX
              ADD   DI, STARX
              ADD   DI, WID
              POP   CX
ENDM


CalculateBoxVertex macro 
                       mov    di, PosY
                       imul   di, SCREEN_WIDTH                       ; di = BOXY * SCREEN_WIDTH (two operand multiplication)
                       add    di, PosX
ENDM


DrawCar MACRO  
    LOCAL Rows , cols

MOV ax , 0A000H
MOV es , ax

MOV DI , 0

MOV cx , CAR_SIZE
MOV SI , BYTE PTR CarImg

CalculateBoxVertex

Rows:
    PUSH CX

    Cols:
    MOV ES:[DI] , SI
    INC SI
    INC DI
    LOOP Cols

    POP CX
    ADD DI, SCREEN_WIDTH-CAR_SIZE
    LOOP Rows

    
ENDM


.CODE

MAIN PROC FAR
    
         MOV    AX,@DATA
         MOV    DS,AX
         MOV ax , 0A000H
         MOV es , ax
    
        MOV AH , 0
        MOV AL , 13H
        INT 10H

    ; set initial pos of car in the game

    MOV PosX , (SCREEN_WIDTH-CAR_SIZE)/2
    MOV PosY , (SCREEN_HEIGHT-CAR_SIZE)/2


MAIN ENDP
END MAIN
