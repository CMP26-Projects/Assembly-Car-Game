
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    DATA    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Model compact
.STACK  1024

.data

        ;CarImage
        CarImg1                 DB   142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142
        CarImg2                 DB   142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142

        ;CarDimensions
        CAR_SIZE                EQU  6
        PosXfirst               DW   ?
        PosYfirst               DW   ?
        PosXsecond              DW   ?
        PosYsecond              DW   ?

        PosX    DW  ?
        PosY    DW  ?
        

        ;CarTodraw  info
        CarToDrawSize           DW   ?
        CarToDraw               DW   ?
        CarToDrawX              DW   ?
        CarToDrawY              DW   ?

    ; Screen Info
    SCREEN_WIDTH   EQU  320
    SCREEN_HEIGHT  EQU  200
    SCREEN_SIZE    EQU  SCREEN_WIDTH*SCREEN_HEIGHT

    ; ;Buffer for reading input keys
    ; BufferSize     EQU  30000
    ; Buffer         DB   BufferSize DUP(?)
    ; bufferHead     DW   0
    ; bufferTail     DW   0

    ;ButtonFlags
    UpFlag         DB   ?
    DownFlag       DB   ?
    LeftFlag       DB   ?
    RightFlag      DB   ?

    ;Arrow flags to check whether this key is pressed down or not
    ArrowUpFlag    DB   0
    ArrowDownFlag  DB   0
    ArrowLeftFlag  DB   0
    ArrowRightFlag DB   0
   
    ;WASD flags to check whether this key is pressed down or not
    WFlag   DB  0
    AFlag   DB  0
    SFlag   DB  0
    DFlag   DB  0


    ;Arrow Keys for movement
    ArrowUp        DB   48H
    ArrowDown      DB   50H
    ArrowLeft      DB   4BH
    ArrowRight     DB   4DH

    ;WASD keys for movement
    WKey db 11h
    AKey db 1Eh
    SKey db 1Fh
    DKey db 20h

    ;Used to save scan codes to indicate the used system of movement(WASD or arrows)
    UpKeyCode      DB   ?
    DownKeyCode    DB   ?
    LeftKeyCode    DB   ?
    RightKeyCode   DB   ?


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

SETKEYS MACRO Up, Down , Left, Right

                               MOV   DL , Up
                               MOV   UpKeyCode , DL

                               MOV   DL , Down
                               MOV   DownKeyCode , DL

                               MOV   DL , Left
                               MOV   LeftKeyCode , DL

                               MOV   DL , Right
                               MOV   RightKeyCode , DL


                              ; CALL InputButtonSwitchCase
ENDM

    ;Setting Flags to be checked while movement
SetFlags MACRO f1 , f2 , f3 , f4

                                MOV   DL , f1
                                MOV   UpFlag , DL

                                MOV   DL , f2
                                MOV   DownFlag , DL

                                MOV   DL , f3
                                MOV   LeftFlag , DL

                                MOV   DL , f4
                                MOV   RightFlag , DL

ENDM

SetPosition  MACRO X , Y
    MOV DX , X
    MOV PosX, DX

    MOV DX , Y
    MOV PosY, DX
ENDM

Update1 MACRO
                        CLEAR CAR_SIZE, PosXfirst, PosYfirst
                        CALL UpdateCar1Pos
                        CALL UpdateArrowFlags
                        Draw  CarImg1, CAR_SIZE, Posxfirst , PosYfirst
ENDM


.CODE

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    PROC    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CalculateBoxVertex PROC
                       MOV   DI , 0
                       MOV   AX , CarToDrawY
                       MOV   BX , SCREEN_WIDTH
                       MUL   BX
                       ADD   AX , CarToDrawX
                       MOV   DI , AX
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
                       MOV   ax , 0A000H
                       MOV   es , ax
                       MOV   cx , CarToDrawSize
                       CALL  CalculateBoxVertex
    ROWS_CLEAR:        
                       PUSH  CX
                       PUSH  DI
                       MOV   CX , CarToDrawSize
    COLS_CLEAR:        
                       MOV   BYTE PTR ES:[DI] , 04H
                       INC   DI
                       LOOP  COLS_CLEAR

                       POP   DI
                       POP   CX
                       ADD   DI, SCREEN_WIDTH
                       LOOP  ROWS_CLEAR
                       RET
ClearCarArea ENDP

InputButtonSwitchCase PROC  FAR
                 
                       cmp   al, 01h
                       jne   bridge
    ;esc logic
                       jmp   exit
    bridge:            

    ; up arrow
                       cmp   al, UpKeyCode
                       JNE   NotPressed1
                       MOV   UpFlag , 1
                       JMP   Default
    NotPressed1:       
                       MOV   BL , UpKeyCode
                       ADD   BL, 80H
                       CMP   AL ,  BL
                       JNE   CheckLeft
                       MOV   UpFlag , 0
                       JMP   Default
    CheckLeft:         
    ; left arrow
                       CMP   AL, LeftKeyCode
                       JNE   NotPressed2
                       MOV   LeftFlag , 1
                       JMP   Default
    NotPressed2:       
                       MOV   BL , LeftKeyCode
                       ADD   BL, 80H
                       CMP   AL , BL
                       JNE   checkDown
                       MOV   LeftFlag , 0
                       JMP   Default

    checkDown:         
    ; down arrow
                       cmp   AL, DownKeyCode
                       JNE   NotPressed3
                       MOV   DownFlag , 1
                       JMP   Default
    NotPressed3:       
                       MOV   BL , DownKeyCode
                       ADD   BL, 80H
                       CMP   AL , BL
                       JNE   checkRight
                       MOV   DownFlag , 0
                       JMP   Default
    
    checkRight:        
    ; right arrow
                       CMP   AL , RightKeyCode
                       JNE   NotPressed4
                       MOV   RightFlag , 1
                       JMP   Default
    NotPressed4:       
                       MOV   BL , RightKeyCode
                       ADD   BL, 80H
                       CMP   AL , BL
                       JNE   Default
                       MOV   RightFlag , 0

    Default:              
    
                        RET
InputButtonSwitchCase ENDP

CheckFlags PROC FAR

    ;------- checking Flags -------
	
                          CMP      UpFlag , 1
                          JNE      CmpLeft
                          SUB      PosY , 1
    CmpLeft:              
                          CMP      LeftFlag , 1
                          JNE      CmpDown
                          SUB      PosX, 1
    CmpDown:              
                          CMP      DownFlag , 1
                          JNE      CmpRight
                          ADD      PosY, 1

    CmpRight:             
                          CMP      RightFlag, 1
                          JNE      CmpFinish
                          ADD      PosX , 1

    CmpFinish:            
                         RET
CheckFlags ENDP


;Update Flags after each game loop 
 UpdateArrowFlags PROC FAR
   
     MOV BL , UpFlag
     MOV ArrowUpFlag, BL

    MOV BL , DownFlag
    MOV ArrowDownFlag ,  BL

    MOV BL , LeftFlag
    MOV ArrowLeftFlag, BL

    MOV BL , RightFlag
    MOV ArrowRightFlag , BL
     RET
 UpdateArrowFlags ENDP

;description
UpdateCar1Pos PROC
    MOV DX , PosX
    MOV PosXfirst, DX

    MOV DX, PosY
    MOV PosYfirst, DX
    RET
UpdateCar1Pos ENDP

;description
UpdateCar2Pos PROC
    MOV DX , PosX
    MOV PosXsecond, DX

    MOV DX, PosY
    MOV PosYsecond, DX
    RET
UpdateCar2Pos ENDP

;description
UpdateWASDFlags PROC
    MOV BL , UpFlag
     MOV WFlag, BL

    MOV BL , DownFlag
    MOV SFlag ,  BL

    MOV BL , LeftFlag
    MOV AFlag, BL

    MOV BL , RightFlag
    MOV DFlag , BL
     RET
UpdateWASDFlags ENDP

;description

;procedure calls all arrow keys functions
CheckArrowKeys PROC
                        SetPosition PosXfirst, PosYfirst
                        SETKEYS ArrowUp, ArrowDown, ArrowLeft, ArrowRight
                        SetFlags ArrowUpFlag, ArrowDownFlag, ArrowLeftFlag, ArrowRightFlag
                        CALL InputButtonSwitchCase
                        CALL CheckFlags
                        
                        RET
                        ;CALL UpdateArrowFlags
CheckArrowKeys ENDP

;procedure calls all WASD keys functions
CheckWASDKeys PROC
                        SetPosition PosXsecond, PosYsecond
                        SETKEYS WKey, SKey, AKey, DKey
                        SetFlags WFlag, SFlag, AFlag, DFlag
                        CALL InputButtonSwitchCase

                        CLEAR CAR_SIZE, PosXsecond, PosYsecond
                        CALL CheckFlags
                        CALL UpdateCar2Pos
                        CALL UpdateWASDFlags
                        Draw  CarImg2, CAR_SIZE, PosXsecond , PosYsecond
                 
                        RET
                        ;CALL UpdateArrowFlags
CheckWASDKeys ENDP

INT09H PROC FAR
                            IN     AL, 60H
 ; escape
;                           cmp      AL, 01h
;                           JNE      cont                                                      ;made as a bridge to avoid far jumps
;                           JMP      exit
;    cont:
                            
                            CALL CheckArrowKeys
                            ;CALL CheckWASDKeys

                                               
                            MOV AL , 20H
                            OUT 20H, AL
                            IRET
INT09H ENDP


MAIN PROC FAR

                       MOV   AX,@DATA
                       MOV   DS,AX
                       MOV   ax , 0A000H
              
    ;video mode
                       MOV   es , ax
                       MOV   AH , 0
                       MOV   AL , 13H
                       INT   10H

     ; set initial pos of first car in the game
                MOV  PosXfirst , (SCREEN_WIDTH-CAR_SIZE)/2
                MOV  PosYfirst , (SCREEN_HEIGHT-CAR_SIZE)/2
                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst

                ; set initial pos of second car in the game
                MOV  PosXsecond , (SCREEN_WIDTH-CAR_SIZE)/3
                MOV  PosYsecond , (SCREEN_HEIGHT-CAR_SIZE)/3
                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond

                MOV DX , PosXfirst
                MOV PosX, DX

                MOV DX , PosYfirst
                MOV PosY, DX
     mainLoop:          
     ;--------------    Overriding INT 9H   ---------------
    ;Disable interrrupts
                          CLI
                       
    ;Saving DS it will be the base of the addressing mode inside the interrupt
                          PUSH     DS
                          MOV      AX , CS
                          MOV      DS , AX

    ;changing interrup vector
                          MOV AX , 2509H
                          LEA DX , INT09H
                          INT 21H
                            
    ;re-enabling interrupts
                          POP DS
                          STI

                        MOV DX , PosXfirst
                        CMP PosX, DX
                        JE bridge1
                        Update1
    bridge1:
                        MOV DX , PosYfirst
                        CMP POSY , DX
                        JE bridge2
                        Update1
    bridge2:
                         MOV   CX , 10000
     WasteTime:         
                        LOOP  WasteTime

                       JMP  mainLoop                             ; keep looping
    exit:              
                       HLT
MAIN ENDP
END MAIN
            ;                 in al, 60h                            
            ;                 ;copying scan codes          
            ;                 MOV   DL , ArrowUp
            ;                 MOV   UpKeyCode , DL

            ;                 MOV   DL , ArrowLeft
            ;                 MOV   LeftKeyCode , DL


            ;                 MOV   DL , ArrowUpFlag
            ;                 MOV   UpFlag , DL

            ;                 MOV   DL , ArrowLeftFlag
            ;                 MOV   LeftFlag , DL


            ;                 cmp   al, 01h
            ;                 jne   b
            ; ;esc logic
            ;                 jmp   exit
            ; b:            

            ; ; up arrow
            ;                 cmp   al, UpKeyCode
            ;                 JNE   N
            ;                 MOV   UpFlag , 1
            ;                 JMP   D
            ; N:  
            ;                 MOV   BL , UpKeyCode
            ;                 ADD   BL, 80H
            ;                 CMP   AL ,  BL
            ;                 JNE   la
            ;                 MOV   UpFlag , 0
            ;                 JMP   D
            
            ; la:
            ; ; left arrow
            ;            CMP   AL, LeftKeyCode
            ;            JNE   N2
            ;            MOV   LeftFlag , 1
            ;            JMP   D
            ;  N2:       
            ;            MOV   BL , LeftKeyCode
            ;            ADD   BL, 80H
            ;            CMP   AL , BL
            ;            JNE   D
            ;            MOV   LeftFlag , 0

            ; D:   


                    
            ;             MOV BL , UpFlag
            ;             MOV ArrowUpFlag, BL
                        



                        ; CLEAR CAR_SIZE, PosXsecond, PosYsecond
                        ; CALL CheckFlags
                        ; Draw  CarImg2, CAR_SIZE, PosXsecond , PosYsecond
                 
                ;    
                       

    ; moveUp:            
    ;                    CALL ClearCarArea

    ;                    SUB  PosYfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop
    ; moveDown:          
    ;                    CALL ClearCarArea

    ;                    ADD  PosYfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop
                     
    ; moveLeft:          
    ;                    CALL ClearCarArea

    ;                    SUB  Posxfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop
    ; moveRight:         
    ;                    CALL ClearCarArea

    ;                    ADD  Posxfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop

;-----------------------------  Previous Work   -----------------------------------------                   
    
    ; checkLeft:
    ; ; left arrow
    ;                    cmp   al, 4bh
    ;                    jne   checkRight
    ; ;Left logic
    ;                    CALL  ClearCarArea
    ;                    SUB   Posxfirst , 1
    ;                    Draw  CarImg1, CAR_SIZE, Posxfirst , PosYfirst
    ; checkDown:
    ; ; down arrow
    ;                    cmp   al, 50h
    ;                    jne   checkLeft
    ; ;Down logic
    ;                    CALL  ClearCarArea
    ;                    ADD   PosYfirst , 1
    ;                    Draw  CarImg1, CAR_SIZE, Posxfirst , PosYfirst
                       
    ; checkRight:
    ; ; right arrow
    ;                    cmp   al, 4dh
    ;                    jne   checkEsc
    ; ;Right logic
    ;                    CALL  ClearCarArea
    ;                    SUB   Posxfirst , 1
    ;                    Draw  CarImg1, CAR_SIZE, Posxfirst , PosYfirst
    

    ; moveUp:
    ;                    CALL ClearCarArea

    ;                    SUB  PosYfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop
    ; moveDown:
    ;                    CALL ClearCarArea

    ;                    ADD  PosYfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop
                     
    ; moveLeft:
    ;                    CALL ClearCarArea

    ;                    SUB  Posxfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop
    ; moveRight:
    ;                    CALL ClearCarArea

    ;                    ADD  Posxfirst , 1
    ;                    Draw CarImg1, CAR_SIZE, Posxfirst , PosYfirst

    ;                    jmp  mainLoop