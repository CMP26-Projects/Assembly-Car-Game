;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; MACROS ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawPower MACRO powerX , powerY , PType
            ; DRAW MACRO IMG, WID, HEI, STARX, STARY, ISROAD
            LOCAL DECSPEED , SETOBSTACLE , PASSOBSTACLE , FINISH_DRAWING_POWER

            MOV AH , PType

            CMP AH,1       ;Increase Speed Powerup
            JNE DECSPEED
            DRAW INCSPEEDPOWER, POWERW, POWERH, powerX, powerY, TMP4
            JMP FINISH_DRAWING_POWER
            ; MOV AX ,OFFSET INCSPEEDPOWER
            ; MOV powerupToDraw , AX

            ; CALL DrawPowerup

        
DECSPEED:
            CMP AH,2       ;Decrease Speed Powerup   
            JNE SETOBSTACLE
            DRAW DECSPEEDPOWER, POWERW, POWERH, powerX, powerY, TMP4
            JMP FINISH_DRAWING_POWER
            ; MOV AX , OFFSET DECSPEEDPOWER
            ; MOV powerupToDraw , AX
            
            ; CALL DrawPowerup
            ; JMP FINISH_DRAWING_POWER

SETOBSTACLE:
            CMP AH,3       ;Create Obstacle Powerup
            JNE PASSOBSTACLE
            DRAW CREATEOBSTPOWER, POWERW, POWERH, powerX, powerY, TMP4
            JMP FINISH_DRAWING_POWER
            ; MOV AX , OFFSET CREATEOBSTPOWER
            ; MOV powerupToDraw , AX

            ; CALL DrawPowerup
            ; JMP FINISH_Drawing_POWER

PASSOBSTACLE:
            CMP AH,4       ;Pass Obstacle Powerup
            JNE FINISHPOWER
            DRAW PASSOBSTPOWER , POWERW, POWERH, powerX, powerY, TMP4
            ; MOV AX , OFFSET PASSOBSTPOWER
            ; MOV powerupToDraw , AX

            ; CALL DrawPowerup

FINISH_DRAWING_POWER:
 ENDM

Draw_Car MACRO Img, CarSize, StartPosX, StartPosY
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

ClearPower MACRO 
            LOCAL CLEAR_SECOND_POWERUP, Delete_Powerup
            CMP powerupParent , 1
            JNE CLEAR_SECOND_POWERUP
            MOV AX , powerup1Posx
            MOV TEMPX,AX
            MOV AX , powerup1Posy
            MOV TEMPY,AX
            JMP Delete_Powerup

CLEAR_SECOND_POWERUP:
            MOV AX , powerup2Posx
            MOV TEMPX,AX
            MOV AX , powerup2Posy
            MOV TEMPY,AX


Delete_Powerup:            
            CALL ClearPowerup

ENDM

SETKEYS MACRO Up, Down , Left, Right , DeletePower1 , DeletePower2

                               MOV   DL , Up
                               MOV   UpKeyCode , DL

                               MOV   DL , Down
                               MOV   DownKeyCode , DL

                               MOV   DL , Left
                               MOV   LeftKeyCode , DL

                               MOV   DL , Right
                               MOV   RightKeyCode , DL

                               MOV DL , DeletePower1
                               MOV DeletePower1Key , DL

                               MOV DL , DeletePower2
                               MOV DeletePower2Key , DL


                              ; CALL InputButtonSwitchCase
ENDM

    ;Setting Flags to be checked while movement
SetFlags MACRO f1 , f2 , f3 , f4 , f5 , f6 

                                MOV   DL , f1
                                MOV   UpFlag , DL

                                MOV   DL , f2
                                MOV   DownFlag , DL

                                MOV   DL , f3
                                MOV   LeftFlag , DL

                                MOV   DL , f4
                                MOV   RightFlag , DL

                                MOV  DL , f5
                                MOV  KFlag , DL

                                MOV  DL , f6
                                MOV  MFlag , DL


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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; road MACROS ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MACRO TO DRAW AN IMAGE GIVEN THESE PARAMS

DRAW MACRO IMG, WID, HEI, STARX, STARY, ISROAD
LOCAL FINISHDRAW
MOV AX, OFFSET IMG
MOV IMGTODRAW, AX
MOV AX, WID
MOV WIDTODRAW, AX
MOV AX, HEI
MOV HEITODRAW, AX
MOV AX, STARX
MOV STARXTODRAW, AX
MOV AX, STARY
MOV STARYTODRAW, AX
CALL DRAWIMAGE
CMP ISROAD, 1
JNE FINISHDRAW
MOV LASTDI, DI
FINISHDRAW:
ENDM

;THIS MACRO CHECKS ONLY THE BYTES AT THE WIDTH AND HEIGHT FOR SIMPLICITY AND FAST RUN
; CHECKCANDRAW MACRO WID, HEI, STARX, STARY, DIRECTION
;     LOCAL HOR, VER, FINISH, HANDLECANTDRAW, CONTINUEUP, CONTINUERIGHT, CONTINUEDOWN, CONTINUELEFT
;     ;VIDEO MEMORY
;     MOV AX, 0A000H
;     MOV ES, AX

;     MOV DI, STARY
;     MOV AX, SCREENWIDTH
;     MUL DI
;     MOV DI, AX
;     ADD DI, STARX
    
;     MOV AX, WID
;     PUSH DI
;     MOV INCOUNTER, AX
;     HOR:
;         CMP BYTE PTR ES:[DI], 20
;         JE HANDLECANTDRAW
;         CMP BYTE PTR ES:[DI], 31
;         JE HANDLECANTDRAW
;         INC DI
;         DEC INCOUNTER
;     JNZ HOR
;     POP DI

;     MOV AX, HEI
;     MOV OUTCOUNTER, AX
;     VER:
;         CMP BYTE PTR ES:[DI], 20
;         JE HANDLECANTDRAW
;         CMP BYTE PTR ES:[DI], 31
;         JE HANDLECANTDRAW
;         ADD DI, SCREENWIDTH
;         DEC OUTCOUNTER
;     JNZ VER
;     JMP FINISH

;     HANDLECANTDRAW:
;     CMP DIRECTION, 0
;     JNE CONTINUEUP
;     MOV CANTUP, 1
;     CONTINUEUP:
    
;     CMP DIRECTION, 1
;     JNE CONTINUERIGHT
;     MOV CANTRIGHT, 1
;     CONTINUERIGHT:
    
;     CMP DIRECTION, 2
;     JNE CONTINUEDOWN
;     MOV CANTDOWN, 1
;     CONTINUEDOWN:

;     CMP DIRECTION, 3
;     JNE CONTINUELEFT
;     MOV CANTLEFT, 1
;     CONTINUELEFT:

;     JMP RANDOMIZEPART
;     FINISH:
; ENDM






;THIS MACRO CHECKS THE WHOLE AREA TO BE DRAWN

CHECKCANDRAW MACRO WID, HEI, STARX, STARY, DIRECTION
    LOCAL ROWS, COLS, FINISH, HANDLECANTDRAW, CONTINUEUP, CONTINUERIGHT, CONTINUEDOWN, CONTINUELEFT
    ;VIDEO MEMORY
    MOV AX, 0A000H
    MOV ES, AX 
    MOV DI, STARY
    MOV AX, SCREENWIDTH
    MUL DI
    MOV DI, AX
    ADD DI, STARX
    MOV AX, HEI
    MOV OUTCOUNTER, AX

    ROWS:
        MOV FIRSTBYTEINROW, DI
        MOV AX, WID
        MOV INCOUNTER, AX
        COLS:
            CMP BYTE PTR ES:[DI], 20
            JE HANDLECANTDRAW
            CMP BYTE PTR ES:[DI], 31
            JE HANDLECANTDRAW
            INC DI
            DEC INCOUNTER
        JNZ COLS
        MOV DI, FIRSTBYTEINROW
        ADD DI, SCREENWIDTH
    DEC OUTCOUNTER
    JNZ ROWS
    JMP FINISH

    HANDLECANTDRAW:
    CMP DIRECTION, 0
    JNE CONTINUEUP
    MOV CANTUP, 1
    CONTINUEUP:
    
    CMP DIRECTION, 1
    JNE CONTINUERIGHT
    MOV CANTRIGHT, 1
    CONTINUERIGHT:
    
    CMP DIRECTION, 2
    JNE CONTINUEDOWN
    MOV CANTDOWN, 1
    CONTINUEDOWN:

    CMP DIRECTION, 3
    JNE CONTINUELEFT
    MOV CANTLEFT, 1
    CONTINUELEFT:

    JMP RANDOMIZEPART
    FINISH:
ENDM




;MACRO TO CHECK POWERUP AREA
CHECKCANDRAWPOWER MACRO WID, HEI, STARX, STARY
    LOCAL ROWS, COLS, FINISH, HANDLECANTDRAW, CONTINUEUP, CONTINUERIGHT, CONTINUEDOWN, CONTINUELEFT
    ;VIDEO MEMORY
    MOV AX, 0A000H
    MOV ES, AX 
    MOV DI, STARY
    MOV AX, SCREENWIDTH
    MUL DI
    MOV DI, AX
    ADD DI, STARX
    MOV AX, HEI
    MOV OUTCOUNTER, AX

    ROWS:
        MOV FIRSTBYTEINROW, DI
        MOV AX, WID
        MOV INCOUNTER, AX
        COLS:
            CMP BYTE PTR ES:[DI], 16
            JE HANDLECANTDRAW
            INC DI
            DEC INCOUNTER
        JNZ COLS
        MOV DI, FIRSTBYTEINROW
        ADD DI, SCREENWIDTH
    DEC OUTCOUNTER
    JNZ ROWS
    JMP FINISH

    HANDLECANTDRAW:
    

    JMP FINISHPOWER
    FINISH:
ENDM





CHECKPOSSIBILITIES MACRO
    CMP CANTUP, 0
    JE START
    CMP CANTRIGHT, 0
    JE START
    CMP CANTDOWN, 0
    JE START
    CMP CANTLEFT, 0
    JE START
    JMP LAST
ENDM


.MODEL COMPACT
.STACK 64
.DATA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;   car data   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;CarImage
        CarImg1                 DB   142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142
        CarImg2                 DB   142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142
        Car1Speed               DW   2
        Car2Speed               DW   2
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
    KFlag          DB   ?
    MFlag          DB   ?

    ;Arrow flags to check whether this key is pressed down or not
    ArrowUpFlag    DB   0
    ArrowDownFlag  DB   0
    ArrowLeftFlag  DB   0
    ArrowRightFlag DB   0
    LetterKFlag    DB   0
    LetterMFlag    DB   0
   
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
    LetterK        DB   25h
    LetterM        DB   32H

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
    DeletePower1Key DB  ?
    DeletePower2Key DB  ?

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

    ;Data for the status bar (First Player's data)
    player1PosX     EQU  0
    player1PosY     EQU  22
    player1Name     DB  'Abd El-Rahman', '$'
   

    ;Data for the status bar (Second Player's data)
    player2PosX     DB  65
    player2PosY     DB  22
    player2Name     DB  'Ahmed', '$'


    ; Data for the powerups
    powerupMessage      DB  'Powerup :', '$'

    powerup1Posx        EQU  71
    powerup1Posy        EQU  187

    powerup2Posx        EQU  271
    powerup2Posy        EQU  187

    powerupToDraw       DW   ?
    powerupToDrawPosX   DW   ?
    powerupToDrawPosY   DW   ?

    powerupParent       DB   ?
    powerupType         DB   ?

    catchedIndex        DW   ?

    verticalFlag        DB   ?
    horizontalFlag      DB   ?



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;   road data   ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;BACKGROUND
BACKGROUNDIMAGEPARTH    EQU     16
BACKGROUNDIMAGEPARTW    EQU     16
BACKGROUNDIMAGEPART     DB      142, 203, 142, 142, 71, 142, 203, 142, 143, 203, 142, 142, 142, 71, 142, 142, 71, 142, 203, 142, 71, 142, 203, 142, 142, 142, 142, 142, 142, 142, 142, 142, 142, 142, 203, 142, 142, 142, 142, 142
 DB 71, 142, 142, 142, 203, 142, 142, 71, 142, 142, 142, 142, 143, 142, 142, 142, 142, 71, 142, 203, 142, 142, 143, 71, 142, 143, 142, 142, 142, 142, 142, 142, 142, 71, 142, 203, 142, 142, 142, 71
 DB 142, 142, 142, 71, 142, 142, 142, 142, 142, 142, 142, 142, 142, 203, 142, 142, 142, 142, 142, 142, 71, 142, 203, 142, 142, 143, 142, 142, 142, 203, 142, 142, 142, 203, 142, 142, 71, 142, 142, 203
 DB 142, 142, 142, 142, 142, 142, 142, 203, 142, 142, 203, 142, 71, 142, 142, 203, 142, 142, 142, 71, 142, 142, 203, 142, 142, 142, 203, 142, 142, 142, 142, 142, 142, 142, 71, 142, 142, 203, 142, 143
 DB 142, 142, 142, 142, 142, 142, 142, 142, 142, 142, 71, 142, 142, 203, 142, 142, 143, 142, 142, 142, 203, 142, 142, 71, 142, 142, 142, 142, 142, 142, 142, 142, 71, 142, 142, 203, 142, 142, 71, 142
 DB 143, 142, 142, 142, 143, 142, 142, 142, 142, 71, 142, 203, 142, 142, 71, 142, 142, 142, 203, 142, 142, 142, 71, 142, 142, 71, 142, 142, 142, 142, 71, 142, 142, 203, 142, 142, 142, 71, 142, 142
 DB 142, 143, 142, 71, 142, 203, 142, 142, 142, 203, 142, 143, 142, 71, 142, 142
SCREENWIDTH             EQU     320
SCREENHEIGHT            EQU     200
SCREENSIZE              EQU     32*32


;OBSTACLE
THRESHOLD               EQU     10
OBSTACLEW               EQU     5
OBSTACLEH               EQU     5
OBSTACLE                DB      16, 16, 16, 16, 16, 16, 28, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
XOBSTACLE               DW      ?
YOBSTACLE               DW      ?

;POWERUPS
POWERW                  EQU     3
POWERH                  EQU     3
CREATEOBSTPOWER         DB      36, 36, 36, 36, 17, 36, 36, 36, 36
PASSOBSTPOWER           DB      36, 36, 36, 36, 28, 36, 36, 36, 36
DECSPEEDPOWER           DB      36, 36, 36, 112, 112, 112, 36, 36, 36
INCSPEEDPOWER           DB      36, 121, 36, 121, 121, 121, 36, 121, 36

;STORING ROAD UNDER POWERUPS TO DRAW IT AGAIN WHEN IT'S COLLECTED
TOPLEFTPOWER            DW      45 DUP(?)  
ROADUNDERPOWER          DB      405 DUP(?)
ISVISIBLEPOWER          DB      45 DUP(?)
; TOPLEFTPOWER            DW      45 DUP(?)  
; ROADUNDERPOWER          DB      40 DUP(2)
POWERUPCOUNTER          DW      0
CURPOWERINDEX           DW      0
POWERTOPLEFTBYTE        DW      ?
INDEXSTARTSHOWING       DW      5  ; INDEX TO START SHOWING THE HIDDEN POWER FROM

;PROBABILITY OF DRAWING A POWERUP OR AN OBSTACLE %
POWERPROBABILITY        DB      30
OBSTPROBABILITY         DB      70
POWERVISIBPROBABILITY   DB      60


;CAR
CARIMGW                 EQU     6
CARIMGH                 EQU     6
CARIMG                  DB      142, 142, 0, 0, 142, 142, 142, 46, 46, 46, 46, 142, 0, 46, 16, 112, 46, 0, 0, 46, 112, 16, 46, 0, 142, 46, 46, 46, 46, 142, 142, 142, 0, 0, 142, 142

;START FLAG
STARTFLAGIMGW           EQU     4
STARTFLAGIMGH           EQU     20
STARTFLAGIMG            DB      16, 16, 29, 29, 16, 16, 29, 29, 29, 29, 16, 16, 29, 29, 16, 16, 16, 16, 29, 29, 16, 16, 29, 29, 29, 29, 16, 16, 29, 29, 16, 16, 16, 16, 29, 29, 16, 16, 29, 29
 DB 29, 29, 16, 16, 29, 29, 16, 16, 16, 16, 29, 29, 16, 16, 29, 29, 29, 29, 16, 16, 29, 29, 16, 16, 16, 16, 29, 29, 16, 16, 29, 29, 29, 29, 16, 16, 29, 29, 16, 16

;END FLAG
HORENDFLAGIMGW          EQU     20
HORENDFLAGIMGH          EQU     6
HORENDFLAGIMG           DB      31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40
 DB 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31
 DB 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31, 40, 40, 31, 31
VERENDFLAGIMGW          EQU     6
VERENDFLAGIMGH          EQU     20
VERENDFLAGIMG           DB      40, 40, 40, 31, 31, 31, 40, 40, 40, 31, 31, 31, 31, 31, 31, 40, 40, 40, 31, 31, 31, 40, 40, 40, 40, 40, 40, 31, 31, 31, 40, 40, 40, 31, 31, 31, 31, 31, 31, 40 
 DB 40, 40, 31, 31, 31, 40, 40, 40, 40, 40, 40, 31, 31, 31, 40, 40, 40, 31, 31, 31, 31, 31, 31, 40, 40, 40, 31, 31, 31, 40, 40, 40, 40, 40, 40, 31, 31, 31, 40, 40 
 DB 40, 31, 31, 31, 31, 31, 31, 40, 40, 40, 31, 31, 31, 40, 40, 40, 40, 40, 40, 31, 31, 31, 40, 40, 40, 31, 31, 31, 31, 31, 31, 40, 40, 40, 31, 31, 31, 40, 40, 40

;TEMPORARY X AND Y
TEMPX                   DW      ?
TEMPY                   DW      ?

;WE SAVE LAST DIRECTION TO PRINT THE END RACE LINE 
LASTDIR                 DW      ?
LASTDI                  DW      ?

;TEMPORARY VARIABLE
TMP                     DW      ?
TMP1                    DW      ?
TMP2                    DW      ?
TMP3                    DW      ?
TMP4                    DW      ?
TMP5                    DW      ?
TMP6                    DW      ?

;INFINITELOOP RANDOMIZATIONS STORAGE
CANTUP                  DW      0
CANTRIGHT               DW      0
CANTDOWN                DW      0
CANTLEFT                DW      0

;COUNTERS FOR CHECKDRAW
OUTCOUNTER              DW      ?
INCOUNTER               DW      ?
FIRSTBYTEINROW          DW      ?

;RANGEOFRAND
RANGEOFRAND             DB      ?

;STARTdd
STARTROADX              EQU     2
STARTROADY              EQU     2
NUMBEROFPARTS           EQU     5
MINNUMOFPARTS           EQU     5

;VARIABLES FOR DRAWIMAGE PROCEDURE
IMGTODRAW               DW      ?
WIDTODRAW               DW      ?
HEITODRAW               DW      ?
STARXTODRAW             DW      ?
STARYTODRAW             DW      ?

;CONSTRAINTS          ;;;; 10 GAB IS LET
XNOLEFT                 EQU     22
XNORIGHT                EQU     268
YNOUP                   EQU     22
YNODOWN                 EQU     124

;DIRECTIONS
UPDIR                   DW      ?
RIGHTDIR                DW      ?
DOWNDIR                 DW      ?
LEFTDIR                 DW      ?

;ROAD IMAGES
VERROADIMGW             EQU     20
VERROADIMGH             EQU     30
VERROADIMG              DB      20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
HORROADIMGW             EQU     30
HORROADIMGH             EQU     20
HORROADIMG              DB      20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 31
 DB 31, 20, 20, 31, 31, 31, 31, 20, 20, 31, 31, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 31, 31, 20, 20, 31, 31, 31, 31, 20, 20, 31
 DB 31, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
.CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;     car procedures      ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SearchForLeftVertex PROC FAR 
                        
; ROWS_POWER:         
;                     CMP BYTE PTR DS:[BX], 121       ; 121 is the color degree for the increasing speed powerup
;                     JE THE_END
;                     CMP BYTE PTR ES:[BX] , 20       ; 20 is the GREY color degree of the road
;                     JE PREWORKOUT
;                     CMP BYTE PTR ES:[BX] , 31       ; 31 is the WHITE color degree of the road
;                     JE PREWORKOUT
;                     CMP BYTE PTR ES:[BX] , 0     ; 46 is the transparent color degree of the CAR
;                     JE PREWORKOUT
;                     CMP BYTE PTR ES:[BX] , 142      ; 46 is the transparent color degree of the CAR
;                     JE CAR_DETECTED
;                     DEC BX
;                     JMP ROWS_POWER

; CAR_DETECTED:
;                     INC BX
; PREWORKOUT:
;                     SUB BX , SCREEN_WIDTH
; COL_POWER:
;                     CMP BYTE PTR DS:[BX], 121
;                     JE THE_END
;                     CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
;                     JE CATCHED
;                     CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
;                     JE CATCHED
;                     CMP BYTE PTR ES:[BX] , 0    ; 31 is the WHITE color degree of the road
;                     JE CATCHED
;                     CMP BYTE PTR ES:[BX] , 142    ; 31 is the WHITE color degree of the road
;                     JE CAR_DETECTED_FROM_UP
;                     SUB BX , SCREEN_WIDTH
;                     JMP COL_POWER
; CAR_DETECTED_FROM_UP:
;                     ADD BX , SCREEN_WIDTH
; CATCHED:
;                     INC BX
;                     ADD BX , SCREEN_WIDTH
; THE_END:
;                     RET


;                     CMP horizontalFlag , 1
;                     JE HORIZONTAL_COLLIDE
;                     CMP verticalFlag , 1
;                     JE VERTICAL_COLLIDE
;                     JMP END_POWER
; VERTICAL_COLLIDE:
;                     PUSH BX
;                     SUB BX , 1    ;CHECKING whether the collided bit of the powerup is the left one
;                     CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
;                     JE LEFT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
;                     JE LEFT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
;                     JE LEFT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
;                     JE LEFT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
;                     JE LEFT_CHECKED
;                     POP BX

;                     PUSH BX
;                     INC BX                   ; CHECKING whether the collided bit of the powerup is the right one
;                     CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
;                     JE RIGHT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
;                     JE RIGHT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
;                     JE RIGHT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
;                     JE RIGHT_CHECKED
;                     CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
;                     JE RIGHT_CHECKED
;                     POP BX

;                     CMP YMovement , 1           ; if the car is moving up to the bottom of the powerup                    
;                     JE TO_UP
;                     JMP END_POWER

; TO_UP:
;                     SUB BX , SCREEN_WIDTH
;                     JMP GET_ME_OUT_OF_HERE

; RIGHT_CHECKED:
;                     SUB BX , 2
;                     CMP YMovement , 1           ; if the car is moving up to the bottom of the powerup                    
;                     JE TO_UP
;                     JMP END_POWER 

; LEFT_CHECKED:            
;                     ADD BX ,2
;                     CMP YMovement , 1           ; if the car is moving up to the bottom of the powerup                    
;                     JE TO_UP
;                     JMP END_POWER

; HORIZONTAL_COLLIDE:                    
;                     CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
;                     JE CATCHED
;                     CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
;                     JE CATCHED
;                     CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
;                     JE CATCHED
;                     CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
;                     JE CATCHED
;                     CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
;                     JE CATCHED
;                     SUB BX , SCREEN_WIDTH
;                     JMP HORIZONTAL_COLLIDE

; CATCHED:
;                     ADD BX , SCREEN_WIDTH
;                     CMP XMovement , 0           ; if the car is moving left to the right of the powerup
;                     JE TOLEFT
;                     INC BX
;                     JMP END_POWER
; TOLEFT:
;                     DEC BX

; END_POWER:
;                     ADD BX , SCREEN_WIDTH

; GET_ME_OUT_OF_HERE:                    
;                     RET
                    MOV DX,BX
                    ; PUSH BX
                    ; MOV BX,DX
                    SUB BX , 1    ;CHECKING whether the collided bit of the powerup is the left one
                    CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
                    JE LEFT_CHECKED
                    CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
                    JE LEFT_CHECKED
                    CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
                    JE LEFT_CHECKED
                    CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
                    JE LEFT_CHECKED
                    CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
                    JE LEFT_CHECKED
                    MOV BX ,DX

                    ; MOV DX,BX
                    ; PUSH BX
                    ; MOV BX,DX
                    INC BX                   ; CHECKING whether the collided bit of the powerup is the right one
                    CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
                    JE RIGHT_CHECKED
                    CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
                    JE RIGHT_CHECKED
                    CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
                    JE RIGHT_CHECKED
                    CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
                    JE RIGHT_CHECKED
                    CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
                    JE RIGHT_CHECKED
                    ; POP BX
                    MOV BX ,DX

                    JMP MIDDLE_CHECKED

LEFT_CHECKED:
                    ADD BX ,2
                    SUB BX , SCREEN_WIDTH
                    CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    RET

IAM_AT_TOP:
                    ADD BX , SCREEN_WIDTH
                    ADD BX , SCREEN_WIDTH
                    RET

RIGHT_CHECKED:
                    SUB BX ,2
                    SUB BX , SCREEN_WIDTH
                    CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    RET

MIDDLE_CHECKED:
                    SUB BX , SCREEN_WIDTH
                    CMP BYTE PTR ES:[BX] , 20    ; 20 is the GREY color degree of the road
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 31    ; 31 is the WHITE color degree of the road
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 142    ; 142 is COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 203    ; 203 is the COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    CMP BYTE PTR ES:[BX] , 71      ; 71 is the COLOR DEGREE FOR THE GRASS
                    JE IAM_AT_TOP
                    RET


SearchForLeftVertex ENDP

CalculatePowerupVertex PROC FAR
                       MOV   DI , 0
                       MOV   AX , TEMPY
                       MOV   BX , SCREEN_WIDTH
                       MUL   BX
                       ADD   AX , TEMPX
                       MOV   DI , AX
                       RET
CalculatePowerupVertex ENDP


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
                CMP DL, 0
                JE DONTDRAWBYTECAR
                MOV  BYTE PTR ES:[DI] , DL          ;Drawing the car bit
                DONTDRAWBYTECAR: 
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

ClearPowerup PROC FAR
                        MOV AX,0A000H
                        MOV ES,AX
                        MOV DI ,0
                        MOV CX , POWERH
                        CALL CalculatePowerupVertex
ROWS_CLEAR_POWER:
                        PUSH CX
                        PUSH DI
                        MOV CX , POWERW
COLS_CLEAR_POWER:
                        MOV BYTE PTR ES:[DI] , 0ffh
                        INC DI
                        LOOP COLS_CLEAR_POWER
                        POP DI
                        POP CX
                        ADD DI , SCREEN_WIDTH
                        LOOP ROWS_CLEAR_POWER
                        RET
ClearPowerup ENDP


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
                       JNE   CheckLetterK
                       MOV   RightFlag , 0
                       JMP   Default

    CheckLetterK:     
                       CMP AL , DeletePower1Key
                       JNE NotPressed5
                       MOV KFlag , 1
                       MOV powerupParent , 1
                       ClearPower
                       JMP Default

    NOTPRESSED5:
                          MOV BL , DeletePower1Key
                          ADD BL , 80H
                          CMP AL , BL
                          JNE CheckLetterM
                          MOV KFlag , 0
                          JMP Default
    
    CheckLetterM:
                          CMP AL , DeletePower2Key
                          JNE NotPressed6
                          MOV MFlag , 1
                          MOV powerupParent , 2
                          ClearPower
                          JMP Default

    NOTPRESSED6:

                            MOV BL , DeletePower2Key
                            ADD BL , 80H
                            CMP AL , BL
                            JNE Default
                            MOV MFlag , 0

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

                MOV BL , KFlag
                MOV LetterKFlag , BL

                MOV BL , MFlag
                MOV LetterMFlag , BL

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

                MOV BL , KFlag
                MOV LetterKFlag , BL

                MOV BL , MFlag
                MOV LetterMFlag , BL

                RET
UpdateWASDFlags ENDP

;description

;procedure calls all arrow keys functions
CheckArrowKeys PROC FAR
                SETKEYS ArrowUp, ArrowDown, ArrowLeft, ArrowRight , LetterK , LetterM
                SetFlags ArrowUpFlag, ArrowDownFlag, ArrowLeftFlag, ArrowRightFlag, LetterKFlag, LetterMFlag
                CALL InputButtonSwitchCase
                CALL UpdateArrowFlags
                RET
CheckArrowKeys ENDP

;procedure calls all WASD keys functions
CheckWASDKeys PROC FAR
                SETKEYS WKey, SKey, AKey, DKey , LetterK , LetterM
                SetFlags WFlag, SFlag, AFlag, DFlag , LetterKFlag, LetterMFlag
                CALL InputButtonSwitchCase
                CALL UpdateWASDFlags
                RET
CheckWASDKeys ENDP

Update1 PROC FAR
                CLEAR CarImg1, CAR_SIZE, PrevPosXfirst, PrevPosYfirst
                Draw_Car  CarImg1, CAR_SIZE, Posxfirst , PosYfirst
    CannotDraw:                
                RET
Update1 ENDP


Update2 PROC FAR
                CLEAR CarImg2, CAR_SIZE, PrevPosXsecond, PrevPosYsecond
                Draw_Car CarImg2, CAR_SIZE, PosXsecond , PosYsecond
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
                MOV verticalFlag ,1

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
                ; CMP BYTE PTR ES:[DI] , 142
                ; JNE NoObstacleDetected

                CMP BYTE PTR ES:[DI] , 20    ; 20 is the GREY color degree of the road
                JE NoObstacleDetected
                CMP BYTE PTR ES:[DI] , 31    ; 31 is the WHITE color degree of the road
                JE NoObstacleDetected
                CMP BYTE PTR ES:[DI] , 40    ; 40 is one of the color degrees for the end line
                JE NoObstacleDetected
                ;Checking if it is the increasing speed powerup

                    CMP BYTE PTR ES:[DI] , 121     ; 121 is the color degree of the increasing powerup
                    JE INCPOWERUP_DETECTED2
                    CMP BYTE PTR ES:[DI] , 36       ; 36 is the color degree of any powerup
                    JNE TERMINATE2

                    MOV BX,DI
                    CALL SearchForLeftVertex
                    CMP BYTE PTR ES:[BX] , 121     ; 121 is the color degree of the increasing powerup
                    JE INCPOWERUP_DETECTED2
                    CMP BYTE PTR ES:[BX] , 112     ; 112 is the color degree of the decreasing powerup
                    JE DECPOWERUP_DETECTED2
                    CMP BYTE PTR ES:[BX] , 17
                    JE CREATEOBSTPOWERUP_DETECTED2
                    CMP BYTE PTR ES:[BX] , 28
                    JE PASSOBSTPOWER_DETECTED2
TERMINATE2:
                    POP DI
                    POP CX
                    RET  
INCPOWERUP_DETECTED2:
                    MOV AL , 1
                    MOV powerupType , AL
                    JMP DRAWING_COLLECTED_POWERUP2
DECPOWERUP_DETECTED2:
                    MOV AL , 2
                    MOV powerupType , AL
                    JMP DRAWING_COLLECTED_POWERUP2
CREATEOBSTPOWERUP_DETECTED2:
                    MOV AL , 3
                    MOV powerupType , AL
                    JMP DRAWING_COLLECTED_POWERUP2

PASSOBSTPOWER_DETECTED2:
                    MOV AL , 4
                    MOV powerupType , AL

DRAWING_COLLECTED_POWERUP2:
                    CMP CarToScan , 0       ;Car1 is scanning
                    JE Car2Powerup2
                    ;Powerup for first player is collected

                    MOV AX , powerup1Posx
                    MOV TEMPX , AX

                    MOV AX , powerup1Posy
                    MOV TEMPY , AX

                    MOV AL , CarToScan
                    MOV powerupParent , AL

                    MOV TMP4 , 0

                    DrawPower TEMPX,TEMPY,powerupType
                    JMP TERMINATE2
Car2Powerup2:
                    ;Powerup for second player is collected

                    MOV AX , powerup2Posx
                    MOV TEMPX , AX

                    MOV AX , powerup2Posy
                    MOV TEMPY , AX

                    MOV AL , CarToScan
                    MOV powerupParent , AL

                    MOV TMP4 , 0

                    DrawPower TEMPX,TEMPY, powerupType
                    JMP TERMINATE2
NoObstacleDetected:
                INC DI
                DEC CX
                CMP CX , 0
                JNE CheckY
    
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
                DEC CX
                CMP CX , 0
                JNE NextRow

    checkYFinish:
                MOV verticalFlag,0
                RET
ScanYmovement ENDP

ScanXmovement PROC FAR
                MOV AX , 0A000H
                MOV ES, AX

                MOV DI , 0
                MOV horizontalFlag ,1

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


                    CMP BYTE PTR ES:[DI] , 20    ; 20 is the GREY color degree of the road
                    JE NoObstacleDetected2 
                    CMP BYTE PTR ES:[DI] , 31    ; 31 is the WHITE color degree of the road
                    JE NoObstacleDetected2 
                    CMP BYTE PTR ES:[DI] , 40    ; 40 is one of the color degrees for the end line
                    JE NoObstacleDetected2
                    ;Checking if it is the increasing speed powerup

                    CMP BYTE PTR ES:[DI] , 121     ; 121 is the color degree of the increasing powerup
                    JE INCPOWERUP_DETECTED
                    CMP BYTE PTR ES:[DI] , 36       ; 36 is the color degree of any powerup
                    JNE TERMINATE

                    MOV BX,DI
                    CALL SearchForLeftVertex
                    CMP BYTE PTR ES:[BX] , 121     ; 121 is the color degree of the increasing powerup
                    JE INCPOWERUP_DETECTED
                    CMP BYTE PTR ES:[BX] , 112     ; 112 is the color degree of the decreasing powerup
                    JE DECPOWERUP_DETECTED
                    CMP BYTE PTR ES:[BX] , 17
                    JE CREATEOBSTPOWERUP_DETECTED
                    CMP BYTE PTR ES:[BX] , 28
                    JE PASSOBSTPOWER_DETECTED
TERMINATE:
                    POP DI
                    POP CX
                    RET  
INCPOWERUP_DETECTED:
                    MOV AL , 1
                    MOV powerupType , AL
                    JMP DRAWING_COLLECTED_POWERUP
DECPOWERUP_DETECTED:
                    MOV AL , 2
                    MOV powerupType , AL
                    JMP DRAWING_COLLECTED_POWERUP
CREATEOBSTPOWERUP_DETECTED:
                    MOV AL , 3
                    MOV powerupType , AL
                    JMP DRAWING_COLLECTED_POWERUP

PASSOBSTPOWER_DETECTED:
                    MOV AL , 4
                    MOV powerupType , AL

DRAWING_COLLECTED_POWERUP:
                    CMP CarToScan , 0       ;Car1 is scanning
                    JE Car2Powerup
                    ;Powerup for first player is collected

                    MOV AX , powerup1Posx
                    MOV TEMPX , AX

                    MOV AX , powerup1Posy
                    MOV TEMPY , AX

                    MOV AL , CarToScan
                    MOV powerupParent , AL

                    MOV TMP4 , 0

                    DrawPower TEMPX,TEMPY,powerupType
                    JMP TERMINATE
Car2Powerup:
                    ;Powerup for second player is collected

                    MOV AX , powerup2Posx
                    MOV TEMPX , AX

                    MOV AX , powerup2Posy
                    MOV TEMPY , AX

                    MOV AL , CarToScan
                    MOV powerupParent , AL

                    MOV TMP4 , 0

                    DrawPower TEMPX,TEMPY, powerupType
                    JMP TERMINATE

NoObstacleDetected2:
                    ADD DI , SCREEN_WIDTH
                    DEC CX
                    CMP CX , 0
                    JNE CheckX

                    POP DI
                    POP CX

                    CMP XMovement , 1
                    JNE LeftMovement2

                    INC DI
                    INC CarToDrawX
                    JMP NextLoop2
    LeftMovement2:
                    DEC DI
                    DEC CarToDrawX

    NextLoop2:
                    DEC CX
                    CMP CX , 0
                    JNE NextRow2
    checkXFinish:
                            MOV horizontalFlag ,0
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;     Road procedures      ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;PROC TO DRAW AN IMAGE
DRAWIMAGE PROC FAR 
    PUSH CX
    ;VIDEO MEMORY
    MOV AX, 0A000H
    MOV ES, AX

    MOV DI, STARYTODRAW
    MOV AX, SCREENWIDTH
    MUL DI
    MOV DI, AX
    ADD DI, STARXTODRAW
    
    MOV CX, HEITODRAW
    MOV SI, IMGTODRAW

    ROWS:
        PUSH CX
        PUSH DI
        MOV CX, WIDTODRAW
        COLS:
            MOV DL, BYTE PTR [SI]
            CMP DL, 0
            JE DONTDRAWBYTE
            MOV ES:[DI], DL
            DONTDRAWBYTE:
            INC SI
            INC DI
        LOOP COLS
        POP DI
        POP CX
        ADD DI, SCREENWIDTH
    LOOP ROWS
    MOV DI, STARYTODRAW
    MOV AX, SCREENWIDTH
    MUL DI
    MOV DI, AX
    ADD DI, STARXTODRAW
    ADD DI, WIDTODRAW
    POP CX
    RET
DRAWIMAGE ENDP





;PROC TO RANDOMIZE

GETSYSTEMTIME PROC FAR
    MOV CX, 0
    MOV DX, 59000 ;63997
    MOV AH, 86H
    INT 15H
    MOV AH, 2CH  ; INTERRUPT to get system time
    INT 21H
    RET
GETSYSTEMTIME ENDP


GETSYSTEMTIME2 PROC FAR
    MOV CX, 0
    MOV DX, 53000 ;63997
    MOV AH, 86H
    INT 15H
    MOV AH, 2CH  ; INTERRUPT to get system time
    INT 21H
    RET
GETSYSTEMTIME2 ENDP

RANDOMIZEPERCENTAGE PROC
    CALL GETSYSTEMTIME2                        
    MOV AL, 100
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND    ;DL NOW HAS A NUMBER FROM 0 TO 99           
    RET
RANDOMIZEPERCENTAGE ENDP


;PROC TO GET THE POSIBLE POINTS AFTER DRAWING UP
POINTSAFTERUP PROC
    CALL CALCXY ; AS WE NEED IT IN THE LEFT DIR

    MOV UPDIR, DI
    CMP UPDIR, VERROADIMGH*SCREENWIDTH + VERROADIMGW  ;CHECKING FOR OVERFLOWING THE SCREEN
    JA FIRSTUP
    MOV UPDIR, 0
    JMP NOTFIRSTUP
    FIRSTUP:
    SUB UPDIR, VERROADIMGH*SCREENWIDTH + VERROADIMGW 
    NOTFIRSTUP:

    MOV RIGHTDIR, DI
    SUB RIGHTDIR, HORROADIMGH*SCREENWIDTH + VERROADIMGW 
    MOV DOWNDIR, 0
    
    CMP TEMPX, HORROADIMGW
    JA FIRSTLEFT
    MOV LEFTDIR, 0
    JMP NOTFIRSTLEFT
    FIRSTLEFT:
    MOV LEFTDIR, DI
    SUB LEFTDIR, HORROADIMGH*SCREENWIDTH + HORROADIMGW
    NOTFIRSTLEFT:
    RET
POINTSAFTERUP ENDP

;PROC TO GET THE POSIBLE POINTS AFTER DRAWING RIGHT
POINTSAFTERRIGHT PROC
    MOV UPDIR, DI
    CMP UPDIR, (VERROADIMGH-HORROADIMGH)*SCREENWIDTH
    JA SECONDUP
    MOV UPDIR, 0
    JMP NOTSECONDUP
    SECONDUP:
    SUB UPDIR, (VERROADIMGH-HORROADIMGH)*SCREENWIDTH  ;VERROADIMGH-HORROADIMGH = 30
    NOTSECONDUP:

    MOV RIGHTDIR, DI
    MOV DOWNDIR, DI
    MOV LEFTDIR, 0
    RET
POINTSAFTERRIGHT ENDP

;PROC TO GET THE POSIBLE POINTS AFTER DRAWING DOWN
POINTSAFTERDOWN PROC
    CALL CALCXY
    MOV UPDIR, 0
    MOV RIGHTDIR, DI
    SUB RIGHTDIR, VERROADIMGW
    ADD RIGHTDIR, VERROADIMGH * SCREENWIDTH
    MOV DOWNDIR, DI
    SUB DOWNDIR, VERROADIMGW
    ADD DOWNDIR, VERROADIMGH * SCREENWIDTH

    CMP TEMPX, HORROADIMGW
    JA THIRDLEFT
    MOV LEFTDIR, 0
    JMP NOTTHIRDLEFT
    THIRDLEFT:
    MOV LEFTDIR, DI
    SUB LEFTDIR, HORROADIMGW
    ADD LEFTDIR, VERROADIMGH * SCREENWIDTH
    NOTTHIRDLEFT:
    RET
POINTSAFTERDOWN ENDP

;PROC TO GET THE POSIBLE POINTS AFTER DRAWING LEFT
POINTSAFTERLEFT PROC
    CALL CALCXY
    MOV UPDIR, DI
    CMP UPDIR, HORROADIMGW + VERROADIMGW + (VERROADIMGH - HORROADIMGH) * SCREENWIDTH
    JA FOURTHUP
    MOV UPDIR, 0
    JMP NOTFOURTHUP
    FOURTHUP:
    SUB UPDIR, HORROADIMGW + VERROADIMGW + (VERROADIMGH - HORROADIMGH) * SCREENWIDTH 
    NOTFOURTHUP:
    MOV RIGHTDIR, 0
    MOV DOWNDIR, DI
    SUB DOWNDIR, HORROADIMGW + VERROADIMGW

    CMP TEMPX, 2 * HORROADIMGW
    JA FOURTHLEFT
    MOV LEFTDIR, 0
    JMP NOTFOURTHLEFT
    FOURTHLEFT:
    MOV LEFTDIR, DI
    SUB LEFTDIR, 2 * HORROADIMGW
    NOTFOURTHLEFT:
    RET
POINTSAFTERLEFT ENDP



;PROCEDURE TO CALCULATE X AND Y FROM THE LOCATION OF THE BYTE
CALCXY PROC  
    MOV AX, DI
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX

    MOV TEMPY, AX
    RET
CALCXY ENDP

STORINGROADUNDERPOWER PROC
    MOV AX, POWERH 
    MOV OUTCOUNTER, AX

    POWERROWS:
        MOV FIRSTBYTEINROW, DI
        MOV AX, POWERW
        MOV INCOUNTER, AX
        POWERCOLS:
            MOV AL, BYTE PTR ES:[DI]
            MOV BYTE PTR DS:[SI], AL

            INC DI
            INC SI
            DEC INCOUNTER
        JNZ POWERCOLS
        MOV DI, FIRSTBYTEINROW
        ADD DI, SCREENWIDTH
    DEC OUTCOUNTER
    JNZ POWERROWS   
    RET
STORINGROADUNDERPOWER ENDP

RETRIEVEROAD PROC
    MOV AL, POWERW * POWERH
    MOV BX, CURPOWERINDEX
    MOV BH, 0
    MUL BL   ; NOW AX HAS THE INDEX OF STARTING BYTE

    MOV SI, OFFSET ROADUNDERPOWER
    ADD SI, AX

    MOV BX, OFFSET TOPLEFTPOWER
    MOV AL, 2
    MOV DX, CURPOWERINDEX
    MOV DH, 0
    MUL DL
    ADD BX, AX
    MOV DI, [BX]

    MOV CX, POWERH
    RETRIEVEROWS:
        PUSH CX
        PUSH DI
        MOV CX, POWERW
        RETRIEVECOLS:
            MOV DL, BYTE PTR DS:[SI]
            MOV BYTE PTR ES:[DI], DL
            INC SI
            INC DI
        LOOP RETRIEVECOLS
        POP DI
        POP CX
        ADD DI, SCREENWIDTH
    LOOP RETRIEVEROWS
    RET
RETRIEVEROAD ENDP



SEARCHTORETRIEVE PROC
    MOV DX, POWERTOPLEFTBYTE
    MOV SI, OFFSET TOPLEFTPOWER
    MOV CX, POWERUPCOUNTER
    SEARCH:
    CMP WORD PTR DS:[SI], DX
    JE GOTORETRIEVE
    ADD SI, 2
    LOOP SEARCH

    GOTORETRIEVE:
    MOV AX, POWERUPCOUNTER
    SUB AX, CX
    MOV CURPOWERINDEX, AX
    CALL RETRIEVEROAD
    RET
SEARCHTORETRIEVE ENDP

SHOWHIDDENPOWER PROC
    MOV AX, INDEXSTARTSHOWING
    DEC AX
    MOV BL, 2
    MOV BH, 0
    MUL BL ;NOW WE HAVE THE SHIFTING IN AX
    MOV SI, OFFSET TOPLEFTPOWER
    ADD SI, AX
    MOV DI, WORD PTR DS:[SI]
    CALL CALCXY

    ;DECIDING WHICH POWERUP TO DRAW
    CALL GETSYSTEMTIME
    ;AND DL, 3
    MOV AL, 4
    MOV RANGEOFRAND, AL
    CALL RANGINGRAND
    CMP DL, 0
    JNE HIDNODECSPEED

    DRAW DECSPEEDPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4
    JMP HIDFINISHPOWER
    HIDNODECSPEED:

    CMP DL, 1
    JNE HIDNOINCSPEED
    DRAW INCSPEEDPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4
    JMP HIDFINISHPOWER
    HIDNOINCSPEED:

    CMP DL, 2
    JNE HIDNOPASSOBST
    DRAW PASSOBSTPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4
    JMP HIDFINISHPOWER
    HIDNOPASSOBST:

    CMP DL, 3
    JNE HIDFINISHPOWER
    DRAW CREATEOBSTPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4

    HIDFINISHPOWER:
            
    RET
SHOWHIDDENPOWER ENDP

WHICHPOWERIMG PROC
    CHECKCANDRAWPOWER POWERW, POWERH, TEMPX, TEMPY ;IF IT WILL BE DRAWN ON THE OBST IT WILL NOT BE DRAWN AT ALL (SKIPPED)
    
    CALL RANDOMIZEPERCENTAGE
    CMP DL, POWERPROBABILITY
    JA FINISHPOWER

    MOV DI, TEMPY
    MOV AX, SCREENWIDTH
    MUL DI
    MOV DI, AX
    ADD DI, TEMPX

    ;STORING THE TOP LEFT CORNER AND THE ROAD UNDER THE POWER UP
    MOV SI, OFFSET TOPLEFTPOWER
    MOV AL, 2
    MOV BX, POWERUPCOUNTER
    MOV BH, 0
    MUL BL
    ADD SI, AX
    MOV WORD PTR DS:[SI], DI

    MOV SI, OFFSET ROADUNDERPOWER
    MOV AL, POWERW * POWERH
    MOV BX, POWERUPCOUNTER
    MOV BH, 0
    MUL BL
    ADD SI, AX
    CALL STORINGROADUNDERPOWER
    
    ;RANDOMIZING WHETHER TO DRAW OR MAKE IT HIDDEN UNTIL WE SHOW IT DURING THE GAME 
    CALL RANDOMIZEPERCENTAGE
    MOV SI, OFFSET ISVISIBLEPOWER
    ADD SI, POWERUPCOUNTER
    INC POWERUPCOUNTER ; WE MOVE THAT LINE HERE AS WE NEEDED IT IN THE PREVIOUS LINE
    CMP DL, POWERVISIBPROBABILITY
    JBE VISIBLE
    MOV BYTE PTR DS:[SI], 0
    JMP FINISHPOWER
    
    VISIBLE:
    MOV BYTE PTR DS:[SI], 1
    CALL GETSYSTEMTIME
    ;AND DL, 3
    MOV AL, 4
    MOV RANGEOFRAND, AL
    CALL RANGINGRAND
    CMP DL, 0
    JNE NODECSPEED

    DRAW DECSPEEDPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4
    JMP FINISHPOWER
    NODECSPEED:

    CMP DL, 1
    JNE NOINCSPEED
    DRAW INCSPEEDPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4
    JMP FINISHPOWER
    NOINCSPEED:

    CMP DL, 2
    JNE NOPASSOBST
    DRAW PASSOBSTPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4
    JMP FINISHPOWER
    NOPASSOBST:

    CMP DL, 3
    JNE FINISHPOWER
    DRAW CREATEOBSTPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4

    FINISHPOWER:

RET
WHICHPOWERIMG ENDP



OBSTRANDANDDRAW PROC
    CALL RANDOMIZEPERCENTAGE
    CMP DL, OBSTPROBABILITY
    JA FINISHOBST
    DRAW OBSTACLE, OBSTACLEW, OBSTACLEH, TEMPX, TEMPY, TMP4
    FINISHOBST:
    RET
OBSTRANDANDDRAW ENDP

RANGINGRAND PROC
    MOV AL, DL
    MOV AH, 0
    MOV BL, RANGEOFRAND
    DIV BL
    MOV DL, AH
    MOV DH, 0
    RET
RANGINGRAND ENDP


;PROC TO DRAW THE END RACE LINE
DRAWENDLINE PROC
    ;THIS CAN BE EDITED INTO THE PROC CALCXY(OPTIMIZATION)
    MOV AX, LASTDI
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    MOV TMP4, 0

    CMP LASTDIR, 0
    JNE NOTLASTUP
    SUB TEMPX, VERROADIMGW
    SUB TEMPY, HORENDFLAGIMGH 
    DRAW HORENDFLAGIMG, HORENDFLAGIMGW, HORENDFLAGIMGH, TEMPX, TEMPY, TMP4
    JMP FINISHDRAWENDLINE
    NOTLASTUP:

    CMP LASTDIR, 1
    JNE NOTLASTRIGHT
    DRAW VERENDFLAGIMG, VERENDFLAGIMGW, VERENDFLAGIMGH, TEMPX, TEMPY, TMP4
    JMP FINISHDRAWENDLINE
    NOTLASTRIGHT:

    CMP LASTDIR, 2
    JNE NOTLASTDOWN
    SUB TEMPX, VERROADIMGW
    ADD TEMPY, VERROADIMGH
    DRAW HORENDFLAGIMG, HORENDFLAGIMGW, HORENDFLAGIMGH, TEMPX, TEMPY, TMP4
    JMP FINISHDRAWENDLINE
    NOTLASTDOWN:
    
    SUB TEMPX, HORROADIMGW + VERENDFLAGIMGW
    DRAW VERENDFLAGIMG, VERENDFLAGIMGW, VERENDFLAGIMGH, TEMPX, TEMPY, TMP4
    
    FINISHDRAWENDLINE:
    RET
DRAWENDLINE ENDP






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; MAIN ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAIN PROC FAR
MOV AX, @DATA
MOV DS, AX


MOV AH,0
MOV AL,13H
INT 10H

MOV AX, 0A000H
MOV ES, AX


;;;;;;;;;; DRAWING ROAD ;;;;;;;;;;;;


;DRAWING PART OF ROAD 
;DRAW BACKGROUNDIMAGE, SCREENWIDTH, SCREENHEIGHT, 0, 0
STARTPROGRAM:
    MOV CANTUP, 0
    MOV CANTRIGHT, 0
    MOV CANTDOWN, 0
    MOV CANTLEFT, 0
    MOV POWERUPCOUNTER, 0 ;ADDED THAT WHEN ADDED START PROGRAM
    MOV CURPOWERINDEX, 0
    MOV CX, 11
    MOV TEMPX, 0
    MOV TEMPY, 0
    OUTERLOOP:
    PUSH CX
    MOV CX, 20
    INNERLOOP:
        MOV TMP4, 0
        DRAW BACKGROUNDIMAGEPART , BACKGROUNDIMAGEPARTW, BACKGROUNDIMAGEPARTH, TEMPX, TEMPY, TMP4
        ADD TEMPX, BACKGROUNDIMAGEPARTW
    LOOP INNERLOOP
    MOV TEMPX, 0
    ADD TEMPY, BACKGROUNDIMAGEPARTH
    POP CX
    LOOP OUTERLOOP
;CALL DRAWBCKGROUND

MOV TMP4, 0
MOV CX, 0
DRAW HORROADIMG , HORROADIMGW, HORROADIMGH, STARTROADX, STARTROADY, TMP4
CALL POINTSAFTERRIGHT
DRAW STARTFLAGIMG, STARTFLAGIMGW, STARTFLAGIMGH, STARTROADX, STARTROADY, TMP4


;THIS IS TO RANDOMIZE NUMBER FROM 0 TO 3 TO SPECIFY THE DIRECTON
MOV CX, NUMBEROFPARTS
RANDOMIZEPART:
    CHECKPOSSIBILITIES
    START:
    PUSH CX
    CALL GETSYSTEMTIME
    POP CX
    AND DL, 3
    CMP DL, 0  ;UP
    JE CHECKUP
    CMP DL, 1  ;RIGHT
    JE CHECKRIGHT
    CMP DL, 2  ;DOWN
    JE CHECKDOWN
    JMP CHECKLEFT ;left

    CHECKUP:
    CMP UPDIR, 0
    JNE CONTUP
    MOV CANTUP, 1
    JMP RANDOMIZEPART
    CONTUP:

    MOV AX, UPDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPY, YNOUP
    JB NOTHANDLEUP
    JMP HANDLEUP
    NOTHANDLEUP:
    MOV CANTUP, 1
    JMP RANDOMIZEPART


    CHECKRIGHT:
    CMP RIGHTDIR, 0
    JNE CONTRIGHT
    MOV CANTRIGHT, 1
    JMP RANDOMIZEPART
    CONTRIGHT:

    MOV AX, RIGHTDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPX, XNORIGHT
    JA NOTHANDLERIGHT
    JMP HANDLERIGHT
    NOTHANDLERIGHT:
    MOV CANTRIGHT, 1
    JMP RANDOMIZEPART 
    
    CHECKDOWN:
    CMP DOWNDIR, 0
    JNE CONTDOWN
    MOV CANTDOWN, 1
    JMP RANDOMIZEPART
    CONTDOWN:

    MOV AX, DOWNDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPY, YNODOWN
    JA NOTHANDLEDOWN
    JMP HANDLEDOWN
    NOTHANDLEDOWN:
    MOV CANTDOWN, 1
    JMP RANDOMIZEPART
    
    CHECKLEFT:
    CMP LEFTDIR, 0
    JNE CONTLEFT
    MOV CANTLEFT, 1
    JMP RANDOMIZEPART
    CONTLEFT:

    MOV AX, LEFTDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPX, XNOLEFT
    JB NOTHANDLELEFT
    JMP HANDLELEFT
    NOTHANDLELEFT:
    MOV CANTLEFT, 1
    JMP RANDOMIZEPART





;THIS PART OF HANDLES WAS REVISED
    ;WE CHECK AGAIN HERE FOR THE SCREEN EDGES 
    HANDLEUP:
    MOV TMP, 0
    ;THIS IS TO LEAVE SOME SPACE FOR A ORTHOGONAL PART TO BE DRAWN
    MOV TMP1, VERROADIMGH + HORROADIMGH + 2
    SUB TEMPY, HORROADIMGH + 2
    CHECKCANDRAW VERROADIMGW, TMP1, TEMPX, TEMPY, TMP
    ADD TEMPY, HORROADIMGH + 2
    MOV TMP4, 1
    DRAW VERROADIMG, VERROADIMGW, VERROADIMGH, TEMPX, TEMPY, TMP4
    CALL POINTSAFTERUP
    MOV LASTDIR, 0

    ;OBSTACLE RANDOMIZATION
    PUSH CX
    PUSH TEMPX
    PUSH TEMPY
    CALL GETSYSTEMTIME
    AND DL, VERROADIMGW - OBSTACLEW
    MOV DH, 0
    SUB TEMPX, OBSTACLEW
    SUB TEMPX, DX
    CALL GETSYSTEMTIME
    AND DL, VERROADIMGH - OBSTACLEH - THRESHOLD ; THIS THRESHOLD TO START FROM 10 TO 40 TO NOT MAKE TWO OBSTACLES IN THE CORNER TOGETHER
    MOV DH, 0
    ADD TEMPY, THRESHOLD / 2 ;AS THRESHOLD IS 20 TO START FROM 10
    ADD TEMPY, DX
    MOV TMP4, 0
    CALL OBSTRANDANDDRAW
    
    ;POWERUPRANDOMIZATION
    POP TEMPY
    POP TEMPX
    CALL GETSYSTEMTIME
    MOV AL, VERROADIMGW - POWERW
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND
    SUB TEMPX, POWERW
    SUB TEMPX, DX
    CALL GETSYSTEMTIME
    MOV AL, VERROADIMGH - POWERH - THRESHOLD
    MOV RANGEOFRAND, AL
    CALL RANGINGRAND
    ADD TEMPY, THRESHOLD / 2 ;AS THRESHOLD IS 20 TO START FROM 10
    ADD TEMPY, DX
    MOV TMP4, 0

    ;WHICH POWERUP
    CALL WHICHPOWERIMG
    
    POP CX
    JMP FINISH



    


    ;THIS THE ONLY DIRECTION WE DONT CALL XY IN IT SO THE DI IS STILL ON TOP LEFT AFTER FINISH DRAWING 
    HANDLERIGHT:
    MOV TMP, 1
    MOV TMP1, HORROADIMGW + VERROADIMGW + 2  
    CHECKCANDRAW TMP1, HORROADIMGH, TEMPX, TEMPY, TMP
    MOV TMP4, 1
    DRAW HORROADIMG, HORROADIMGW, HORROADIMGH, TEMPX, TEMPY, TMP4
    CALL POINTSAFTERRIGHT
    MOV LASTDIR, 1

    CMP CX, 0 ;HANDLING FIRST SEGMENT NO OBSTACLES
    JNE NOTFIRSTSEGMENT
    JMP FIRSTSEGMENT
    NOTFIRSTSEGMENT:

    ;OBSTACLE RANDOMIZATION
    PUSH CX
    PUSH TEMPX
    PUSH TEMPY
    CALL GETSYSTEMTIME                         
    AND DL, HORROADIMGW - OBSTACLEW - THRESHOLD
    MOV DH, 0
    ADD TEMPX, THRESHOLD / 2
    ADD TEMPX, DX
    CALL GETSYSTEMTIME                         
    AND DL, HORROADIMGH - OBSTACLEH
    MOV DH, 0
    ADD TEMPY, DX
    MOV TMP4, 0
    CALL OBSTRANDANDDRAW


    ;POWERUPRANDOMIZATION
    POP TEMPY
    POP TEMPX
    CALL GETSYSTEMTIME                         
    MOV AL, HORROADIMGW - POWERW - THRESHOLD
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND
    ADD TEMPX, THRESHOLD / 2
    ADD TEMPX, DX
    CALL GETSYSTEMTIME
    MOV AL, HORROADIMGH - POWERH
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND   
    ADD TEMPY, DX
    MOV TMP4, 0

    ;WHICH POWERUP
    CALL WHICHPOWERIMG


    POP CX

    FIRSTSEGMENT:
    JMP FINISH
    





    HANDLEDOWN:
    MOV TMP, 2
    MOV TMP1, VERROADIMGH + HORROADIMGH + 2
    CHECKCANDRAW VERROADIMGW, TMP1, TEMPX, TEMPY, TMP
    MOV TMP4, 1
    DRAW VERROADIMG, VERROADIMGW, VERROADIMGH, TEMPX, TEMPY, TMP4
    MOV LASTDIR, 2
    CALL POINTSAFTERDOWN

    ;OBSTACLE RANDOMIZATION
    PUSH CX
    PUSH TEMPX
    PUSH TEMPY
    CALL GETSYSTEMTIME
    AND DL, VERROADIMGW - OBSTACLEW
    MOV DH, 0
    SUB TEMPX, OBSTACLEW
    SUB TEMPX, DX
    CALL GETSYSTEMTIME
    AND DL, VERROADIMGH - OBSTACLEH - THRESHOLD
    MOV DH, 0
    ADD TEMPY, THRESHOLD / 2
    ADD TEMPY, DX
    MOV TMP4, 0
    CALL OBSTRANDANDDRAW

    ;POWERUPRANDOMIZATION
    POP TEMPY
    POP TEMPX
    CALL GETSYSTEMTIME
    MOV AL, VERROADIMGW - POWERW
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND
    SUB TEMPX, POWERW
    SUB TEMPX, DX
    CALL GETSYSTEMTIME
    MOV AL, VERROADIMGH - POWERH - THRESHOLD
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND
    ADD TEMPY, THRESHOLD / 2
    ADD TEMPY, DX
    MOV TMP4, 0

    ;WHICH POWERUP
    CALL WHICHPOWERIMG


    POP CX
    JMP FINISH



    
    HANDLELEFT:
    MOV TMP, 3
    MOV TMP1, HORROADIMGW + VERROADIMGW + 2
    SUB TEMPX, VERROADIMGW + 2
    CHECKCANDRAW TMP1, HORROADIMGH, TEMPX, TEMPY, TMP
    ADD TEMPX, VERROADIMGW + 2
    MOV TMP4, 1
    DRAW HORROADIMG, HORROADIMGW, HORROADIMGH, TEMPX, TEMPY, TMP4
    MOV LASTDIR, 3
    CALL POINTSAFTERLEFT

    ;OBSTACLE RANDOMIZATION
    PUSH CX
    PUSH TEMPX
    PUSH TEMPY
    CALL GETSYSTEMTIME
    AND DL, HORROADIMGW - OBSTACLEW - THRESHOLD
    MOV DH, 0
    SUB TEMPX, OBSTACLEW  + THRESHOLD / 2
    SUB TEMPX, DX
    CALL GETSYSTEMTIME
    AND DL, HORROADIMGH - OBSTACLEH
    MOV DH, 0
    ADD TEMPY, DX
    MOV TMP4, 0
    CALL OBSTRANDANDDRAW


    ;POWERUPRANDOMIZATION
    POP TEMPY
    POP TEMPX
    CALL GETSYSTEMTIME
    MOV AL, HORROADIMGW - POWERW - THRESHOLD
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND
    SUB TEMPX, POWERW  + THRESHOLD / 2
    SUB TEMPX, DX
    CALL GETSYSTEMTIME
    MOV AL, HORROADIMGH - POWERH
    MOV RANGEOFRAND, AL 
    CALL RANGINGRAND
    ADD TEMPY, DX
    MOV TMP4, 0

    ;WHICH POWERUP
    CALL WHICHPOWERIMG


    POP CX

    FINISH:
;INITIALIZING CANT DRAW ARRAY
MOV CANTUP, 0
MOV CANTRIGHT, 0
MOV CANTDOWN, 0
MOV CANTLEFT, 0

DEC CX
JNZ GOUP
JMP LAST
GOUP:
JMP FAR PTR RANDOMIZEPART


LAST:
CMP CX, NUMBEROFPARTS - MINNUMOFPARTS
JBE NOTSTARTPROGRAM
CALL GETSYSTEMTIME2
JMP STARTPROGRAM
NOTSTARTPROGRAM:
CALL DRAWENDLINE

; MOV CURPOWERINDEX, 4
; CALL RETRIEVEROAD

     ; set initial pos of first car in the game
                MOV  PosXfirst , STARTROADX
                MOV  PosYfirst , STARTROADY + 1
                Draw_Car CarImg1, CAR_SIZE, PosXfirst , PosYfirst

                ; set initial pos of second car in the game
                MOV  PosXsecond , STARTROADX 
                MOV  PosYsecond , STARTROADY + HORROADIMGH - Car_Size - 1
                Draw_Car CarImg2, CAR_SIZE, PosXsecond , PosYsecond

                MOV DX , PosXfirst
                MOV PosX, DX

                MOV DX , PosYfirst
                MOV PosY, DX

                ;Multiplayers' Names
                MOV AH,2
                MOV DH , player1PosY
                MOV DL , player1PosX
                INT 10H

                MOV AH ,9
                LEA DX , player1Name
                INT 21H

                MOV AH ,2
                MOV DH , player2PosY
                MOV DL , player2PosX
                INT 10H

                MOV AH ,9
                LEA DX , player2Name
                INT 21H

                MOV AH ,2 
                MOV DH , player1PosY
                ADD DH ,1
                MOV DL , player1PosX
                INT 10H

                MOV AH , 09
                LEA DX , powerupMessage
                INT 21H

                MOV AH ,2 
                MOV DH , player2PosY
                ADD dh , 1
                MOV DL , player2PosX
                INT 10H

                MOV AH , 09
                LEA DX , powerupMessage
                INT 21H

        

                    ; MOV TMP4 , 0
                    ; MOV TEMPX , 71
                    ; MOV TEMPY , 187
                    ; DRAW INCSPEEDPOWER, POWERW, POWERH, TEMPX, TEMPY, TMP4

                    ; MOV powerupParent , 1
                    ; ClearPower
 

     mainLoop:          

    ;             ; MOV AH, 2CH  ; INTERRUPT to get system time
    ;             ; INT 21H
    ;             ; MOV AL, DH
    ;             ; MOV AH, 0
    ;             ; MOV BL, 3
    ;             ; DIV BL
    ;             ; CMP AH, 0
    ;             ; JNE DONTSHOWPOWER
    ;             ; MOV SI, OFFSET ISVISIBLEPOWER
    ;             ; ADD SI, INDEXSTARTSHOWING
    ;             ; INC INDEXSTARTSHOWING
    ;             ; CMP BYTE PTR DS:[SI], 0
    ;             ; JNE DONTSHOWPOWER
    ;             ; CALL SHOWHIDDENPOWER


    ;             ; DONTSHOWPOWER:

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
                MOV DX , 40997D
                MOV AH , 86H
                INT 15H

                JMP  mainLoop                             ; keep looping
    exit:              
                HLT

MAIN ENDP


END MAIN





; MOV DI, 0

; ;BACKGROUND WITH IMAGE
; BACKGROUND:
;     MOV CX, SCREENSIZE
;     MOV Bx, offset img
; BACKGROUNDLOOP:
;     MOV DL, BYTE PTR [Bx]
;     MOV ES:[DI], DL
;     INC DI
;     INC BX
; LOOP BACKGROUNDLOOP