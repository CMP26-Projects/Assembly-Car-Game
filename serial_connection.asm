ScrollYRecieving MACRO
                     mov ah,6                  ; function 6
                     mov al,1                  ; scroll by 1 line
                     mov bh,0                  ; normal video attribute
                     mov ch,13                 ; upper left Y
                     mov cl,0                  ; upper left X
                     mov dh,21                 ; lower right Y
                     mov dl,79                 ; lower right X
                     int 10h
                  
                     mov recieveCursorX , 5
ENDM

ScrollYSend MACRO
                mov ah,6               ; function 6
                mov al,1               ; scroll by 1 line
                mov bh,0               ; normal video attribute
                mov ch,1               ; upper left Y
                mov cl,0               ; upper left X
                mov dh,10              ; lower right Y
                mov dl,79              ; lower right X
                int 10h
                  
                mov sendCursorX , 5
ENDM

.model compact
.stack 64
.data

    sendCursorX    DB 5
    sendCursorY    DB 1
    recieveCursorX DB 5
    recieveCursorY DB 13
    SepLineCursorX DB 0

    recievedChar   DB ?
    SendedChar     DB ?

.code

configuration PROC FAR

    ;setting the baud rate
                       MOV              dx,3fbh
                       MOV              AL, 10000000b
                       OUT              DX , AL
    ;setting the protocol
                       MOV              DX , 3F8H
                       MOV              AL , 0CH
                       OUT              DX , AX
    ;Setting MSB of divisor latch
                       MOV              DX , 3F9H
                       MOV              AL, 00H
                       OUT              DX ,AL
    ;Set port configuration
                       MOV              DX , 3fbh
                       MOV              AL , 00011011B
                       OUT              DX , AL

                       RET
configuration ENDP

    ;description
RecieveChar PROC
    ;Get char
                       mov              dx , 03F8H
                       in               al , dx
                       mov              recievedChar, al
            
                       CMP              recievedChar , 27
                       JE               endRecieving

                       CMP              recievedChar , 13
                       JE               enter2

                       mov              ah,2
                       mov              dl , recieveCursorX
                       mov              dh ,  recieveCursorY
                       int              10h
 
    ;printing
                       mov              cx , 1
                       mov              ah, 9
                       mov              bl , 0Fh
                       int              10h

                       ADD              recieveCursorX , 1
 
                       CMP              recieveCursorX  , 79
                       jne              endRecieving
                       CMP              recieveCursorY  ,21
                       jne              enter2
                       ScrollYRecieving


                       jmp              endRecieving

    enter2:            
                       CMP              recieveCursorY  ,21
                       jne              normalEnter
                       ScrollYRecieving
                       jmp              endRecieving
    normalEnter:       
                       mov              recieveCursorX , 5
                       add              recieveCursorY , 1
                        
    ;Setting cursor
    endRecieving:      
                       mov              ah,2
                       mov              dl , recieveCursorX
                       mov              dh ,  recieveCursorY
                       int              10h
                       RET
RecieveChar ENDP


    ;description
SendChar PROC
            
                       MOV              AL , 0
                       MOV              AH , 1
                       INT              16H
                       JZ               EndSending
    ;Get character
                       MOV              AH , 0
                       INT              16H
                       MOV              SendedChar , AL
        
                       CMP              SendedChar , 27
                       JE               EndSending

                       CMP              SendedChar , 13
                       JE               enter

    ;Setting cursor with sending position
                       mov              ah,2
                       mov              dl , sendCursorX
                       mov              dh ,  sendCursorY
                       int              10h

                       mov              cx , 1
                       mov              ah, 9
                       mov              bl , 0Fh
                       int              10h

                       ADD              sendCursorX , 1

                       CMP              sendCursorX  , 79
                       jne              startSending
                       CMP              sendCursorY  ,10
                       jne              enter
                       ScrollYSend
                  
                       mov              sendCursorX , 0
                       jmp              startSending

    enter:             
                       CMP              sendCursorY  ,10
                       jne              normalEnter2
                       ScrollYSend
                       jmp              startSending

    normalEnter2:      
                       mov              sendCursorX , 5
                       add              sendCursorY , 1

    startSending:      
                       mov              ah,2
                       mov              dl , sendCursorX
                       mov              dh ,  sendCursorY
                       int              10h
            

                       MOV              DX , 03F8H
                       MOV              AL , SendedChar
                       OUT              DX , AL

    EndSending:        
                       RET
SendChar ENDP

    ;description
DrawSeparationLine MACRO height
                        local DrawSepLine
    ;Setting the cursor to draw the separaion line
                       mov              ah,2
                       mov              dl , SepLineCursorX
                       mov              dh ,  height
                       int              10h
    ;Drawing the separaion lines
                       MOV              CX , 80
    DrawSepLine:       
                       PUSH             CX
                       mov              al , 2DH
                       mov              cx , 1
                       mov              ah, 9
                       mov              bl , 06h
                       int              10h

                       INC              SepLineCursorX

                       mov              ah,2
                       mov              dl , SepLineCursorX
                       mov              dh ,  height
                       int              10h
                       POP              CX
                       loop             DrawSepLine
ENDM

MAIN PROC FAR

                       MOV              AX , @DATA
                       MOV              DS , AX

                       CALL             configuration
    ;Clear Screen
                       MOV              AX , 3
                       INT              10H
    ;text mode
                       MOV              AX , 0B800H
                       MOV              ES , AX

                       DrawSeparationLine 11
                       DrawSeparationLine 22
    ;Setting cursor with sending position
                       mov              ah,2
                       mov              dl , sendCursorX
                       mov              dh ,  sendCursorY
                       int              10h

    MainLoop:          
                       MOV              DX , 3FDH
                       IN               AL , DX
                       AND              AL , 1
                       JZ               Send
                       CALL             RecieveChar
                       cmp              recievedChar , 27
                       JE               kill
            
    Send:              
                       MOV              DX , 3FDH
                       IN               AL , DX
                       AND              AL , 00100000B
                       JZ               cont
                       CALL             SendChar
                       cmp              sendedChar , 27
                       JE               kill
    cont:              
                       JMP              MainLoop

    kill:              
                       HLT
MAIN ENDP
END MAIN