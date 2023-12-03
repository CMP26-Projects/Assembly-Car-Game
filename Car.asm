
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


        ;CarTodraw  info
        CarToDrawSize           DW   ?
        CarToDraw               DW   ?
        CarToDrawX              DW   ?
        CarToDrawY              DW   ?

        ; Screen Info
        SCREEN_WIDTH            EQU  320
        SCREEN_HEIGHT           EQU  200
        SCREEN_SIZE             EQU  SCREEN_WIDTH*SCREEN_HEIGHT


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

                ; set initial pos of first car in the game
                MOV  PosXfirst , (SCREEN_WIDTH-CAR_SIZE)/2
                MOV  PosYfirst , (SCREEN_HEIGHT-CAR_SIZE)/2
                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst

                ; set initial pos of second car in the game
                MOV  PosXsecond , (SCREEN_WIDTH-CAR_SIZE)/3
                MOV  PosYsecond , (SCREEN_HEIGHT-CAR_SIZE)/3
                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond


                ; Start the game for both drawn cars
mainLoop:        

                ; The idea of moving just one has to be revised with Sami , I've tried to control movement for such one car
                mov  DI,0H
                mov  ah, 01h
                int  16h  
                jz keys                                         ; Don't wait for key press to select such car - store key in ah register
                
                ; Take the key for detecting which car has to move

                cmp  ah, 21h                                     ; Character "F" states for first car (Needed to be revised with Sami)
                je car1

                cmp  ah, 20h                                     ; Character "D" states for second car (Needed to be revised with Sami)
                je car2

                jmp exit                                         ; If the key is neither "F" and "A" then exit the game

car1:
                MOV  BX, OFFSET CarImg1
                jmp keys

car2:
                MOV  BX, OFFSET CarImg2
                jmp keys

keys:                                                            ; Wait for pressing a key for detecting which direction the car has to move
                mov  DI,0H
                mov  ah, 00h
                int  16h 

                cmp  ah, 48h                                     ; up arrow
                je   MoveUpBridge     

                cmp  ah, 50h                                     ; down arrow
                je   MoveDownBridge   

                cmp  ah, 4bh                                    ; left arrow
                je   MoveLeftBridge   

                cmp  ah, 4dh                                    ; right arrow
                je   MoveRightBridge  

                cmp  ah, 01h                                    ; escape
                jne  ContinueBridge     
                jmp  exit       

MoveUpBridge:
                jmp MoveUp
MoveDownBridge:
                jmp MoveDown
MoveLeftBridge:
                jmp MoveLeft
MoveRightBridge:
                jmp MoveRight               
ContinueBridge:                 
                jmp  mainLoop                                   ; keep looping

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveUp:                 
                LEA SI, CarImg1
                CMP BX, [SI]
                je MoveUpFirst                                  ; if the car is the first one then move it up 
                                                                ;N.B - > The terminology of these intermediated lebals is (First/Second + To + Direction)

                CLEAR CAR_SIZE, PosXsecond , PosYsecond
                SUB  PosYsecond , 10
                CMP PosYsecond , 0                              ; Check if the car is in the top of the screen
                JL SecondToUp

                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond ; Draw the car in the new position
                JMP ContinueBridge
SecondToUp:
                ADD PosYsecond,10
                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond ; Draw the car in the old position
                jmp  ContinueBridge

MoveUpFirst:
                CLEAR CAR_SIZE, PosXfirst , PosYfirst
                SUB  PosYfirst , 10
                CMP  PosYfirst , 0                             ; Check if the car is in the top of the screen
                JL FirstToUp

                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst  ; Draw the car in the new position
                jmp  ContinueBridge
FirstToUp:
                ADD PosYfirst,10
                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst ; Draw the car in the old position
                jmp  ContinueBridge

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveDown:         
                LEA SI, CarImg1
                CMP BX, [SI]
                je MoveDownFirst

                CLEAR CAR_SIZE, PosXsecond , PosYsecond
                ADD  PosYsecond , 10

                CMP  PosYsecond , SCREEN_HEIGHT-CAR_SIZE                ; Check if the car is in the bottom of the screen
                JG SecondToDown

                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond         ; Draw the car in the new position
                JMP ContinueBridge
SecondToDown:
                SUB PosYsecond,10
                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond        ; Draw the car in the old position
                jmp  ContinueBridge

moveDownFirst:
                CLEAR CAR_SIZE, PosXfirst , PosYfirst
                ADD  PosYfirst , 10                                             
                CMP PosYfirst , SCREEN_HEIGHT-CAR_SIZE                 ; Check if the car is in the bottom of the screen
                JG FirstToDown

                Draw CarImg1, CAR_SIZE, PosXsecond , PosYsecond
                jmp  ContinueBridge
FirstToDown:
                SUB PosYfirst,10
                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst         ; Draw the car in the old position
                jmp  ContinueBridge
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveLeft:            
                LEA SI, CarImg1
                CMP BX, [SI]
                je MoveLeftFirst
                CLEAR CAR_SIZE, PosXsecond , PosYsecond
                SUB  PosXsecond , 10
                CMP PosXsecond , 0                                     ; Check if the car is in the left of the screen
                JL SecondToLeft

                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond        ; Draw the car in the new position
                jmp  ContinueBridge
SecondToLeft:
                ADD PosXsecond,10
                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond       ; Draw the car in the old position
                jmp  ContinueBridge

moveLeftFirst:
                CLEAR CAR_SIZE, PosXfirst , PosYfirst
                SUB  PosXfirst , 10
                CMP PosXfirst , 0                                       ; Check if the car is in the left of the screen
                JL FirstToLeft

                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst           ; Draw the car in the new position
                JMP ContinueBridge
FirstToLeft:
                ADD PosXfirst,10
                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst           ; Draw the car in the old position
                jmp  ContinueBridge

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveRight:        
                LEA SI, CarImg1
                CMP BX, [SI]
                je MoveRightFirst
                CLEAR CAR_SIZE, PosXsecond , PosYsecond
                ADD  PosXsecond , 10
                CMP PosXsecond , SCREEN_WIDTH-CAR_SIZE                  ; Check if the car is in the right of the screen
                JG SecondToRight

                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond         ; Draw the car in the new position
                JMP ContinueBridge
SecondToRight:
                SUB PosXsecond,10
                Draw CarImg2, CAR_SIZE, PosXsecond , PosYsecond         ; Draw the car in the old position
                jmp  ContinueBridge

moveRightFirst:
                CLEAR CAR_SIZE, PosXfirst , PosYfirst
                ADD  PosXfirst , 10
                CMP PosXfirst , SCREEN_WIDTH-CAR_SIZE                   ; Check if the car is in the right of the screen
                JG FirstToRight

                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst           ; Draw the car in the new position
                JMP ContinueBridge
FirstToRight:
                SUB PosXfirst,10
                Draw CarImg1, CAR_SIZE, PosXfirst , PosYfirst           ; Draw the car in the old position
                jmp  ContinueBridge

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
exit:             
                HLT   
MAIN ENDP
END MAIN