#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# decompression.asm - A couple common decompression routines
# (LZ77, LZSS, and RLE)
#-----------------------------------------------------------
	.syntax asmpsx 
	.arch psx
	.text

# Function: VS_DecompressLZSS
# Purpose: Decompresses a LZSS compressed bitstream
# a0: dest, a1: src, a2: size
VS_DecompressLZSS:
	addu a2, a0, a2                       ; end = dest + size;
	li t0, 0                              ; flag_num = 0; 
LoadLZSSFlag:
	lbu t1, 0(a1)                         ; byte = *src;
	li t0, 8                              ; flag_num = 8; (Delay Slot)
	addiu a1, 1                           ; src++;
LZSSLoop:
	bge  a0, a2, lzss_end                 ; if(dest >= end) { goto lzss_end; } 
	nop
	beqz t0, LoadLZSSFlag                 ; if(flag_num == 0) { goto LoadLZSSFlag; } 
	andi t2, t1, $80                      ; num = byte & 0x80; (Delay Slot)
	bnez t2, LoadByte                     ; if(num) { goto LoadByte; }
	nop
	lbu t2, 0(a1)                         ; lsb = *src;
	lbu t3, 1(a1)                         ; msb = *(src + 1);
	addiu a1, 2                           ; src += 2; (Delay Slot)
	sll t3, 8                             ; msb <= 8;
	or t3, t2                             ; hword = msb | lsb;
	sra t4, t3, 4                         ; offset = hword >> 4;
	andi t5, t3, 15                       ; length = hword & 15;
	subu t6, a0, t4                       ; src_cpy = dest - offset;
LZSSCopy:
	lbu t7, 0(t6)                         ; cbyte = *src_cpy;
	addiu t6, 1                           ; src_cpy++; (Delay Slot) 
	sb t7, 0(a0)                          ; *dest = cbyte;
	subiu t5, 1                           ; length--;
	bgtz t5, LZSSCopy                     ; if(length > 0) { goto LZSSCopy; }
	addiu a0, 1                           ; dest++; (Delay Slot)
	subiu t0, 1                           ; flag_num--;
	sll t1, 1                             ; byte <<= 1;
	b LZSSLoop                            ; goto LZSSLoop;
	nop
LoadByte:
	lbu t2, 0(a1)                         ; cbyte = *src;
	addiu a1, 1                           ; src++; (Delay Slot)
	sb t2, 0(a0)                          ; *dest = *cbyte;
	subiu t0, 1                           ; flag_num--;
	sll t1, 1                             ; byte <<= 1;
	b LZSSLoop                            ; goto LZSSLoop;
	addiu a0, 1                           ; dest++; (Delay Slot)
lzss_end:
	jr ra 
	nop

# Function: VS_DecompressRLE
# Purpose: Decompresses a run-length encoded bytestream
# a0: dest, a1: src, a2: size 
VS_DecompressRLE:
	move v0, zero          ; len = 0;
RLELoop:
	bge v0, a2, rle_end    ; if(len >= size) { goto rle_end; }
	lbu a3, 0(a1)          ; byte = *src;
	addiu a1, 1            ; src++; (Delay Slot)
	andi t0, a3, $80       ; runbit = byte & 128;
	bnez t0, unpackrun     ; if(runbit) { goto unpackrun; }
	andi t1, a3, $7F       ; length = byte & 0x7F; (Delay Slot)
copybyteloop:
	lbu t0, 0(a1)          ; byte = *src;
	addiu a1, 1            ; src++; (Delay Slot)
	sb t0, 0(a0)           ; *dest = byte;
	addiu v0, 1            ; len++;
	subi t1, 1             ; length--;
	bgtz t1, copybyteloop  ; if(length > 0) { goto copybyteloop; }
	addiu a0, 1            ; dest++; (Delay Slot)
	b RLELoop
	nop
unpackrun:
	lbu t0, 0(a1)          ; byte = *src;
	addiu a1, 1            ; src++; (Delay Slot)
unpackrunloop:
	sb t0, 0(a0)           ; *dest = byte;
	subi t1, 1             ; length--;
	addiu v0, 1            ; len++;
	bgtz t1, unpackrunloop ; if(length > 0) { goto unpackrunloop; }
	addiu a0, 1            ; dest++; (Delay Slot)
	b RLELoop
	nop
rle_end:
	jr ra 
	nop