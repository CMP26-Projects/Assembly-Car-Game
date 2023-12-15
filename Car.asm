
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    DATA    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Model compact
.STACK  1024

.data

        ;CarImage
        CarImg1                 DB   142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142
        CarImg2                 DB   142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142
        Car1Speed               DW   3
        Car2Speed               DW   1
        CurrentSpeed            DW   ?      ;Stores the speed of the currently updating car 

        ;CarDimensions
        CAR_SIZE                EQU  6
        PosXfirst               DW   ?
        PosYfirst               DW   ?
        PosXsecond              DW   ?
        PosYsecond              DW   ?

        PosX    DW  ?
        PosY    DW  ?
        
        ;previous postions to check for updates
        PrevPosXfirst               DW   ?
        PrevPosYfirst               DW   ?
        PrevPosXsecond              DW   ?
        PrevPosYsecond              DW   ?

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

    ;Boolean to indicate if the path the car is going to move in is safe or not
    ;0 -> Safe , 1->Not Safe
    CanUpdateX    DB  0
    CanUpdateY    DB  0

    ;boolean (up -> 1 or down -> 0)
    YMovement    DB   ?
    ;boolean (right -> 1 or left -> 0)
    XMovement    DB   ?
    ;boolean (CAR1 -> 1 or CAR2 -> 0)
    CarToScan    DB   ?

    ;Buffer to store the background to save it upon movement
    BackgroundBuffer1    DB     Car_Size*Car_Size DUP(?)
    BackgroundBuffer2    DB     Car_Size*Car_Size DUP(?)

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

;CarNo: 1->car1 , 2->Car2
CLEAR MACRO Car, ClearedSize, ClearedPosX, ClearedPosY
            
           MOV  AX , ClearedSize
           MOV  CarToDrawSize , ClearedSize

           MOV  AX , ClearedPosX
           MOV  CarToDrawX, AX

           MOV  AX , ClearedPosY
           MOV  CarToDrawY , AX

            MOV AX, OFFSET Car
            MOV CarToDraw , AX

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


;Scans the path of the car to handle collisions
;pass the left point of the row you want to scan
;carNo -> 1 for first, 0 -> for second
ScanY MACRO x , y , CarNo , MovemetType, Speed
    MOV DX , x
    MOV CarToDrawX , DX

    MOV DX, y
    MOV CarToDrawY , DX

    MOV DL , CarNo
    MOV CarToScan , DL

    MOV DL , MovemetType
    MOV YMovement, DL

    MOV DX , Speed
    MOV CurrentSpeed , DX
ENDM

ScanX MACRO x , y , CarNo , MovemetType, Speed
    MOV DX , X
    MOV CarToDrawX , DX

    MOV DX, y
    MOV CarToDrawY , DX

    MOV DL , CarNo
    MOV CarToScan , DL

    MOV DL , MovemetType
    MOV XMovement, DL

    MOV DX , Speed
    MOV CurrentSpeed , DX

ENDM

.CODE

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    PROC    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CalculateBoxVertex PROC FAR
                       MOV   DI , 0
                       MOV   AX , CarToDrawY
                       MOV   BX , SCREEN_WIDTH
                       MUL   BX
                       ADD   AX , CarToDrawX
                       MOV   DI , AX
                       RET
CalculateBoxVertex ENDP

;Moves the background of the car to be drawn in BX
CheckCarToDraw PROC FAR
                MOV DX , OFFSET CarImg1
                CMP CarToDraw , DX
                JNE Car2Draw
                MOV BX ,OFFSET BackgroundBuffer1
                RET
Car2Draw:
                MOV BX ,OFFSET BackgroundBuffer2
                RET
CheckCarToDraw ENDP

DrawCar PROC FAR
                MOV  ax , 0A000H
                MOV  es , ax
                MOV  DI , 0
                MOV  cx , CarToDrawSize
                MOV  SI ,  CarToDraw
                MOV  DL , 0
                CALL CalculateBoxVertex
                
                CALL CheckCarToDraw               ;Get Background offset in BX

ROWS_DRAW:        
                PUSH CX
                PUSH DI

                MOV  CX , CarToDrawSize
COLS_DRAW:         
                MOV  DH , BYTE PTR ES:[DI]          ;Moving the byte of the road to DH to be stored in buffer
                MOV  BYTE PTR DS:[BX] , DH          ;Moving DH -> the memory with offset BX
                MOV  DL , BYTE PTR [SI]             ;Car byte to be drawn this iteration
                MOV  BYTE PTR ES:[DI] , DL          ;Drawing the car bit
;Updates                
                INC  SI
                INC  DI
                INC  BX
                LOOP COLS_DRAW

                POP  DI
                POP  CX
                ADD  DI, SCREEN_WIDTH
                LOOP ROWS_DRAW
                RET
DrawCar ENDP



;clear the car's image from the screen
ClearCarArea PROC FAR
                       MOV   ax , 0A000H
                       MOV   es , ax
                       MOV   cx , CarToDrawSize
                       CALL  CalculateBoxVertex

                      CALL CheckCarToDraw               ;Get Background offset in BX

    ROWS_CLEAR:        
                       PUSH  CX
                       PUSH  DI
                       MOV   CX , CarToDrawSize
    COLS_CLEAR:        
                       MOV   DL, BYTE PTR DS:[BX]        ;Moving road byte in dl
                       MOV   BYTE PTR ES:[DI] , DL      ;Moving the road byte to be printed
                       INC   DI
                       INC   BX
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
                       JNE   CarCheckLeft
                       MOV   UpFlag , 0
                       JMP   Default
    CarCheckLeft:         
    ; left arrow
                       CMP   AL, LeftKeyCode
                       JNE   NotPressed2
                       MOV   LeftFlag , 1
                       JMP   Default
    NotPressed2:       
                       MOV   BL , LeftKeyCode
                       ADD   BL, 80H
                       CMP   AL , BL
                       JNE   CarCheckDown
                       MOV   LeftFlag , 0
                       JMP   Default

    CarCheckDown:         
    ; down arrow
                       cmp   AL, DownKeyCode
                       JNE   NotPressed3
                       MOV   DownFlag , 1
                       JMP   Default
    NotPressed3:       
                       MOV   BL , DownKeyCode
                       ADD   BL, 80H
                       CMP   AL , BL
                       JNE   CarCheckRight
                       MOV   DownFlag , 0
                       JMP   Default
    
    CarCheckRight:        
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
    
CheckArrowFlags PROC FAR

    ;------- checking Flags -------
	
                          CMP      ArrowUpFlag , 1
                          JNE      CmpLeft
                          
                          ScanY PosXfirst, PosYfirst , 1 , 1, Car1Speed
                          CALL ScanYmovement
                          CALL UpdateCarPos
                          INC PosYfirst  
    CmpLeft:              
                          CMP      ArrowLeftFlag , 1
                          JNE      CmpDown
                        
                          ScanX PosXfirst, PosYfirst , 1 , 0, Car1Speed
                          CALL ScanXmovement
                          CALL UpdateCarPos
                          INC PosXfirst

    CmpDown:              
                          CMP      ArrowDownFlag , 1
                          JNE      CmpRight
                        
                          ScanY PosXfirst, PosYfirst , 1 , 0, Car1Speed
                          CALL ScanYmovement
                          CALL UpdateCarPos
                          DEC PosYfirst  

    CmpRight:             
                          CMP      ArrowRightFlag, 1
                          JNE      CmpFinish
                         
                          ScanX PosXfirst, PosYfirst , 1 ,1, Car1Speed
                          CALL ScanXmovement
                          CALL UpdateCarPos
                          DEC PosXfirst
    CmpFinish:            
                         RET
CheckArrowFlags ENDP

CheckWASDFlags PROC FAR

    ;------- checking Flags -------
	
                CMP      WFlag , 1
                JNE      CmpLeft2

                ScanY PosXsecond, PosYsecond , 0 , 1, Car2Speed
                CALL ScanYmovement
                CALL UpdateCarPos
                INC PosYsecond  

    CmpLeft2:              
                CMP      AFlag , 1
                JNE      CmpDown2

                ScanX PosXsecond, PosYsecond , 0 , 0, Car2Speed
                CALL ScanXmovement
                CALL UpdateCarPos
                INC PosXsecond

    CmpDown2:              
                CMP      SFlag , 1
                JNE      CmpRight2

                ScanY PosXsecond, PosYsecond , 0 , 0, Car2Speed
                CALL ScanYmovement
                CALL UpdateCarPos
                DEC PosYsecond 

    CmpRight2:             
                CMP      DFlag, 1
                JNE      CmpFinish2

                ScanX PosXsecond, PosYsecond , 0 ,1, Car2Speed
                CALL ScanXmovement
                CALL UpdateCarPos
                DEC PosXsecond

    CmpFinish2:            
                RET
                
CheckWASDFlags ENDP


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
UpdateWASDFlags PROC FAR
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
CheckArrowKeys PROC FAR
                SETKEYS ArrowUp, ArrowDown, ArrowLeft, ArrowRight
                SetFlags ArrowUpFlag, ArrowDownFlag, ArrowLeftFlag, ArrowRightFlag
                CALL InputButtonSwitchCase
                CALL UpdateArrowFlags
                RET
CheckArrowKeys ENDP

;procedure calls all WASD keys functions
CheckWASDKeys PROC FAR
                SETKEYS WKey, SKey, AKey, DKey
                SetFlags WFlag, SFlag, AFlag, DFlag
                CALL InputButtonSwitchCase
                CALL UpdateWASDFlags
                RET
CheckWASDKeys ENDP

Update1 PROC FAR
                CLEAR CarImg1, CAR_SIZE, PrevPosXfirst, PrevPosYfirst
                DRAW  CarImg1, CAR_SIZE, Posxfirst , PosYfirst
    CannotDraw:                
                RET
Update1 ENDP


Update2 PROC FAR
                CLEAR CarImg2, CAR_SIZE, PrevPosXsecond, PrevPosYsecond
                DRAW CarImg2, CAR_SIZE, PosXsecond , PosYsecond
                RET
Update2 ENDP

;Before Calling, Set the carToScan with the car you want to scan
UpdateCarPos PROC FAR
    ;Checking that the car that it is scanning      
                CMP CarToScan , 0                   
                JE Car2
    ;Changing car1 position to the previous position  
                MOV DX , CarToDrawY    
                MOV PosYfirst , DX

                MOV DX , CarToDrawX    
                MOV PosXfirst , DX
                RET
                
    ;Changing car2 position to the previous position            
    Car2:       
                MOV DX , CarToDrawY
                MOV PosYsecond , DX

                MOV DX , CarToDrawX
                MOV PosXsecond , DX
    ;No matching found, continue looping
                RET
UpdateCarPos ENDP

;description
ScanYmovement PROC FAR
    
                MOV AX , 0A000H
                MOV ES , AX
                
                MOV DI , 0

;Assume no addition or subtraction has occured to the positions in "checkFlags"   

                 CMP YMovement , 1              ; The car is moving up either car1 or car2
                 JE UpMovement

                 ADD CarToDrawY , CAR_SIZE
                 CALL CalculateBoxVertex
                 SUB CarToDrawY , CAR_SIZE-1

                 JMP StartScanning
     UpMovement:
                 DEC CarToDrawY 
                 CALL CalculateBoxVertex
     StartScanning:
                MOV CX , CurrentSpeed             ;# of rows to be checked

;Outer Loop Starts
    NextRow:  
                PUSH CX
                PUSH DI
                MOV CX , CAR_SIZE
;Inner loop starts
    CheckY:
                CMP BYTE PTR ES:[DI] , 142
                JNE NoObstacleDetected
                
                POP DI
                POP CX
                RET
    NoObstacleDetected:
                INC DI
                LOOP checkY
    
                POP DI
                POP CX
 ;Incrementing DI & Y position of the car after each row is scanned             

                CMP YMovement , 1
                JE UpMovement2
                ADD DI , SCREEN_WIDTH
                INC CarToDrawY
                JMP NextLoop
    UpMovement2:
                SUB DI , SCREEN_WIDTH
                DEC CarToDrawY
    NextLoop:
                LOOP NextRow

    checkYFinish:
                RET
ScanYmovement ENDP

ScanXmovement PROC FAR
                MOV AX , 0A000H
                MOV ES, AX

                MOV DI , 0

                CMP XMovement , 1   ; The car is moving right either car1 or car2
                JNE LeftMovement
    ;Moving right         
                ADD CarToDrawX , CAR_SIZE
                CALL CalculateBoxVertex
                SUB CarToDrawX , CAR_SIZE-1
                JMP StartScanning2
    ;Moving left
    LeftMovement:
                    DEC CarToDrawX
                    CALL CalculateBoxVertex
    StartScanning2:
                    MOV CX , CurrentSpeed
    
    NextRow2:
                    PUSH CX
                    PUSH DI
                    MOV CX, CAR_SIZE

    CheckX:
                    CMP BYTE PTR ES:[DI] , 142
                    JNE NoObstacleDetected2

                    POP DI
                    POP cx
                    RET  
    NoObstacleDetected2:
                    ADD DI , SCREEN_WIDTH
                    LOOP checkX

                    POP DI
                    POP cx

                    CMP XMovement , 1
                    JNE LeftMovement2

                    INC DI
                    INC CarToDrawX
                    JMP NextLoop2
    LeftMovement2:
                    DEC DI
                    DEC CarToDrawX

    NextLoop2:
                    LOOP NextRow2
    checkXFinish:
                            RET
ScanXmovement ENDP

;description
checkingPositionChange1 PROC FAR
             
                MOV DX , PosXfirst
                CMP PrevPosXfirst, DX

                JE bridge1
                CALL Update1
                JMP Car2Check
    bridge1:
                MOV DX , PosYfirst
                CMP PrevPosYfirst , DX
                JE Car2Check
                CALL Update1
    Car2Check:  
                RET
checkingPositionChange1 ENDP

;description
checkingPositionChange2 PROC FAR
                MOV DX , PosXsecond
                CMP PrevPosXsecond, DX
                JE bridge2
                CALL Update2
                JMP ContinueLooping
    bridge2:
                MOV DX , PosYsecond
                CMP PrevPosYsecond , DX
                JE ContinueLooping
                CALL Update2

    ContinueLooping:
                RET
checkingPositionChange2 ENDP

INT09H PROC FAR
                IN     AL, 60H
                            
                CALL CheckArrowKeys
                CALL CheckWASDKeys

                                    
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
                MOV  PosXfirst , STARTROADX
                MOV  PosYfirst , STARTROADY + 1
                DRAW CarImg1, CAR_SIZE, PosXfirst , PosYfirst

                ; set initial pos of second car in the game
                MOV  PosXsecond , STARTROADX 
                MOV  PosYsecond , STARTROADY + HORROADIMGH - Car_Size - 1
                DRAW CarImg2, CAR_SIZE, PosXsecond , PosYsecond


                MOV DX , PosXfirst
                MOV PosX, DX

                MOV DX , PosYfirst
                MOV PosY, DX
     mainLoop:          

                MOV DX , PosXfirst
                MOV PrevPosXfirst, DX

                MOV DX, PosYfirst
                MOV PrevPosYfirst, DX

                MOV DX , PosXsecond
                MOV PrevPosXsecond, DX

                MOV DX , PosYsecond
                MOV PrevPosYsecond ,DX


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
            
                
                CALL CheckArrowFlags
                CALL checkingPositionChange1 

                CALL CheckWASDFlags
                CALL checkingPositionChange2               
 
    ;Delay  
                MOV CX , 0
                MOV DX , 30997D
                MOV AH , 86H
                INT 15H

                JMP  mainLoop                             ; keep looping
    exit:              
                HLT
                
MAIN ENDP
END MAIN