;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; MACROS ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;MACRO TO DRAW AN IMAGE GIVEN THESE PARAMS
DRAWIMAGE MACRO IMG, WID, HEI, STARX, STARY
              LOCAL ROWS, COLS
              PUSH  CX
    ;VIDEO MEMORY
              MOV   AX, 0A000H
              MOV   ES, AX

              MOV   DI, STARY
              MOV   AX, SCREENWIDTH
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
              ADD   DI, SCREENWIDTH
              LOOP  ROWS
              MOV   DI, STARY
              MOV   AX, SCREENWIDTH
              MUL   DI
              MOV   DI, AX
              ADD   DI, STARX
              ADD   DI, WID
              POP   CX
ENDM



CHECKCANDRAW MACRO WID, HEI, STARX, STARY
                   LOCAL ROWS, COLS, FINISH, HANDLECANTDRAW
    ;VIDEO MEMORY
                   MOV   AX, 0A000H
                   MOV   ES, AX

                   MOV   DI, STARY
                   MOV   AX, SCREENWIDTH
                   MUL   DI
                   MOV   DI, AX
                   ADD   DI, STARX
                   MOV   OUTCOUNTER, HEI

    ROWS:          
                   MOV   FIRSTBYTEINROW, DI
                   MOV   INCOUNTER, WID
    COLS:          
                   CMP   ES:[DI], 20
                   JE    HANDLECANTDRAW
                   INC   DI
                   DEC   INCOUNTER
                   JNZ   COLS
                   MOV   DI, FIRSTBYTEINROW
                   ADD   DI, SCREENWIDTH
                   DEC   OUTCOUNTER
                   JNZ   ROWS
                   JMP   FINISH
    HANDLECANTDRAW:
                   JMP   RANDOMIZEPART
    FINISH:        
ENDM


.MODEL MEDIUM
.STACK 64
.DATA
    ;BACKGROUND
    BACKGROUNDIMAGE DB  ?
    SCREENWIDTH     EQU 320
    SCREENHEIGHT    EQU 200
    SCREENSIZE      EQU 32*32

    ;TEMPORARY X AND Y
    TEMPX           DW  ?
    TEMPY           DW  ?

    ;COUNTERS FOR CHECKDRAW
    OUTCOUNTER      DW  ?
    INCOUNTER       DW  ?
    FIRSTBYTEINROW  DW  ?

    ;START
    STARTROADY      EQU 150


    ;CONSTRAINTS          ;;;; 10 GAB IS LET
    XNOLEFT         EQU 30
    XNORIGHT        EQU 240
    YNOUP           EQU 30
    YNODOWN         EQU 120

    ;DIRECTIONS
    UPDIR           DW  ?
    RIGHTDIR        DW  ?
    DOWNDIR         DW  ?
    LEFTDIR         DW  ?

    ;ROAD IMAGES
    VERROADIMGW     EQU 20
    VERROADIMGH     EQU 50
    VERROADIMG      DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20

    HORROADIMGW     EQU 50
    HORROADIMGH     EQU 20
    HORROADIMG      DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 31, 31, 31, 31, 20, 20, 31, 31, 31, 31, 31, 31, 20
                    DB  20, 31, 31, 31, 31, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 31, 31, 31, 31, 31
                    DB  31, 20, 20, 31, 31, 31, 31, 31, 31, 20, 20, 31, 31, 31, 31, 31, 31, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
                    DB  20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
.CODE







    ;PROC TO RANDOMIZE
GetSystemTime PROC
                     MOV          AH, 2Ch                                                                         ; INTERRUPT to get system time
                     INT          21h
                     RET
GetSystemTime ENDP



    ;PROC TO GET THE POSIBLE POINTS AFTER DRAWING UP
POINTSAFTERUP PROC
                     MOV          UPDIR, DI
                     SUB          UPDIR, VERROADIMGH*SCREENWIDTH + VERROADIMGW
                     MOV          RIGHTDIR, DI
                     SUB          RIGHTDIR, HORROADIMGH*SCREENWIDTH + VERROADIMGW
                     MOV          DOWNDIR, 0
                     MOV          LEFTDIR, DI
                     SUB          LEFTDIR, HORROADIMGH*SCREENWIDTH + HORROADIMGW
                     RET
POINTSAFTERUP ENDP

    ;PROC TO GET THE POSIBLE POINTS AFTER DRAWING RIGHT
POINTSAFTERRIGHT PROC
                     MOV          UPDIR, DI
                     SUB          UPDIR, (VERROADIMGH-HORROADIMGH)*SCREENWIDTH                                    ;VERROADIMGH-HORROADIMGH = 30
                     MOV          RIGHTDIR, DI
                     MOV          DOWNDIR, DI
                     MOV          LEFTDIR, 0
                     RET
POINTSAFTERRIGHT ENDP

    ;PROC TO GET THE POSIBLE POINTS AFTER DRAWING DOWN
POINTSAFTERDOWN PROC
                     MOV          UPDIR, 0
                     MOV          RIGHTDIR, DI
                     SUB          RIGHTDIR, VERROADIMGW
                     ADD          RIGHTDIR, VERROADIMGH * SCREENHEIGHT
                     MOV          DOWNDIR, DI
                     SUB          DOWNDIR, VERROADIMGW
                     ADD          DOWNDIR, VERROADIMGH * SCREENHEIGHT
                     MOV          RIGHTDIR, DI
                     SUB          RIGHTDIR, HORROADIMGW
                     ADD          RIGHTDIR, VERROADIMGH * SCREENHEIGHT
                     RET
POINTSAFTERDOWN ENDP

    ;PROC TO GET THE POSIBLE POINTS AFTER DRAWING LEFT
POINTSAFTERLEFT PROC
                     MOV          UPDIR, DI
                     SUB          UPDIR, HORROADIMGW + VERROADIMGW + (VERROADIMGH - HORROADIMGW) * SCREENWIDTH
                     MOV          RIGHTDIR, 0
                     MOV          DOWNDIR, DI
                     SUB          UPDIR, HORROADIMGW + VERROADIMGW
                     MOV          LEFTDIR, DI
                     SUB          LEFTDIR, 2 * HORROADIMGW
                     RET
POINTSAFTERLEFT ENDP








    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;; MAIN ;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAIN PROC FAR
                     MOV          AX, @DATA
                     MOV          DS, AX

                     MOV          AH,0
                     MOV          AL,13H
                     INT          10H

                     MOV          AX, 0A000H
                     MOV          ES, AX


    ;;;;;;;;;; DRAWING ROAD ;;;;;;;;;;;;


    ;DRAWING PART OF ROAD
                     DRAWIMAGE    HORROADIMG , HORROADIMGW, HORROADIMGH, 0, STARTROADY
                     CALL         POINTSAFTERRIGHT
    ;THIS IS TO RANDOMIZE NUMBER FROM 0 TO 3 TO SPECIFY THE DIRECTON
                     MOV          CX, 14
    RANDOMIZEPART:   
                     PUSH         CX
                     CALL         GetSystemTime
                     POP          CX
                     AND          DL, 3
                     CMP          DL, 0                                                                           ;UP
                     JE           CHECKUP
                     CMP          DL, 1                                                                           ;RIGHT
                     JE           CHECKRIGHT
                     CMP          DL, 2                                                                           ;DOWN
                     JE           CHECKDOWN
                     JMP          CHECKLEFT                                                                       ;left

    CHECKUP:         
                     CMP          UPDIR, 0
                     JE           RANDOMIZEPART
                     MOV          AX, UPDIR
                     MOV          DX, 0
                     MOV          BX, SCREENWIDTH
                     DIV          BX
                     MOV          TEMPX, DX
                     MOV          TEMPY, AX
                     CMP          TEMPY, YNOUP
                     JAE          HANDLEUP
                     JMP          RANDOMIZEPART

    CHECKRIGHT:      
                     CMP          RIGHTDIR, 0
                     JE           RANDOMIZEPART
                     MOV          AX, RIGHTDIR
                     MOV          DX, 0
                     MOV          BX, SCREENWIDTH
                     DIV          BX
                     MOV          TEMPX, DX
                     MOV          TEMPY, AX
                     CMP          TEMPX, XNORIGHT
                     JBE          HANDLERIGHT
                     JMP          RANDOMIZEPART
    
    CHECKDOWN:       
                     CMP          DOWNDIR, 0
                     JE           RANDOMIZEPART
                     MOV          AX, DOWNDIR
                     MOV          DX, 0
                     MOV          BX, SCREENWIDTH
                     DIV          BX
                     MOV          TEMPX, DX
                     MOV          TEMPY, AX
                     CMP          TEMPY, YNODOWN
                     JBE          HANDLEDOWN
                     JMP          RANDOMIZEPART
    
    CHECKLEFT:       
                     CMP          LEFTDIR, 0
                     JE           RANDOMIZEPART
                     MOV          AX, LEFTDIR
                     MOV          DX, 0
                     MOV          BX, SCREENWIDTH
                     DIV          BX
                     MOV          TEMPX, DX
                     MOV          TEMPY, AX
                     CMP          TEMPX, XNOLEFT
                     JAE          HANDLELEFT
                     JMP          RANDOMIZEPART



    ;WE CHECK AGAIN HERE FOR THE SCREEN EDGES
    HANDLEUP:        
                     CHECKCANDRAW VERROADIMGW, VERROADIMGH, TEMPX, TEMPY
                     DRAWIMAGE    VERROADIMG, VERROADIMGW, VERROADIMGH, TEMPX, TEMPY
                     CALL         POINTSAFTERUP
                     JMP          FINISH

    HANDLERIGHT:     
                     CHECKCANDRAW HORROADIMGW, HORROADIMGH, TEMPX, TEMPY
                     DRAWIMAGE    HORROADIMG, HORROADIMGW, HORROADIMGH, TEMPX, TEMPY
                     CALL         POINTSAFTERRIGHT
                     JMP          FINISH
    
    HANDLEDOWN:      
                     CHECKCANDRAW VERROADIMGW, VERROADIMGH, TEMPX, TEMPY
                     DRAWIMAGE    VERROADIMG, VERROADIMGW, VERROADIMGH, TEMPX, TEMPY
                     CALL         POINTSAFTERDOWN
                     JMP          FINISH
    
    HANDLELEFT:      
                     CHECKCANDRAW HORROADIMGW, HORROADIMGH, TEMPX, TEMPY
                     DRAWIMAGE    HORROADIMG, HORROADIMGW, HORROADIMGH, TEMPX, TEMPY
                     CALL         POINTSAFTERLEFT

    FINISH:          
                     DEC          CX
                     JNZ          GOUP
                     JMP          LAST
    GOUP:            
                     JMP          FAR PTR RANDOMIZEPART


    LAST:            


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