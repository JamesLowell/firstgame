
    .model small
    .stack 100h
    .data
        cr      db 13,10, '$'
        msg     db 10,13,10,13, '              **  pick one: bato(1), papel(2), gunting(3)  ** $',0
        pl1     db 10,13, '              player 1: $', 0
        pl2     db '              player 2: $', 0
        pl1_win db 10,13,10,13,'                         !!! Player 1 is the Winner !!!                       $',10,13
        pl2_win db 10,13,10,13,'                         !!! Player 2 is the Winner !!!                       $',10,13
        pleq    db 10,13,'                     !!! Waw! it is a draw !!!                            $', 0
        m1      db 10,13,10,13, '              **       Welcome to Bato Bato Pik!          **$',10,13
        b1      db 10,13,10,13, '              ***********************************************$',10,13
        b2      db 10,13,10,13, '              **                                           **$',10,13
        chose   db 10,13, 'Pumili ng Laro $'
        chose1  db 10,13, 'Bato Bato Pik (1) Guess the Number (2)$'
            
        dseg    segment 'data'

        welcome db 10,13,10,13, '              **       Welcome to Guess The Number          **$',10,13
        prompt  db 10, 13, 'Please enter a number between 0 and 99 : $'
        greater db 10,13, 'It is to high, try to lower the number! $'
        smaller db 10,13, 'It is to low, try to higher the number! $'
        equal   db 10,13, 'Nice one baby! You guessed the number. Number of guesses: $'
        play    db 10,13, 'Wanna play more? Yes(y), No(n): $'
        newline:
	            db      13,10
	            db	'$'
        counter:
	            db	1 dup(?)
	            db	'$'		

        dseg    ends

        sseg    segment stack   'stack'
        dw      100h    dup(?)
        sseg    ends

        cseg    segment 'code'    
           
    begin:   
            mov ax, @data
            mov ds, ax
            mov es, ax       
    	    
    	    mov ax,0b800h
            mov es,ax        ; set es to text video memory segment
            mov si,4000      ; 2000 2-byte cells on an 80x25 display
        
    l1:     mov byte ptr es:[si-1],03fh                     ; set attribute to 1f (1=blue background, f=white foreground)
            sub si,2         ; go to next attribute(backwards)
            jg  l1           ; loop for entire display
            start1:
            mov dx, offset chose     
            mov ah, 09h
            int 21h
            
            mov dx, offset chose1      
            mov ah, 09h
            int 21h
           
            mov ah,08               
            int 21h                 
            mov ah,02               
            mov bl,al               
            mov dl,al              
            int 21h
            
            
            cmp bl, '1'
            je  bbp
            
            
            cmp bl, '2'
            je  gg  
            
    gg:     
                    start   proc    far
        
        ; store return address to os:
            push    ds
            mov     ax, 0
            push    ax
        
        ; set segment registers:
            mov     ax, dseg
            mov     ds, ax
            mov     es, ax
        
        
        
    main:               ;display welcome screen
            call    linenew
            call    linenew
            call    reset    
           
                        ;get random number using system clock   	
            mov     dx,offset welcome		
            call    writestring			; call function to write it to screen
            call    linenew			; call function to write newline to screen
            mov	    ah,00h	  		; call the system time function (bios)
            int	    1ah		  		
            mov	    al,01011110b  		; take the recieved time value and remove the 128 and 32 bits
            and	    al,dl	  		; to make sure the value is less than 99 (actually 95)
            mov	    ch,al			; move the random value 
           
                        ;display get number prompt and get number from keyboard
    again:
            
            mov     dx,offset prompt		; load the prompt string
            call    writestring			; call function to write string to screen
            call    readkey			; call function to read character from keyboard
            sub	    al,30h			; convert asci value to number (-30h or -48)
            push    ax				; save the entered number to temp area
            call    readkey			;
            cmp     al,13			;
            je	    skipchar2			;
            sub	    al,30h			; convert asci value to number
            mov     cl,al			; move the received value
            pop	    ax				;
            mov	    bl,10
            mul     bl				; save the value as a tens number
            add	    cl,al			; add the values together to get full number
            jmp	    carryon
            	
    skipchar2:
            pop     ax				; move temp value back
            mov	    cl,al			; save the value to the register for entered value
            
                                    ;compare random number to entered number
    carryon:
            mov	    bx,offset counter		; load up the counter address
            mov	    dl,[bx]			; load counter value
            inc	    dl				; add 1 to counter
            mov     [bx],dl			; load counter back to memory
            call    linenew			; call function to write newline to screen
            cmp     cl,ch			; compare the random number to entered number
            jg	    great			; if the entered number is greater then display greater message
            jl      small			; if the entered number is smaller then display smaller message
            mov	    dx,offset equal		; if the entered number is equal then display equal message
            call    writestring
            mov     dx,offset counter		;
            call    writestring			;
            jmp     whatnow			; what now heh?
        
    greats:
            call great
    smalls:    
            call small
        
    whatnow:
            call    linenew
            mov     dx,offset play				; does the user want to try again?
            call    writestring                                 ;
            call    readkey					;
            cmp	    al,'y'					; check if input is y for yes						
            jz	    main					; if the result is true zflag=1, therefore do program over
            cmp	    al,'y'					; check if input is y for yes						
            jz	    main
            cmp	    al,'n'					; check if input is n for no						
            jz	    exit					; if the result is true zflag=1, therefore exit program 
            cmp	    al,'n'					; check if input is n for no						
            jz	    exit					; if the result is true zflag=1, therefore exit program 	
        
        ;=-=-=-=-=-=-=-=-=-=-=-=-=-terminate program-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    exit:
            mov	    ah, 4ch			; call dos function to terminate program using		 
            int	    21h				; interrupt 21h
        
        
    start   endp
        
        ;-=-=-=-=-=-=-=-=-=-=-=-=-=-read character from keyboard =-=-=-=-=-=-=-=-=-=-=-=-=-=-=    	
    readkey proc
        
            mov	    ah,01h			; call the dos function to write a char string	
            int	    21h				; to the screen using interupt 21h
            ret
            
    readkey endp
            
        ;-=-=-=-=-=-=-=-=-=-=-=-=-=-write string to screen function-=-=-=-=-=-=-=-=-=-=-=-=-=-=    	
    writestring proc
        
            mov	    ah,09h			; call the dos function to write a char string	
            int	    21h				; to the screen using interupt 21h
            ret
            
    writestring endp
        
        ;-=-=-=-=-=-=-=-=-=-=-=-=-=-write new line to screen function-=-=-=-=-=-=-=-=-=-=-=-=-=-=    	
        
    linenew proc
        
            mov	    dx,offset newline
            mov	    ah,09h			; call the dos function to write a char string	
            int	    21h				; to the screen using interupt 21h
            ret
            
    linenew endp
        
          
        ;-=-=-=-=-=-=-=-=-=-=-=-=-=-reset the number of guesses counter-=-=-=-=-=-=-=-=-=-=-=-=-=-=    	
        
    reset proc
        
            mov	    bx,offset counter		; load counter variable
            mov     [bx],48			; load number 1 into variable
            ret
            
    reset endp
        
        ;-=-=-=-=-=-=-=-=-=-=-=-=-=-reset the number of guesses counter-=-=-=-=-=-=-=-=-=-=-=-=-=-=    	
        
    great proc
            
            mov	    dx,offset greater
            call    writestring
            call    linenew			; call function to write newline to screen
            jmp	    again	
            ret	  
            
    great endp
        
        ;-=-=-=-=-=-=-=-=-=-=-=-=-=-reset the number of guesses counter-=-=-=-=-=-=-=-=-=-=-=-=-=-=    	
        
    small proc
        
            mov	    dx,offset smaller
            call    writestring
            call    linenew			; call function to write newline to screen
            jmp	    again		    
            ret    
            
    small endp
        
        
        ; return to operating system:
            ret
        
        
        ;*******************************************
        
    cseg    ends 

            
    bbp:
            mov dx, offset b1     
            mov ah, 09h
            int 21h
            
            mov dx, offset m1     
            mov ah, 09h
            int 21h
            
            mov dx, offset b2     
            mov ah, 09h
            int 21h
            
            mov dx, offset msg      ; game instruction
            mov ah, 09h
            int 21h
            mov ah, 09h
      
            
            mov dx, offset b1     
            mov ah, 09h
            int 21h
            
              
            mov dx, offset cr     
            mov ah, 09h
            int 21h
            
            mov dx, offset pl1      
            mov ah, 09h
            int 21h
            
            mov ah,08               
            int 21h                 
            mov ah,02               
            mov bl,al               
            mov dl,al              
            int 21h
            
            mov dx, offset cr       
            mov ah, 09h
            int 21h
            
            mov dx, offset pl2     
            mov ah, 09h
            int 21h
            
            mov ah,08               
            int 21h                        
            mov ah,02                 
            mov bh,al                
            mov dl,al              
            int 21h
    
            mov dx, offset cr       
            mov ah, 09h      
            int 21h 
            
            mov cx, 1000
            mov bl, 70
            int 10h 
            mov ah, 09
            mov dx, 130
            int 21h
            int 20h
            
            cmp bl, bh
            je  eql    
            
            cmp bl, '1'
            je  eq1   
            cmp bl, '2'
            je  eq2
            cmp bl, '3'
            je  eq3
            
        eq1:
            cmp bh, '2'
            je  p2_win   
            cmp bh, '3'
            je  p1_win   
    
        eq2:  
            cmp bh, '1'
            je  p1_win   
            cmp bh, '3'
            je  p2_win 
     
        eq3:  
            cmp bh, '1'
            je  p2_win   
            cmp bh, '2'
            je  p1_win 
           
        p1_win:                     ;player 1 is winner
            mov dx, offset pl1_win     
            mov ah, 09h
            int 21h
            jmp final
          
        eql:                      ;player 1 == player 2
            mov dx, offset pleq   
            mov ah, 09h
            int 21h
            jmp final
            
        p2_win:                     ;player 2 is winner
            mov dx, offset pl2_win     
            mov ah, 09h
            int 21h
            jmp final
       
        final:
            
            je start1
            
    end begin 
    
