.386
DATA SEGMENT USE16                               ; Equivalent to .data in 32-bit ; Doctor Allowed using .386

    ; Screen Info
    SCREENWIDTH  EQU 320
    SCREENHEIGHT EQU 200
    SCREENSIZE   EQU SCREENWIDTH*SCREENHEIGHT

    ; Color Info
    COLORBLACK   EQU 0
    COLORWHITE   EQU 15
    BOXCOLOR     EQU 230                         ; You can choose any color between 0 and 255

    ; Box Info
    BOXSIZE      EQU 20
    BOXX         dw  ?
    BOXY         dw  ?


DATA ENDS                                        ; It must be ended unlike .data in 32-bit

CODE SEGMENT USE16                                                  ; Equivalent to .code in 32-bit
                       ASSUME CS:CODE,DS:DATA                       ; To tell him to replace .data and .code with CODE and DATA
    BEG:                                                            ; MUST BE BEG (DON'T KNOW WHY YET)
                       MOV    AX,DATA
                       MOV    DS,AX

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CODE STARTS HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Set Video Mode (320x200 256 colors)
                       MOV    AX,13H
                       INT    10H
  
    ; Set Box Position (Center)
                       MOV    BOXX, (SCREENWIDTH - BOXSIZE) / 2
                       MOV    BOXY, (SCREENHEIGHT - BOXSIZE) / 2

    ; Clear the screen
                       call   clearScreen                           ; Loops and procedures can be called its just pusha and jmp and allows you to use ret

    ; Draw the box
                       call   drawBox

    ; MAIN LOOP
    mainLoop:          
    ; wait for a key press
                       mov    ah, 00h
                       int    16h                                   ; wait for key press - store key in ah

    ; Handle arrow keys (ah stores the scan code of the key not the ASCII code)
                       cmp    ah, 48h                               ; up arrow
                       je     moveUp
                       cmp    ah, 50h                               ; down arrow
                       je     moveDown
                       cmp    ah, 4bh                               ; left arrow
                       je     moveLeft
                       cmp    ah, 4dh                               ; right arrow
                       je     moveRight

                       cmp    ah, 01h                               ; escape
                       je     exit

                       jmp    mainLoop                              ; keep looping

    moveUp:            
    ;checking page upper edge
                       cmp    BOXY , 0
                       je     exitMovement
    ;applying movement
    ;  sub    BOXY, 2
    ;  call   clearScreen
    ;  call   drawBox

    ;  jmp    exitMovement


                       mov    cx , 4
    lap:               
                       call   calculateBoxVertex
                       push   cx
                       add    di , SCREENWIDTH*(BOXSIZE-1)
                        
                       mov    cx , BOXSIZE
    l:                 
                       mov    byte ptr es:[di], COLORBLACK
                       inc    di
                       loop   l

                       call   calculateBoxVertex
                       sub    di , SCREENWIDTH
                       mov    cx,  BOXSIZE
    l1:                
                       mov    byte ptr es:[di], BOXCOLOR
                       inc    di
                       loop   l1
                       
                       sub    BOXY , 1
                       pop    cx
                       loop   lap
                       jmp    exitMovement

    moveDown:          
    ;checking page upper edge
                       cmp    BOXY , SCREENHEIGHT-BOXSIZE
                       je     exitMovement
    ;applying movement
                       add    BOXY, 2
                       call   clearScreen
                       call   drawBox
                       jmp    exitMovement

  
    moveLeft:          
    ;checking page upper edge
                       cmp    BOXX , 0
                       je     exitMovement
    ;applying movement
                       sub    BOXX, 2
                       call   clearScreen
                       call   drawBox
                       jmp    exitMovement


    moveRight:         
    ;checking page upper edge
                       cmp    BOxX , SCREENWIDTH-BOXSIZE
                       je     exitMovement
    ;applying movement
                       add    BOXX, 2
                       call   clearScreen
                       call   drawBox
    
    exitMovement:      
                       jmp    mainLoop

    drawBox:                                                        ; (Imagine it as a Procedure)
    ; summary: draws a box at the given position (BOXX, BOXY)
    ;          with the given size (BOXSIZE)
    ;          and the given color (BOXCOLOR)

    ; write the color to the video memory
                       mov    ax, 0A000h
                       mov    es, ax

                       call   calculateBoxVertex
    ; counters
                       mov    cx, BOXSIZE
                       mov    dx, SCREENWIDTH - BOXSIZE

    drawBoxRow:        
                       push   cx
                       mov    cx, BOXSIZE
    drawBoxPixel:      
                       mov    byte ptr es:[di], BOXCOLOR
                       inc    di
                       loop   drawBoxPixel

                       add    di, dx
                       pop    cx
                       loop   drawBoxRow

                       ret                                          ; return from the procedure (return to the caller - pop flags and ip)

    clearScreen:       
    ; summary: clears the screen by setting all pixels to black
                       mov    ax, 0A000h
                       mov    es, ax                                ; set the video segment

                       mov    di, 0
                       mov    cx, SCREENSIZE                        ; set the counter to the screen size
                       mov    al, COLORBLACK                        ; set the color to black
                       rep    stosb
                       ret

    calculateBoxVertex:
    ; get the start of the row
                       mov    di, BOXY
                       imul   di, SCREENWIDTH                       ; di = BOXY * SCREENWIDTH (two operand multiplication)
                       add    di, BOXX
                       ret
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    exit:                                                           ; exit the program
                       MOV    AH,4CH
                       INT    21H                                   ;back to dos
CODE ENDS
END BEG