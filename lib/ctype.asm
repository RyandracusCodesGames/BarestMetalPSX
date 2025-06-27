#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# ctype.asm - A collection of common character utiltites
# typically provided as apart of a ctype.h libc implementation
#-----------------------------------------------------------
	.syntax asmpsx
	.arch psx 
	.text 
	
# Function: VS_IsDigit
# Purpose: Returns 1 if the input character is a digit and 0 otherwise
# a0: digit
VS_IsDigit:
	li a1, 48              ; c = '0';
	blt a0, a1, not_digit  ; if(digit < c) { goto not_digit; }
	li a2, 57              ; c = '9';
	bgt a0, a2, not_digit  ; if(digit > c) { goto not_digit; }
	nop
	li v0, 1               ; return 1;
	jr ra
	nop
not_digit:
	move v0, zero          ; return 0;
	jr ra
	nop
	
# Function: VS_IsPrint
# Purpose: Returns 1 if the input character is a printable character and 0 otherwise
# a0: print 
VS_IsPrint:
	li a1, 32              ; c = ' ';
	blt a0, a1, not_print  ; if(print < c) { goto not_print; }
	li a2, 126             ; c = '~';
	bgt a0, a2, not_print  ; if(print > c) { goto not_print; }
	nop 
	li v0, 1               ; return 1;
	jr ra
	nop
not_print:
	move v0, zero          ; return 0;
	jr ra
	nop
	
# Function: VS_IsGraph
# Purpose: Returns 1 if the input character has graphical representation and 0 otherwise
# a0: graph 
VS_IsGraph:
	li a1, 32              ; c = ' ';
	ble a0, a1, not_graph  ; if(graph <= c) { goto not_graph; }
	li a2, 126              ; c = '~';
	bgt a0, a2, not_graph  ; if(graph > c) { goto not_graph; }
	nop 
	li v0, 1               ; return 1;
	jr ra
	nop
not_graph:
	move v0, zero          ; return 0;
	jr ra
	nop
	
# Function: VS_IsSpace
# Purpose: Returns 1 if the input character is white-space and 0 otherwise
# a0: space 
VS_IsSpace:
	li a1, 32             ; c = ' ';
	beq a0, a1, is_space  ; if(space == c) { goto is_space; }
	li a2, 9              ; c = '\t';
	blt a0, a2, not_space ; if(space < c) { goto not_space; }
	li a1, 13             ; c = '\r';
	bgt a0, a1, not_space ; if(space > c) { goto not_space; }
	nop
is_space:
	li v0, 1              ; return 1; (Delay Slot)
	jr ra 
	nop
not_space:
	move v0, zero         ; return 0;
	jr ra 
	nop
	
# Function: VS_IsBlank
# Purpose: Returns 1 if the input character is blank-space and 0 otherwise
# a0: blank 
VS_IsBlank:
	li a1, 32             ; c = ' ';
	beq a0, a1, is_space  ; if(blank == c) { goto is_blank; }
	li a2, 9              ; c = '\t';
	beq a0, a2, not_space ; if(blank == c) { goto is_blank; }
	nop 
	move v0, zero         ; return 0;
	jr ra 
	nop
is_blank:
	li v0, 1              ; return 1;
	jr ra 
	nop
	
# Function: VS_IsAlpha
# Purpose: Returns 1 if the input character is apart of the alphabet and 0 otherwise
# a0: alpha 
VS_IsAlpha:
	li a1, 65             ; c = 'A';
	bge a0, a1, upper     ; if(alpha >= c) { goto upper; }
	li a2, 97             ; c = 'a';
	blt a0, a2, not_alpha ; if(alpha < c) { goto not_alpha; }
	li a1, 122            ; c = 'z';
	bgt a0, a1, not_alpha ; if(alpha > c) { goto not_alpha; }
	nop 
	li v0, 1              ; return 1;
	jr ra 
	nop
upper:
	li a1, 90             ; c = 'Z';
	bgt a0, a1, not_alpha ; if(alpha > c) { goto upper; }
	nop
	li v0, 1              ; return 1;
	jr ra 
	nop
not_alpha:
	move v0, zero         ; return 0;
	jr ra
	nop
	
# Function: VS_IsCntrl
# Purpose: Returns 1 if the input character is a control character and 0 otherwise
# a0: cntrl 
VS_IsCntrl:
	li a1, $7f            ; c = 0x7f;
	beq a0, a1, cntrl     ; if(cntrl == c) { goto cntrl; }
	nop 
	li a2, $20            ; c = 0x20;
	blt a0, a2, cntrl     ; if(cntrl < c) { goto cntrl; }
	nop
	move v0, zero         ; return 0;
	jr ra
	nop
	
cntrl:
	li v0, 1              ; return 1;
	jr ra
	nop

# Function: VS_ToDigit
# Purpose: Converts an integer digit to the corresponding digit's ASCII character
# a0: digit 
VS_ToDigit:
	addi v0, a0, 48 ; return digit + 48;
	jr ra
	nop 
	
# Function: VS_ToLower
# Purpose: Returns the lowercase version of the input character if the input character is uppercase and alphabetic 
# a0: c 
VS_ToLower:
	li a1, 65             ; c = 'A';
	blt a0, a1, ret_char  ; if(alpha < c) { goto ret_char; }
	li a2, 90             ; c = 'Z';
	blt a0, a1, ret_char  ; if(alpha < c) { goto ret_char; }
	nop
	addiu v0, a0, 32      ; return c + 32;
	jr ra 
	nop
ret_char:
	move v0,a0            ; return c;
	jr ra 
	nop
	
# Function: VS_ToUpper
# Purpose: Returns the uppercase version of the input character if the input character is lowercase and alphabetic 
# a0: c 
VS_ToUpper:
	li a1, 97             ; c = 'a';
	blt a0, a1, ret_char  ; if(alpha < c) { goto ret_char; }
	li a2, 122            ; c = 'z';
	blt a0, a1, ret_char  ; if(alpha < c) { goto ret_char; }
	nop
	subiu v0, a0, 32      ; return c - 32;
	jr ra 
	nop
ret_up_char:
	move v0,a0            ; return c;
	jr ra 
	nop