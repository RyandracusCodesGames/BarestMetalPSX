#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# string.asm - A collection of common string utiltites
# typically provided as apart of a string.h libc implementation
#-----------------------------------------------------------
	
	.syntax asmpsx
	.arch psx 
	.text
	
# Function: VS_Strlen
# Purpose: Returns the length of an input string 
# a0: string
VS_Strlen:
	lbu a1, 0(a0)       ; c = *string;
	addiu a0, 1         ; string++; (Delay Slot)
	beqz a1, StrlenEnd  ; if(c == 0) { goto StrlenEnd; }
	move v0, zero       ; length = 0; (Delay Slot)
StrlenLoop:
	lbu a1, 0(a0)       ; c = *string;
	addiu a0, 1         ; string++; (Delay Slot);
	bnez a1, StrlenLoop ; if(c == 0) { goto StrlenLoop; } 
	addiu v0, 1         ; length++; (Delay Slot)
StrlenEnd:
	jr ra 
	nop
	
# Function: VS_Strcpy
# Purpose: Copies the contents of an input string into a destination string 
# a0: dest, a1: src 
VS_Strcpy:
	lbu a2, 0(a1)       ; c = *src;
	addiu a1, 1         ; src++; (Delay Slot)
	beqz a2, StrcpyEnd  ; if(c == 0) { goto StrcpyEnd; }
	sb a2, 0(a0)        ; *dest = c; (Delay Slot)
	addiu a0, 1         ; dest++;
StrcpyLoop:
	lbu a2, 0(a1)       ; c = *src;
	addiu a1, 1         ; src++; (Delay Slot);
	sb a2, 0(a0)        ; *dest = c;
	bnez a2, StrcpyLoop ; if(c != 0) { goto StrcpyLoop; } 
	addiu a0, 1         ; dest++; (Delay Slot)
StrcpyEnd:
	jr ra 
	nop
	
# Function: VS_Strncpy
# Purpose: Copies the contents of the first n characters of an input string into a destination string
# a0: dest, a1: src, a2: max_len
VS_Strncpy:
	blez a2, StrncpyEnd    ; if(max_len <= 0) { goto StrncpyEnd; }
	addu a3, a1, a2        ; max_src = src + max_len; (Delay Slot)
	lbu a2, 0(a1)          ; c = *src;
	addiu a1, 1            ; src++; (Delay Slot)
	sb a2, 0(a0)           ; *dest = c;
	beqz a1, StrncpyEnd    ; if(c == 0) { goto StrcpyEnd; }
	addiu a0, 1            ; dest++; (Delay Slot)
StrncpyLoop:
	beq a1, a3, StrncpyEnd ; if(src == max_src) { goto StrncpyEnd; }
	lbu a2, 0(a1)          ; c = *src; (Delay Slot)
	addiu a1, 1            ; src++; (Delay Slot);
	sb a2, 0(a0)           ; *dest = c;
	bnez a2, StrncpyLoop   ; if(c == 0) { goto StrcpyLoop; } 
	addiu a0, 1            ; dest++; (Delay Slot)
StrncpyEnd:
	jr ra 
	nop
	
# Function: VS_Strcmp
# Purpose: Compares the characters of two strings 
# a0: str1, a1: str2
VS_Strcmp:
	beq a0, a1, retzero ; if(str1 == str2) { goto retzero; }
	nop
strcmploop:
	lbu a2, 0(a0)       ; c1 = *str1;
	addiu a0, 1         ; str1++; (Delay Slot)
	beqz a2, retzero    ; if(c1 == 0) { goto retzero; }
	lbu a3, 0(a1)       ; c2 = *str2;
	addiu a1, 1         ; str2++; (Delay Slot)
	bne a2, a3, retcmp  ; if(c1 != c2) { goto retcmp; }
	nop
	bnez a3, strcmploop ; if(c2 != 0) { goto strcmploop; } 
	nop 
retzero:
	move v0, zero      ; return 0;
	jr ra  
	nop
retcmp:	
	sub v0, a2, a3     ; return c1 - c2;
	jr ra 
	nop
	
# Function: VS_Strncmp
# Purpose: Compares the first n characters of two strings 
# a0: str1, a1: str2, a2: max_len
VS_Strncmp:
	beq a0, a1, retnzero ; if(str1 == str2) { goto retnzero; }
	nop
strncmploop:
	blez a2, retnzero    ; if(max_len <= 0) { return retnzero; }
	lbu t0, 0(a0)        ; c1 = *str1; 
	addiu a0, 1          ; str1++; (Delay Slot)    
	lbu a3, 0(a1)        ; c2 = *str2;
	addiu a1, 1          ; str2++; (Delay Slot)
	bne t0, a3, retncmp  ; if(c1 != c2) { goto retncmp; }
	nop
	bnez t0, strncmploop ; if(c1 != 0) { goto strncmploop; } 
	subi a2, 1           ; max_len++; (Delay Slot) 
retnzero:
	move v0, zero        ; return 0;
	jr ra 
	nop
retncmp:
	sub v0, t0, a3      ; return c1 - c2;
	jr ra 
	nop
	
# Function: VS_Strchr
# Purpose: Searches for a character in a string and returns the pointer to the first occurence of the character
# a0: str, a1: ch
VS_Strchr:
	lbu a2, 0(a0)         ; c = *str;
	nop
	beqz a2, retchrzero   ; if(c == 0) { goto retchrzero; }
	move v0, a0           ; return str; (Delay Slot) 
	bne a2, a1, VS_Strchr ; if(c != ch) { goto VS_Strchr; } 
	addiu a0, 1           ; str++; (Delay Slot)
	jr ra 
	nop
retchrzero:
	move v0, zero         ; return 0;
	jr ra 
	nop
	
# Function: VS_Strrchr
# Purpose: Searches for a character starting from the end of a string and returns the pointer to the first occurence of the character
# a0: str, a1: ch
VS_Strrchr:
	lbu a2, 0(a0)          ; c = *str;
	addiu a0, 1            ; str++; (Delay Slot)
	beqz a2, retrchrzero   ; if(c == 0) { goto retrchrzero; }
	move v0, zero          ; length = 0; (Delay Slot)
rchrlenLoop:
	lbu a2, 0(a0)          ; c = *str;
	addiu a0, 1            ; str++; (Delay Slot);
	bnez a2, rchrlenLoop   ; if(c == 0) { goto rchrlenLoop; } 
	addiu v0, 1            ; length++; (Delay Slot)
vs_strrchr:
	subi a0, 1             ; str--; (Delay Slot)
	lbu a2, 0(a0)          ; c = *str;
	nop 
	beq a2, a1, retstr     ; if(c == ch) { goto retstr; } 
	nop
	bnez v0, vs_strrchr    ; if(length != 0) { goto vs_strrchr; }
	subi v0, 1             ; length--; (Delay Slot)
retrchrzero:
	move v0, zero          ; return 0;
	jr ra 
	nop
retstr:
	move v0, a0            ; return str; 
	jr ra
	nop
	
# Function: VS_Strcat 
# Purpose: Appends the contents of a source string to the end of a destination string
# a0: dest, a1: src 
VS_Strcat:
	move v0, a0
lenloop:
	lbu a2, 0(a0)          ; c = *dest;
	addiu a0, 1            ; dest++; (Delay Slot)
	bnez a2, lenloop       ; if(c != 0) { goto lenloop;}
	nop
	subi a0, 1             ; dest--;
catloop:
	lbu a2, 0(a1)          ; c = *src;
	addi a1, 1             ; src++; (Delay Slot)
	sb a2, 0(a0)           ; *dest = c;
	bnez a2, catloop       ; if(c != 0) { goto catloop; }
	addi a0, 1             ; dest++;
catend:
	sb zero, 0(a0)         ; *dest = '\0';
	jr ra     
	nop
	
# Function: VS_Strncat 
# Purpose: Appends the contents of the first n characters of a source string to the end of a destination string
# a0: dest, a1: src, a2: max_len
VS_Strncat:
	move v0, a0
nlenloop:
	lbu a3, 0(a0)          ; c = *dest;
	addiu a0, 1            ; dest++; (Delay Slot)
	bnez a3, nlenloop      ; if(c != 0) { goto nlenloop;}
	nop
	subi a0, 1             ; dest--;
catnloop:
	beqz a2, catnend       ; if(max_len == 0) { goto catnend; }
	lbu a3, 0(a1)          ; c = *src;
	addi a1, 1             ; src++; (Delay Slot)
	sb a3, 0(a0)           ; *dest = c;
	subi a2, 1             ; max_len--;
	bnez a3, catnloop      ; if(c != 0) { goto catnloop; }
	addi a0, 1             ; dest++;
catnend:
	sb zero, 0(a0)         ; *dest = '\0';
	jr ra     
	nop
	
# Function: VS_Strstr
# Purpose: Searches for a substring in a string and returns the pointer to the first occurence of substring
# a0: str, a1: substr 
VS_Strstr:
	move a2, a1           ; string = substr;
	lbu a3, 0(a2)         ; c = *string;
	addiu a2, 1           ; string++; (Delay Slot)
	beqz a3, retstrstr    ; if(c == 0) { goto retstrstr; }
	move v1, zero         ; length = 0; (Delay Slot)
strstrlen:
	lbu a3, 0(a2)         ; c = *string;
	addiu a2, 1           ; string++; (Delay Slot);
	bnez a3, strstrlen    ; if(c == 0) { goto StrlenLoop; } 
	addiu v1, 1           ; length++; (Delay Slot)
vs_strstr:
	lbu a2, 0(a0)         ; byte = *str;
	addiu a0, 1           ; str++; (Delay Slot)
	beqz a2, retstrzero   ; if(byte == 0) { goto retstrzero; } 
	move a3, a1           ; b = substr; (Delay Slot)
	move a2, a0           ; a = str;
	move t0, v1           ; len = length;
strstrloop:
	lbu t1, 0(a2)         ; byte1 = *a;
	addiu a2, 1           ; a++; (Delay Slot)
	lbu t2, 0(a3)         ; byte2 = *b;
	addiu a3, 1           ; b++; (Delay Slot)
	bne t1, t2, vs_strstr ; if(byte1 != byte2) { goto vs_strstr; }
	subi t0, 1            ; len--; (Delay Slot)
	bgtz t0, strstrloop   ; if(len > 0) { goto strstrloop; } 
	nop 
retstrstr:
	move v0, a0           ; return str;
	jr ra 
	nop
retstrzero:
	move v0, zero         ; return zero;
	jr ra 
	nop
	
# Function: VS_Sprintf
# Purpose: Formats a string with arguments
# a0: string, a1: fmt, a2: arg1, a3: arg1, 16(sp)...arg3-argN
VS_Sprintf:
	li t0, 37               ; percent = '%'; 
	sw a2, 8(sp)
	sw a3, 12(sp)
	lw v0, 16(sp)
	addiu s0, sp, 8         ; argptr = stack_ptr + 8;
sprintf_loop:
	lbu t1, 0(a1)           ; byte = *fmt;
	addiu a1, 1             ; fmt++; (Delay Slot)
	beqz t1, finish_sprintf ; if(!byte) { goto finish_sprintf; } 
	nop
	bne t1, t0, fmt_cpy     ; if(byte != percent) { goto fmt_cpy; }
	nop 
	lbu t1, 0(a1)           ; c = *fmt;
	li t2, $63              ; fmt_spec = 'c';
	beq t1, t2, vs_char     ; if(c == fmt_spec) { goto vs_char; }
	li t3, $73              ; fmt_spec = 's';
	beq t1, t3, vs_string   ; if(c == fmt_spec) { goto vs_string; }
	li t2, $69              ; fmt_spec = 'i';
	beq t1, t2, vs_int      ; if(c == fmt_spec) { goto vs_int; }
	li t3, $64              ; fmt_spec = 'd'
	beq t1, t3, vs_int      ; if(c == 'd') { goto vs_int; }
	li t2, 104              ; fmt_spec = 'h'
	beq t1, t2, vs_short    ; if(c == 'h') { goto vs_short; }
	nop
	sb zero, 0(a0)          ; *string = '\0';
	jr ra 
	nop
fmt_cpy:
	sb t1, 0(a0)            ; *string = byte;
	b sprintf_loop          ; goto sprintf_loop;
	addiu a0, 1             ; string++; (Delay Slot)
vs_char:
	lbu t1, 0(s0)           ; byte = *argptr;
	addiu s0, 4             ; argptr += 4 (Delay Slot) 
	sb t1, 0(a0)            ; *string = byte;
	addiu a1, 1             ; fmt++;
	b sprintf_loop          ; goto sprintf_loop;
	addiu a0, 1             ; string++; (Delay Slot)
vs_string:
	lw t1, 0(s0)            ; str = *argptr;
	addiu s0, 4             ; argptr += 4 (Delay Slot) 
	addiu a1, 1             ; fmt++;
sprintf_strcpy:
	lbu t2, 0(t1)           ; byte = *str;
	addiu t1, 1             ; str++; (Delay Slot)
	beqz t2, sprintf_loop   ; if(!byte) { goto sprintf_loop; } 
	nop  
	sb t2, 0(a0)            ; *string = byte;
	b sprintf_strcpy        ; goto sprintf_strcpy;
	addi a0, 1              ; string++; (Delay Slot) 
vs_short:
	lh t1, 0(s0)            ; int = *argptr;
	addiu s0, 4             ; argptr += 4; (Delay Slot)
	li t2, 0         		; digits = 0;
	bgez t1, InitDigits     ; if(int >= 0) { goto InitDigits; }
	nop
	b sprintf_abs           ; goto sprintf_abs;
	nop
vs_int:
	lw t1, 0(s0)            ; int = *argptr;
	addiu s0, 4             ; argptr += 4; (Delay Slot)
	li t2, 0         		; digits = 0;
	bgez t1, InitDigits     ; if(int >= 0) { goto InitDigits; }
	nop
sprintf_abs:
	li t3, 45                ; char = '-';
	sb t3, 0(a0)             ; *string = char;
	addi a0, 1               ; string++;
	sub t1, zero, t1         ; int = 0 - int;
InitDigits:
	li t3, 10        		 ; base = 10;
	move t4, t1        		 ; tempInt = int; 
CountNumDigits:
	divu t4, t3              ; tempInt /= base;
	mflo t4       
	addi t2, 1               ; digits++;
	bgtz t4, CountNumDigits  ; if(tempInt > 0) { goto CountNumDigits; }
	nop
	subi t5, t2, 1   		 ; tempDigits = digits - 1;
	move v0, a0              ; temp_buf = buf;
	addu v0, t5   		     ; buf += tempDigits;
ConvertIntLoop:         
	divu  t1, t3             ; result = int % base;
	mfhi  t4
	addi  t4, $30            ; result += $30;
	sb    t4, 0(v0)          ; *string = result;
	mflo  t1 
	addi a0, 1
	bgtz  t1, ConvertIntLoop ; if(int > 0) { goto ConvertIntLoop; }
	subiu v0, 1              ; string--; (Delay Slot)
	b sprintf_loop           ; goto sprintf_loop;
	addiu a1, 1              ; fmt++;
finish_sprintf:
	sb zero, 0(a0)           ; *string = '\0';
	jr ra 
	nop
	
	