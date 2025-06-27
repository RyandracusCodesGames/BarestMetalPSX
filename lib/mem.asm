#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# mem.asm - A collection of common memory manipulation and 
# memory mangement functions
#-----------------------------------------------------------
	.syntax asmpsx
	.arch psx 
	.text
	
# Function: VS_Memset
# Purpose: An optimized implementation of memset inspired from the Atari Jaguar port of Doom
# Ref: https://github.com/JNechaevsky/jaguar-doom/blob/5ab926c33f7769a9db0a91e7628960c9400ecdbb/d_main.c#L41
# a0: dest, a1: src, a2: size
VS_Memset:
	li t0, 32                 ; min_size = 32;
	ble a2, t0, small_memset  ; if(size <= min_size) { goto small_memset; }
	andi a3, a0, 3            ; word_align = dest & 3;
	beqz a3, setup_word_chunk ; if(word_align) { goto setup_word_chunk; }
	nop
align_word:
	sb a1, 0(a0)              ; *dest = src;
	subi a2, 1                ; size--;
	addi a0, 1                ; dest++;
	andi a3, a0, 3            ; word_align = dest & 3;
	bnez a3, align_word       ; if(word_align) { goto align_word; }
	nop
setup_word_chunk:
	sll t0, a1, 24            ; msb1 = src << 24;
	sll t1, a1, 16            ; msb2 = src << 16;
	sll t2, a1, 8             ; lsb1 = src << 8;
	or t0, t0, t1             ; msb1 |= msb2;
	or t0, t0, t2             ; msb |= lsb1;
	or t0, t0, a1             ; word = msb | src;
	li t1, 32                 ; min_size = 32;
memset_word:
	blt a2, t1, small_memset  ; if(size < min_size) { goto small_memset; } 
	nop 
	sw t0, 0(a0)              ; dest[0] = word;
	sw t0, 4(a0)              ; dest[1] = word;
	sw t0, 8(a0)              ; dest[2] = word;
	sw t0, 12(a0)             ; dest[3] = word;
	sw t0, 16(a0)             ; dest[4] = word;
	sw t0, 20(a0)             ; dest[5] = word;
	sw t0, 24(a0)             ; dest[6] = word;
	sw t0, 28(a0)             ; dest[7] = word;
	subiu a2, 32              ; size -= 32;
	b memset_word             ; goto memset_word;
	addi a0, 32               ; dest += 32; (Delay Slot)
small_memset:
	sb a1, 0(a0)              ; *dest = src;
	subi a2, 1                ; size--;
	bgtz a2, small_memset     ; if(size > 0) { goto small_memset; } 
	addi a0, 1                ; dest++; (Delay Slot)
return_memset:
	jr ra 
	nop
	
# Function: VS_Memset16
# Purpose: An optimized implementation of memset for 16-bit integers inspired from the Atari Jaguar port of Doom
# Ref: https://github.com/JNechaevsky/jaguar-doom/blob/5ab926c33f7769a9db0a91e7628960c9400ecdbb/d_main.c#L41
# a0: dest, a1: src, a2: size
VS_Memset16:
	li t0, 32                    ; min_size = 32;
	ble a2, t0, small_memset_16  ; if(size <= min_size) { goto small_memset; }
	andi a3, a0, 3               ; word_align = dest & 3;
	beqz a3, setup_word_chunk_16 ; if(word_align) { goto setup_word_chunk; }
	nop
align_word_16:
	sh a1, 0(a0)                 ; *dest = src;
	subi a2, 1                   ; size--;
	addi a0, 2                   ; dest += 2;
	andi a3, a0, 3               ; word_align = dest & 3;
	bnez a3, align_word_16       ; if(word_align) { goto align_word; }
	nop
setup_word_chunk_16:
	sll t0, a1, 16               ; msb1 = src << 16;
	or t0, t0, a1                ; word = msb | src;
	li t1, 32                    ; min_size = 32;
memset_word_16:
	blt a2, t1, small_memset_16  ; if(size < min_size) { goto small_memset; } 
	nop 
	sw t0, 0(a0)                 ; dest[0] = word;
	sw t0, 4(a0)                 ; dest[1] = word;
	sw t0, 8(a0)                 ; dest[2] = word;
	sw t0, 12(a0)                ; dest[3] = word;
	sw t0, 16(a0)                ; dest[4] = word;
	sw t0, 20(a0)                ; dest[5] = word;
	sw t0, 24(a0)                ; dest[6] = word;
	sw t0, 28(a0)                ; dest[7] = word;
	subiu a2, 16                 ; size -= 16;
	b memset_word_16             ; goto memset_word_16;
	addi a0, 32                  ; dest += 32; (Delay Slot)
small_memset_16:
	sh a1, 0(a0)                 ; *dest = src;
	subi a2, 1                   ; size--;
	bgtz a2, small_memset_16     ; if(size > 0) { goto small_memset; } 
	addi a0, 2                   ; dest += 2; (Delay Slot)
return_memset_16:
	jr ra 
	nop
	
# Function: VS_Memcpy
# Purpose: An optimized implementation of the standard C library's memcpy function 
# a0: dest, a1: src, a2: size 
VS_Memcpy:
	blez a2, memcpy_end       ; if(size >= 0) { goto memcpy_end;}
	li t0, 32                 ; min_size = 32;
	ble a2, t0, small_memcpy  ; if(size <= min_size) { goto small_memcpy; }
	andi a3, a0, 1            ; hword_align_dest = dest & 1;
	bnez a3, small_memcpy     ; if(hword_align_dest) { goto small_memcpy; }
	andi t1, a1, 1            ; hword_align_src = src & 1;
	bnez t1, small_memcpy     ; if(hword_align_src) { goto small_memcpy; }
	andi a3, a0, 3            ; word_align_dest = dest & 3;
	bnez a3, prep_memcpy_16   ; if(word_align_dest) { goto prep_memcpy_16; }
	andi t1, a1, 3            ; word_align_src = src & 3;
	bnez t1, prep_memcpy_16   ; if(word_align_src) { goto prep_memcpy_16; }
	nop 					
memcpy_32:                    ; source = (unsigned long*)src; destination = (unsigned long*)dest;
	lw t1, 0(a1)              ; word1 = source[0];
	lw t2, 4(a1)              ; word2 = source[1];
	lw t3, 8(a1)              ; word3 = source[2];
	lw t4, 12(a1)             ; word5 = source[3];
	lw t5, 16(a1)             ; word6 = source[4];
	lw t6, 20(a1)             ; word7 = source[5];
	lw t7, 24(a1)             ; word8 = source[6];
	lw t8, 28(a1)             ; word9 = source[7];
	addi a1, 32               ; src += 32;
	sw t1, 0(a0)              ; destination[0] = word1;
	sw t2, 4(a0)              ; destination[1] = word2;
	sw t3, 8(a0)              ; destination[2] = word3;
	sw t4, 12(a0)             ; destination[3] = word4;
	sw t5, 16(a0)             ; destination[4] = word5;
	sw t6, 20(a0)             ; destination[5] = word6;
	sw t7, 24(a0)             ; destination[6] = word7;
	sw t8, 28(a0)             ; destination[7] = word8;
	subi a2, 32               ; size -= 32;
	bge a2, t0, memcpy_32     ; if(size >= min_size) { goto memcpy_32; }
	addi a0, 32               ; dest += 32; (Delay Slot)
prep_memcpy_16:
	li t0, 4                  ; min_size = 4;
	ble a2, t0, small_memcpy  ; if(size <= min_size) { goto small_memcpy; }
	nop
memcpy_16:
	lhu t1, 0(a1)             ; hword = *src; (Delay Slot)
	addiu a1, 2               ; src += 2;
	sh t1, 0(a0)              ; *dest = hword;
	lhu t1, 0(a1)             ; hword = *src; (Delay Slot)
	addiu a1, 2               ; src += 2;
	sh t1, 2(a0)              ; *dest = hword;
	subiu a2, 4               ; size -= 4;
	bge a2, t0, memcpy_16     ; if(size >= min_size) { goto memcpy_16; }
	addiu a0, 4               ; dest += 2; (Delay Slot)
small_memcpy:
	lbu t1, 0(a1)             ; byte = *src;
	addiu a1, 1               ; src++; (Delay Slot)
	sb t1, 0(a0)              ; *dest = byte;
	subiu a2, 1               ; size--;
	bgtz a2, small_memcpy     ; if(size > 0) { goto small_memcpy; }
	addiu a0, 1               ; dest++; (Delay Slot)
memcpy_end:
	jr ra 
	nop
	
# Function: VS_Memcmp
# Purpose: Compares two blocks of memory 
# a0: mem1, a1: mem2, a2: size
VS_Memcmp:
	lbu a3, 0(a0)         ; byte1 = *mem1;
	addiu a0, 1           ; mem1++; (Delay Slot)
	lbu t0, 0(a1)         ; byte2 = *mem2;
	addiu a1, 1           ; mem2++; (Delay Slot)
	bne a3, t0, retmemcmp ; if(byte1 != byte2) { goto retmemcmp; }
	nop
	bgtz a2, VS_Memcmp    ; if(size > 0) { goto VS_Memcmp; } 
	nop 
retmemzero:
	move v0, zero         ; return 0;
	jr ra  
	nop
retmemcmp:	
	sub v0, a2, a3        ; return c1 - c2;
	jr ra 
	nop
	
# Function: VS_Memccpy
# Purpose: Copies the contents of the source address of memory into the destination until size bytes are copied or the character 'ch' is found 
# a0: dest, a1: src, a2: ch, a3: size
VS_Memccpy:
	lbu t0, 0(a1);       ; byte = *src;
	addiu a1, 1          ; src++; (Delay Slot)
	sb t0, 0(a0)         ; *dest = byte;
	beq t0, a2, retdest  ; if(byte == ch) { goto retdest; } 
	subi a3, 1           ; size--; (Delay Slot)
	bgtz a3, VS_Memccpy  ; if(size > 0) { goto VS_Memccpy; }
	addiu a0, 1          ; dest++; (Delay Slot) 
	move v0, zero        ; return 0;
	jr ra 
	nop
retdest:
	move v0, a0          ; return dest;
	jr ra 
	nop 
	
# Function: VS_Memchr
# Purpose: Searches for a byte in an area of memory and returns the pointer to the first occurence of the byte
# a0: src, a1: ch, a2: size
VS_Memchr:
	lbu a3, 0(a0)          ; byte = *src;
	addi a0, 1             ; src++; (Delay Slot)
	beq a3, a1, retmemchr  ; if(byte == ch) { goto retmemchr; }
	subi a2, 1             ; size--; (Delay Slot)
	bgtz a2, VS_Memchr     ; if(size > 0) { goto VS_Memchr; } 
	move v0, zero          ; return 0; (Delay Slot)
	jr ra 
	nop
retmemchr:
	move v0, a0           ; return src;
	jr ra 
	nop
	
# Function: VS_Memmove
# Purpose: Copies size bytes from the source area of memory into the destination area of memory
# a0: dest, a1: src, a2: size
VS_Memmove:
	beq a0, a1, retmovedest  ; if(dest == src) { goto retmovedest; }
	nop 
	blt a0, a1, copyforwards ; if(dest < src) { goto copyforwards; } 
	nop 
	addu a0, a2              ; dest += size;
	addu a1, a2              ; src += size;
copybackwards:
	lbu t0, 0(a1)            ; byte = *src;
	subiu a1, 1              ; src--; (Delay Slot) 
	subi a2, 1               ; size--;
	sb t0, 0(a0)             ; *dest = byte;
	bgtz a2, copyforwards    ; if(size > 0) { goto copyforwards; }
	subiu a0, 1              ; dest--; (Delay Slot)
	jr ra 
	nop
copyforwards:
	lbu t0, 0(a1)            ; byte = *src;
	addiu a1, 1              ; src++; (Delay Slot) 
	subi a2, 1               ; size--;
	sb t0, 0(a0)             ; *dest = byte;
	bgtz a2, copyforwards    ; if(size > 0) { goto copyforwards; }
	addiu a0, 1              ; dest++; (Delay Slot)
retmovedest:
	move v0, a0              ; return dest;
	jr ra 
	nop