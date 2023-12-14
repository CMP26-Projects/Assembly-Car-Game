;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; MACROS ;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                        ;MACROS OF CARS
   DRAW_CAR MACRO Img, CarSize, StartPosX, StartPosY
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


;Scans the path of the car to handle collisions
;pass the left point of the row you want to scan
;carNo -> 1 for first, 2 -> for second
ScanY MACRO x , y , CarNo , MovemetType
    MOV DX , x
    MOV CarToDrawX , DX

    MOV DX, y
    MOV CarToDrawY , DX

    MOV DL , CarNo
    MOV CarToScan , DL

    MOV DL , MovemetType
    MOV YMovement, DL

    CALL ScanYmovement
ENDM

ScanX MACRO x , y , CarNo , MovemetType
    MOV DX , X
    MOV CarToDrawX , DX

    MOV DX, y
    MOV CarToDrawY , DX

    MOV DL , CarNo
    MOV CarToScan , DL
    
    MOV DL , MovemetType
    MOV XMovement, DL

    CALL ScanXmovement
ENDM                     

.MODEL compact
.STACK 1024
.DATA
;BACKGROUND
BACKGROUNDIMAGEPARTH    EQU     16
BACKGROUNDIMAGEPARTW    EQU     16
BACKGROUNDIMAGEPART     DB      142, 193, 142, 142, 71, 142, 193, 142, 143, 193, 142, 142, 142, 71, 142, 142, 71, 142, 193, 142, 71, 142, 193, 142, 142, 142, 142, 142, 142, 142, 142, 142, 142, 142, 193, 142, 142, 142, 142, 142
 DB 71, 142, 142, 142, 193, 142, 142, 71, 142, 142, 142, 142, 143, 142, 142, 142, 142, 71, 142, 193, 142, 142, 143, 71, 142, 143, 142, 142, 142, 142, 142, 142, 142, 71, 142, 193, 142, 142, 142, 71
 DB 142, 142, 142, 71, 142, 142, 142, 142, 142, 142, 142, 142, 142, 193, 142, 142, 142, 142, 142, 142, 71, 142, 193, 142, 142, 143, 142, 142, 142, 193, 142, 142, 142, 193, 142, 142, 71, 142, 142, 193
 DB 142, 142, 142, 142, 142, 142, 142, 193, 142, 142, 193, 142, 71, 142, 142, 193, 142, 142, 142, 71, 142, 142, 193, 142, 142, 142, 193, 142, 142, 142, 142, 142, 142, 142, 71, 142, 142, 193, 142, 143
 DB 142, 142, 142, 142, 142, 142, 142, 142, 142, 142, 71, 142, 142, 193, 142, 142, 143, 142, 142, 142, 193, 142, 142, 71, 142, 142, 142, 142, 142, 142, 142, 142, 71, 142, 142, 193, 142, 142, 71, 142
 DB 143, 142, 142, 142, 143, 142, 142, 142, 142, 71, 142, 193, 142, 142, 71, 142, 142, 142, 193, 142, 142, 142, 71, 142, 142, 71, 142, 142, 142, 142, 71, 142, 142, 193, 142, 142, 142, 71, 142, 142
 DB 142, 143, 142, 71, 142, 193, 142, 142, 142, 193, 142, 143, 142, 71, 142, 142
SCREENWIDTH             EQU     320
SCREENHEIGHT            EQU     200
SCREENSIZE              EQU     32*32


;OBSTACLE
THRESHOLD               EQU     20
OBSTACLEW               EQU     5
OBSTACLEH               EQU     5
OBSTACLE                DB      16, 16, 16, 16, 16, 16, 28, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
XOBSTACLE               DW      ?
YOBSTACLE               DW      ?

;POWERUPS
POWERW                  EQU     3
POWERH                  EQU     3
CREATEOBSTPOWER         DB      36, 36, 36, 36, 16, 36, 36, 36, 36
PASSOBSTPOWER           DB      36, 36, 36, 36, 28, 36, 36, 36, 36
DECSPEEDPOWER           DB      36, 36, 36, 112, 112, 112, 36, 36, 36
INCSPEEDPOWER           DB      36, 121, 36, 121, 121, 121, 36, 121, 36


;CAR
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

;STARTdd
STARTROADX              EQU     2
STARTROADY              EQU     170
NUMBEROFPARTS           EQU     30

;VARIABLES FOR DRAWIMAGE PROCEDURE
IMGTODRAW               DW      ?
WIDTODRAW               DW      ?
HEITODRAW               DW      ?
STARXTODRAW             DW      ?
STARYTODRAW             DW      ?

;CONSTRAINTS          ;;;; 10 GAB IS LET
XNOLEFT                 EQU     22
XNORIGHT                EQU     248
YNOUP                   EQU     22
YNODOWN                 EQU     128

;DIRECTIONS
UPDIR                   DW      ?
RIGHTDIR                DW      ?
DOWNDIR                 DW      ?
LEFTDIR                 DW      ?

;ROAD IMAGES
VERROADIMGW             EQU     20
VERROADIMGH             EQU     50
VERROADIMG              DB      20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20

HORROADIMGW             EQU     50
HORROADIMGH             EQU     20
HORROADIMG              DB      20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 31, 31, 31, 31, 20, 20, 31, 31, 31, 31, 31, 31, 20
 DB 20, 31, 31, 31, 31, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 31, 31, 31
 DB 31, 20, 20, 31, 31, 31, 31, 31, 31, 20, 20, 31, 31, 31, 31, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
 DB 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Data for the cars 
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



.CODE

DRAWBCKGROUND PROC
    MOV CX, 12
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
    RET
DRAWBCKGROUND ENDP

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
            MOV ES:[DI], DL
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
    MOV DX, 63997
    MOV AH, 86H
    INT 15H
    MOV AH, 2CH  ; INTERRUPT to get system time
    INT 21H
    RET
GETSYSTEMTIME ENDP



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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                        ;PROCEDURES FOR THE CARS
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
                       MOV   BYTE PTR ES:[DI] , 31
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

CheckArrowFlags PROC FAR

    ;------- checking Flags -------
	
                          CMP      ArrowUpFlag , 1
                          JNE      CmpLeft
                          SUB      PosYfirst , 1

                          ScanY PosXfirst, PosYfirst , 1 , 1

    CmpLeft:              
                          CMP      ArrowLeftFlag , 1
                          JNE      CmpDown
                          SUB      PosXfirst, 1

                          ScanX PosXfirst, PosYfirst , 1 , 0
    CmpDown:              
                          CMP      ArrowDownFlag , 1
                          JNE      CmpRight
                          ADD      PosYfirst, 1

                          ScanY PosXfirst, PosYfirst , 1 , 0
                        
    CmpRight:             
                          CMP      ArrowRightFlag, 1
                          JNE      CmpFinish
                          ADD      PosXfirst , 1

                          ScanX PosXfirst, PosYfirst , 1 ,1

    CmpFinish:            
                         RET
CheckArrowFlags ENDP

CheckWASDFlags PROC FAR

    ;------- checking Flags -------
	
                CMP      WFlag , 1
                JNE      CmpLeft2
                SUB     PosYsecond , 1

                ScanY PosXsecond, PosYsecond , 0 , 1

    CmpLeft2:              
                CMP      AFlag , 1
                JNE      CmpDown2
                SUB      PosXsecond, 1

                ScanX PosXsecond, PosYsecond , 0 , 0

    CmpDown2:              
                CMP      SFlag , 1
                JNE      CmpRight2
                ADD     PosYsecond, 1

                ScanY PosXsecond, PosYsecond , 0 , 0

    CmpRight2:             
                CMP      DFlag, 1
                JNE      CmpFinish2
                ADD      PosXsecond , 1

                ScanX PosXsecond, PosYsecond , 0 ,1

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
; UpdateCar1Pos PROC
;                 MOV DX , PosX
;                 MOV PosXfirst, DX

;                 MOV DX, PosY
;                 MOV PosYfirst, DX
;                 RET
; UpdateCar1Pos ENDP

;description
; UpdateCar2Pos PROC
;                 MOV DX , PosX
;                 MOV PosXsecond, DX

;                 MOV DX, PosY
;                 MOV PosYsecond, DX
;                 RET
; UpdateCar2Pos ENDP

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
                SETKEYS ArrowUp, ArrowDown, ArrowLeft, ArrowRight
                SetFlags ArrowUpFlag, ArrowDownFlag, ArrowLeftFlag, ArrowRightFlag
                CALL InputButtonSwitchCase
                CALL UpdateArrowFlags
                RET
CheckArrowKeys ENDP

;procedure calls all WASD keys functions
CheckWASDKeys PROC
                SETKEYS WKey, SKey, AKey, DKey
                SetFlags WFlag, SFlag, AFlag, DFlag
                CALL InputButtonSwitchCase
                CALL UpdateWASDFlags
                RET
CheckWASDKeys ENDP

Update1 PROC FAR
                ; MOV DX , PosXfirst
                ; MOV CarToDrawX , DX

                ; MOV DX , PosYfirst
                ; MOV CarToDrawY , DX

                ; MOV IsSafeToMove , 0
                ; CALL ScanCarPath
                ; CMP IsSafeToMove , 1
                ; JE CannotDraw

                CLEAR CAR_SIZE, PrevPosXfirst, PrevPosYfirst
                DRAW_CAR  CarImg1, CAR_SIZE, Posxfirst , PosYfirst
    CannotDraw:                
                RET
Update1 ENDP


Update2 PROC FAR
                CLEAR CAR_SIZE, PrevPosXsecond, PrevPosYsecond
                DRAW_CAR  CarImg2, CAR_SIZE, PosXsecond , PosYsecond
                RET
Update2 ENDP

;description
ScanYmovement PROC
    
                MOV AX , 0A000H
                MOV ES , AX
                
                MOV DI , 0
                
                CMP YMovement , 0  ; The car is moving down either car1 or car2
                JNE UpMovement
                ADD CarToDrawY , (CAR_SIZE-1)

    UpMovement:
                CALL CalculateBoxVertex
                MOV CX , CAR_SIZE

    CheckY:
                CMP BYTE PTR ES:[DI] , 20   ; 20 is the GREY color degree of the road
                JE NoObstacleDetected 
                CMP BYTE PTR ES:[DI] , 31   ; 31 is the WHITE color degree of the road
                JE NoObstacleDetected 
                CMP BYTE PTR ES:[DI] , 40   ; 40 is one of the color degrees for the end line
  
    ;Checking that the car that it is scanning      
                CMP CarToScan , 0                   
                JE Car2
    ;Changing car1 position to the previous position  
                MOV DX , PrevPosYfirst    
                MOV PosYfirst , DX
                JMP checkYFinish
    ;Changing car2 position to the previous position            
    Car2:       
                MOV DX , PrevPosYsecond
                MOV PosYsecond , DX
                JMP checkYFinish
    ;No matching found, continue looping
    NoObstacleDetected:
                INC DI
                LOOP checkY

    checkYFinish:
                RET
ScanYmovement ENDP

ScanXmovement PROC FAR
    MOV AX , 0A000H
    MOV ES, AX

    MOV DI , 0

    CMP XMovement , 1   ; The car is moving right either car1 or car2
    JNE LeftMovement
    ADD CarToDrawX , (Car_Size -1)

LeftMovement:
        CALL CalculateBoxVertex
        MOV CX, Car_Size

CheckX:         ; Check if there is an obstacle in the way
                CMP BYTE PTR ES:[DI] , 20   ; 20 is the GREY color degree of the road
                JE NoObstacleDetected2 
                CMP BYTE PTR ES:[DI] , 31   ; 31 is the WHITE color degree of the road
                JE NoObstacleDetected2 
                CMP BYTE PTR ES:[DI] , 40    ; 40 is one of the color degrees for the end line
                JE NoObstacleDetected2


    ;Checking that the car that it is scanning      
                CMP CarToScan , 0                    
                JE Car2_XDetection
    ;Changing car1 position to the previous position  
                MOV DX , PrevPosXfirst    
                MOV PosXfirst , DX
                JMP checkXFinish
    ;Changing car2 position to the previous position            
    Car2_XDetection:       
                MOV DX , PrevPosXsecond
                MOV PosXsecond , DX
                JMP checkXFinish
    ;No matching found, continue looping
    NoObstacleDetected2:
                ADD DI , SCREEN_WIDTH
                LOOP checkX

    checkXFinish:
                RET
ScanXmovement ENDP

INT09H PROC FAR
                IN     AL, 60H
                            
                CALL CheckArrowKeys
                CALL CheckWASDKeys

                                    
                MOV AL , 20H
                OUT 20H, AL
                IRET
INT09H ENDP




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
CALL DRAWBCKGROUND
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
    JE CHECKUP_RANDOM
    CMP DL, 1  ;RIGHT
    JE CHECKRIGHT_RANDOM
    CMP DL, 2  ;DOWN
    JE CHECKDOWN_RANDOM
    JMP CHECKLEFT_RANDOM ;left

    CHECKUP_RANDOM:
    CMP UPDIR, 0
    JNE CONTUP_RANDOM
    MOV CANTUP, 1
    JMP RANDOMIZEPART
    CONTUP_RANDOM:

    MOV AX, UPDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPY, YNOUP
    JAE HANDLEUP
    MOV CANTUP, 1
    JMP RANDOMIZEPART

    CHECKRIGHT_RANDOM:
    CMP RIGHTDIR, 0
    JNE CONTRIGHT_RANDOM
    MOV CANTRIGHT, 1
    JMP RANDOMIZEPART
    CONTRIGHT_RANDOM:

    MOV AX, RIGHTDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPX, XNORIGHT
    JBE HANDLERIGHT
    MOV CANTRIGHT, 1
    JMP RANDOMIZEPART 
    
    CHECKDOWN_RANDOM:
    CMP DOWNDIR, 0
    JNE CONTDOWN_RANDOM
    MOV CANTDOWN, 1
    JMP RANDOMIZEPART
    CONTDOWN_RANDOM:

    MOV AX, DOWNDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPY, YNODOWN
    JBE HANDLEDOWN
    MOV CANTDOWN, 1
    JMP RANDOMIZEPART
    
    CHECKLEFT_RANDOM:
    CMP LEFTDIR, 0
    JNE CONTLEFT_RANDOM
    MOV CANTLEFT, 1
    JMP RANDOMIZEPART
    CONTLEFT_RANDOM:

    MOV AX, LEFTDIR
    MOV DX, 0
    MOV BX, SCREENWIDTH
    DIV BX
    MOV TEMPX, DX
    MOV TEMPY, AX
    CMP TEMPX, XNOLEFT
    JAE HANDLELEFT
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
    DRAW OBSTACLE, OBSTACLEW, OBSTACLEH, TEMPX, TEMPY, TMP4
    
    ;POWERUPRANDOMIZATION
    POP TEMPY
    POP TEMPX
    CALL GETSYSTEMTIME
    AND DL, 17
    MOV DH, 0
    SUB TEMPX, 3
    SUB TEMPX, DX
    MOV AX, TEMPX
    MOV TMP5, AX
    CALL GETSYSTEMTIME
    AND DL, VERROADIMGH - POWERH - THRESHOLD ; THIS THRESHOLD TO START FROM 10 TO 40 TO NOT MAKE TWO OBSTACLES IN THE CORNER TOGETHER
    MOV DH, 0
    ADD TEMPY, THRESHOLD / 2 ;AS THRESHOLD IS 20 TO START FROM 10
    ADD TEMPY, DX
    MOV TMP4, 0

    ;WHICH POWERUP
    CALL GETSYSTEMTIME
    AND DL, 3
    CMP DL, 0
    JNE NODECSPEED
    DRAW DECSPEEDPOWER, POWERW, POWERH, TMP5, TEMPY, TMP4
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
    JE FIRSTSEGMENT

    ;OBSTACLE RANDOMIZATION
    PUSH CX
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
    DRAW OBSTACLE, OBSTACLEW, OBSTACLEH, TEMPX, TEMPY, TMP4
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
    DRAW OBSTACLE, OBSTACLEW, OBSTACLEH, TEMPX, TEMPY, TMP4
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
    DRAW OBSTACLE, OBSTACLEW, OBSTACLEH, TEMPX, TEMPY, TMP4
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
CALL DRAWENDLINE

                MOV  PosXfirst , STARTROADX
                MOV  PosYfirst , STARTROADY
                DRAW_CAR CarImg1, CAR_SIZE, PosXfirst , PosYfirst

                ; set initial pos of second car in the game
                MOV  PosXsecond , STARTROADX
                MOV  PosYsecond , STARTROADY + 20 - CAR_SIZE
                DRAW_CAR CarImg2, CAR_SIZE, PosXsecond , PosYsecond

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
                CALL CheckWASDFlags
                
                
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

                MOV   CX , 60000
     WasteTime:         
                LOOP  WasteTime

                JMP  mainLoop                             ; keep looping
    exit:              
                HLT




MAIN ENDP


END MAIN