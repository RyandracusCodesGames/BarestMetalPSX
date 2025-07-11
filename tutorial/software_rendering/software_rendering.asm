#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# Video Mode: 256x240 NTSC 16-BIT COLOR
#-----------------------------------------------------------

	.syntax asmpsx
	.arch psx
	.org $80010000
	.text
	
; IN ASMPSX SYNTAX, $ IS NOT THE PREFIX OF A REGISTER, BUT THE PREFIX OF A HEXADECIMAL NUMBER
; IN ORDER TO MAKE PROGRAM COMPATIBLE WITH ARMIPS, REPLACE ALL INSTANCES OF $ WITH 0x
; REPLACE ALL (#) COMMENTS WITH THE SEMI-COLON (;)
	
; PlayStation I/O Registers
VS_IO equ $1F800000          ; PlayStation's Base I/O Address For All Registers
VS_GP0 equ $1810             ; PlayStation's First GPU Control Register, Primarily For Drawing Commands and DMA transfers
VS_GP1 equ $1814             ; PlayStation's Second GPU Control Register, Primarily for Display Commands 

; vs_gp0 = (unsigned long*)(VS_IO + VS_GP0);
; vs_gp1 = (unsigned long*)(VS_IO + VS_GP1);

; PlayStation GPU Display Commands
VS_CMD_RESET_GPU equ $000000              ; Resets all The Rendering Attributes, Display Commands, and Clears the Command List of the GPU
VS_CMD_RESET_FIFO equ $1000000            ; Clears the GPU's Command List of All Incoming Commands 
VS_CMD_DISP_ENABLE equ $3000000           ; Enables the GPU to Display the Frame Buffer to the Screen
VS_CMD_DISP_DISABLE equ $3000001          ; Disables the GPU from Displaying the Frame Buffer to the Screen
VS_CMD_DMA_DIRECTION equ $4000000         ; Sets the Direction of a DMA Transfer, Off, CPUtoGPU, FIFO, or GPUtoCPU
VS_CMD_START_DISPLAY_AREA equ $4000000    ; Sest the X and Y Coordinate Pair of the Upper Left Display Address in VRAM 
VS_CMD_HORZ_RANGE equ $6000000            ; Specifies the On-Screen Horizontal Display Range
VS_CMD_VERT_RANGE equ $7000000            ; Specifies the On-Screen Vertical Display Range
VS_CMD_DISPLAY_MODE equ $8000000          ; Sets the Display Mode of the GPU

; Commands Are Sent by Writing Directly to the GPU controls registers
; ex: *vs_gp1 = VS_CMD_DISP_ENABLE;
; li t0, VS_IO
; li t1, VS_CMD_DISP_ENABLE
; sw t1, VS_GP1(t0)

; (X,Y) Coordinate Pairs Are Sent by Writing the Y-Coordinate to the Upper 16-bits of a Register and the X-Coordinate to the Lower 16-bits 
; ex: x = a0, y = a1, t1 = cmd
; li t0, VS_IO 
; sw t1, VS_GP0(t0)
; andi a0, a0, 0xFFFF 
; sll a1, a1, 16 
; addu a1, a1, a0 
; sw a1, VS_GP0(t0)

; PlayStation GPU1 Display Values
VS_HRANGE equ $C4E24E
VS_VRANGE equ $040010 
VS_HORZ_RES_256 equ 0 
VS_HORZ_RES_320 equ 1 
VS_NTSC equ 0 
VS_PAL equ 8
VS_BPP_15 equ 0
VS_BPP24 equ 16
VS_DISP_X1 equ 0 
VS_DISP_Y1 equ 0 
VS_DISP_X2 equ 256 
VS_DISP_Y2 equ 240
VS_OFFSET equ 0
VS_WIDTH equ 256 
VS_HEIGHT equ 240

; PlayStation Display Attributes
VS_CMD_DRAW_MODE equ $E1000000            ; Sets the Primary Drawing Settings for Graphics Primitives
VS_CMD_TEXTURE_WINDOW equ $E2000000       
VS_CMD_DISP_X1Y1 equ $E3000000            ; Sets the Top Left X and Y Coordinate Pair of the Display Area 
VS_CMD_DISP_X2Y2 equ $E4000000            ; Sets the Bottom Right X and Y Coordinate Pair of the Display Area
VS_CMD_DRAW_OFFSET equ $E5000000          ; Sets the Offset of the Previous X and Y Coordinate Pairs in VRAM 
VS_CMD_MASK_BIT equ $E6000000             ; Sets the settings for Semi-Transparency
VS_DMA_ADDR equ $1F8010F0

; PlayStation GPU0 Display Attributes
VS_DRAW_MODE equ $000508

; PlayStation Memory Transfer Commands 
VS_CMD_CLEAR_CACHE equ $010000            ; Clears the Cache of the GPU
VS_FILL_VRAM equ $2000000                 ; Fills a Rectangular Area in VRAM in a Monochrome Color
VS_CPU_TO_VRAM equ $A0000000              ; A Command to Send Data from Main Memory to VRAM 
VS_VRAM_TO_VRAM equ $80000000             ; A Command to Transfer Data from One Area of VRAM to Another Area of VRAM 
VS_GPU_DMA equ $10A0                      ; DMA Channel 2(GPU) Address for Transfering Image Data and Display Lists
VS_GPU_BCR equ $10A4                      ; DMA Block Control Register for Setting DMA Transfer Size
VS_GPU_CHCR equ $10A8                     ; DMA Channel Control Register for Setting Type of DMA Transfer(Read/Write)
VS_CMD_STAT_READY equ $4000000
VS_DMA_ENABLE equ $1000000
VS_CMD_FLUSH_CACHE equ $01000000 
VS_CMD_FILL_VRAM equ $02000000
VS_CMD_CPU_TO_VRAM equ $A0000000          ; A Command to Send Data from Main Memory to VRAM 
VS_CMD_DISABLE_DMA equ $04000000 
VS_CMD_ENABLE_DMA equ $04000002
; PlayStation Rasterization Commands 
VS_CMD_FILL_RECT equ $60000000                  ; Fills A Monochrome Rectangle to the Display Area 
VS_CMD_FILL_SEMI_TRANS_RECT equ $62000000       ; Fills A Monochrome Semi-Transparent Rectangle to the Display Area 
VS_CMD_FILL_1x1_RECT equ $68000000              ; Fills A Monochrome 1x1 Rectangle to the Display Area, aka, a pixel
VS_CMD_FILL_SEMI_TRANS_1x1_RECT equ $6A000000   ; Fills A Monochrome  Semi-Transparent 1x1 Rectangle to the Display Area, aka, a pixel 
VS_CMD_FILL_8x8_RECT equ $70000000              ; Fills A Monochrome 8x8 Rectangle to the Display Area 
VS_CMD_FILL_SEMI_TRANS_8x8_RECT equ $72000000   ; Fills A Monochrome Semi-Transparent 8x8 Rectangle to the Display Area
VS_CMD_FILL_16x16_RECT equ $78000000            ; Fills A Monochrome 16x16 Rectangle to the Display Area 
VS_CMD_FILL_SEMI_TRANS_16x16_RECT equ $7A000000 ; Fills A Monochrome Semi-Transparent 16x16 Rectangle to the Display Area 

VS_RED equ 0 
VS_GREEN equ 0 
VS_BLUE equ 0

InitGPU:	
	li t0, VS_IO                          ; vs_io_addr = (unsigned long*)VS_IO;
	sw zero, VS_GP1(t0)                   ; *vs_gp1 = VS_CMD_RESET_GPU;
	li t1, VS_CMD_DISP_ENABLE             ; vs_cmd = VS_CMD_DISP_ENABLE;
	sw t1, VS_GP1(t0)                     ; *vs_gp1 = vs_cmd;
	li t1, VS_CMD_DMA_DIRECTION           ; vs_cmd = VS_CMD_DMA_DIRECTION;
	sw t1, VS_GP1(t0)                     ; *vs_gp1 = vs_cmd;
	li t1, VS_CMD_DISPLAY_MODE            ; vs_cmd = VS_CMD_DISPLAY_MODE;
	addiu t1, VS_NTSC + VS_HORZ_RES_256   ; vs_cmd += VS_NTSC + VS_HORZ_RES_256;
	sw t1, VS_GP1(t0)                     ; *vs_gp1 = vs_cmd;
	li t1, VS_CMD_START_DISPLAY_AREA      ; vs_cmd = VS_CMD_START_DISPLAY_AREA;
	sw t1, VS_GP1(t0)                     ; *vs_gp1 = vs_cmd;
	li t5, VS_HRANGE                      ; vs_hrange = $C4E24E;
	li t6, VS_VRANGE                      ; vs_vrange = $040010;
	li t1, VS_CMD_HORZ_RANGE              ; vs_cmd = VS_CMD_HORZ_RANGE;
	addu t1, t1, t5                       ; vs_cmd += vs_hrange;
	sw t1, VS_GP1(t0)                     ; *vs_gp1 = vs_cmd;
	li t1, VS_CMD_VERT_RANGE              ; vs_cmd = VS_CMD_VERT_RANGE;
	addu t1, t1, t6                       ; vs_cmd += vs_vrange;
	sw t1, VS_GP1(t0)                     ; *vs_gp1 = vs_cmd_vertical_range;
	li t1, VS_CMD_DRAW_MODE               ; vs_cmd = VS_CMD_DRAW_MODE;
	addi t1, VS_DRAW_MODE                 ; vs_cmd += VS_DRAW_MODE;  
	sw t1, VS_GP0(t0)                     ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_TEXTURE_WINDOW          ; vs_cmd = VS_CMD_TEXTURE_WINDOW;
	sw t1, VS_GP0(t0)                     ; *vs_gp0 = vs_cmd;
	li t1, $E3000000                      ; vs_cmd = VS_CMD_DISP_X1Y1;
	li t2, VS_DISP_X1                     ; x1 = VS_DISP_X1;
	li t3, VS_DISP_Y1                     ; y1 = VS_DISP_Y1;
	andi t2, $3FF                         ; x1 &= $3FF;
	andi t3, $1FF                         ; y1 &= $1FF;
	sll t3, $0A                           ; y1 <<= 10;
	addu t3, t2                           ; y1 += x1;
	addu t1, t3                           ; vs_cmd += y1;
	sw t1, VS_GP0(t0)    				  ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_DISP_X2Y2               ; vs_cmd = VS_CMD_DISP_X2Y2;
	li t2, VS_DISP_X2                     ; x2 = VS_DISP_X2;
	li t3, VS_DISP_Y2                     ; y2 = VS_DISP_Y2;
	andi t2, $3FF                         ; x2 &= $3FF;
	andi t3, $1FF                         ; y2 &= $1FF;
	sll t3, $0A                           ; y2 <<= 10;
	addu t3, t2                           ; y2 += x2;
	addu t1, t3                           ; vs_cmd += y2;
	sw t1, VS_GP0(t0)                     ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_DRAW_OFFSET             ; vs_cmd = VS_CMD_DRAW_OFFSET;
	li t2, VS_DISP_X1                     ; x1 = VS_DISP_X1;
	li t3, VS_DISP_Y1                     ; y1 = VS_DISP_Y1;
	sll  t3, 11                           ; y1 <<= 11;
	addu t3, t2                           ; y1 += x;
	addu t1, t3                           ; vs_cmd += y;
	sw   t1, VS_GP0(t0)                   ; *gpu0 = vs_cmd;
	li t2, VS_DMA_ADDR                    ; dma_address = (unsigned long*)VS_DMA_ADDR;
	li t1, $300                           ; dma_priority = $300;
	sw t1, 0(t2)                          ; *dma_address = dma_priority;
	li t1, $800                           ; gpu_dma_enable = $800;
	sw t1, 0(t2)                          ; *dma_address = gpu_dma_enable;
	addi sp, -64
FillScreen:
	la a0, FrameBuffer                    ; dest = FrameBuffer;
	li a1, $4009                          ; color = 0x4009;
	li a2, VS_WIDTH*VS_HEIGHT             ; size = VS_WIDTH*VS_HEIGHT;
	jal VS_Memset16                       ; VS_Memset16(dest,color,size);
	nop
DrawRectangles:
	li a0, 128                            ; x = 128;
	li a1, 120                            ; y = 120;
	li a2, 64                             ; w = 64;
	li a3, 64                             ; h = 64;
	li t1, $7C00                          ; color = 0x7C00;
	sh t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop 
	li a0, 80                             ; x = 100;
	li a1, 140                            ; y = 120;
	li a2, 64                             ; w = 64;
	li a3, 64                             ; h = 64;
	li t1, $001F                          ; color = 0x001F;
	sh t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop
	li a0, 20                             ; x = 20;
	li a1, 20                             ; y = 20;
	li a2, 16                             ; width = 16;
	li a3, 16                             ; height = 16;
	li t1, $d5e                           ; color = 0xd5e;
	sh t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop 
	li a0, 40                             ; x = 400;
	li a1, 20                             ; y = 120;
	li a2, 16                             ; width = 16;
	li a3, 16                             ; height = 16;
	li t1, $1730                          ; color = 0x1730;
	sh t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop 
	li a0, 20                             ; x = 20;
	li a1, 40                             ; y = 40;
	li a2, 16                             ; width = 16;
	li a3, 16                             ; height = 16;
	li t1, $76a0                          ; color = 0x76a0;
	sh t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop 
	li a0, 40                             ; x = 40;
	li a1, 40                             ; y = 40;
	li a2, 16                             ; width = 16;
	li a3, 16                             ; height = 16;
	li t1, $6ff                           ; color = 0x6ff;
	sh t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop 
	li a0, 140                            ; x = 40;
	li a1, 40                             ; y = 40;
	li a2, 8                              ; width = 8;
	li a3, 8                              ; height = 8;
	li t1, $3e0                           ; color = 0x3e0;
	sh t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop 
DrawFrameBuffer:
	move a0, zero                         ; x1 = 0;
	move a1, zero                         ; y1 = 0;
	li a2, VS_WIDTH                       ; width = VS_WIDTH;
	li a3, VS_HEIGHT                      ; height = VS_HEIGHT;
	la t0, FrameBuffer                    ; data = FrameBuffer;
	sw t0, 16(sp)
	jal VS_DMAImageDataToVram             ; VS_DMAImageDataToVram(x1,y1,width,height,data);
	nop
main:
	b main 
	nop
	addi sp, 64
	
# Function: VS_FillRectangle
# Purpose: Draws a filled rectangle to the display area
# a0: x, a1: y, a2: w, a3: h, 16(sp): color
VS_FillRectangle:
	la t0, FrameBuffer        ; vid_mem = (unsigned short*)FrameBuffer;
	lhu t1, 16(sp)
	addu t2, a0, a2           ; rect_x2 = x + w;
	addu t3, a1, a3           ; rect_y2 = y + h;
	li t6, VS_WIDTH
draw_column:
	move t4, a0               ; rect_x1 = x;
draw_row:
	mult a1, t6               ; offset = y * screen_width;
	mflo t5 
	addu t5, t4               ; offset += x;
	sll t5, 1                 ; offset <<= 1;
	addu t5, t0, t5           ; vid_offset = vid_mem + offset;
	addiu t4, 1               ; rect_x1++;
	bne t4, t2, draw_row      ; if(rect_x1 != rect_x2) { goto draw_row; } 
	sh t1, 0(t5)              ; *vid_offset = color; (Delay Slot)
	addiu a1, 1               ; rect_y1++;
	bne a1, t3, draw_column   ; if(rect_y1 != rect_y2) { goto draw_column; }
	nop
	jr ra 
	nop
	
# Function: VS_DMAImageDataToVram
# Purpose: Peforms a DMA transfer of word-aligned data by the CPU from main memory to VRAM 
# a0: x, a1: y, a2: width, a3: height, 16(sp): data
VS_DMAImageDataToVram:
	li t0, VS_IO                ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_DISABLE_DMA   ; vs_cmd = VS_CMD_DISABLE_DMA;
	sw t1, VS_GP1(t0)           ; *vs_gp1 = vs_cmd;
	li t1, VS_CMD_CLEAR_CACHE   ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_CPU_TO_VRAM   ; vs_cmd = VS_CMD_CPU_TO_VRAM;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF              ; x &= 0xFFFF;
	sll a1, 16                  ; y <<= 16;
	addu a1, a0                 ; y += x;
	sw a1, VS_GP0(t0)           ; *vs_gp0 = y;
	andi a0, a2, $FFFF          ; width &= 0xFFFF; 
	sll a1, a3, 16              ; height <<= 16;
	addu a1, a0                 ; height += width;
	sw a1, VS_GP0(t0)           ; *vs_gp0 = height;
	li a0, VS_CMD_ENABLE_DMA    ; vs_cmd = VS_CMD_ENABLE_DMA;
	sw a0, VS_GP1(t0)           ; *vs_gp1 = vs_cmd;
	mult a2, a3                 
	mflo a0                     ; size = width*height;
	lw a1, 16(sp)
	sra a0, 1                   ; size /= 2;
	sw a1, VS_GPU_DMA(t0)       ; *vs_gpu_dma = data;
	li a1, $10                  ; dma_size = 16;     
	blt a0, a1, CompleteDMA     ; if(size < dma_size) { goto CompleteDMA; }
	nop                  
vs_align:
	andi t1, a0, $f           
	bnez t1, CompleteDMA        ; if(!(size % 16)) { goto CompleteDMA; }
	nop
vs_align_size:
	addiu a0, 15                ; size += 15;
CompleteDMA:
	sra a0, a0, 4               ; size /= 16;
	sll a0, a0, 16              ; size <<= 16;
	ori a0, a0, 16    	        ; size |= 16;
	sw a0, VS_GPU_BCR(t0)       ; *gpu_bcr = size;
	li t2, $01000201   	        ; mode = write_mode;
	sw t2, VS_GPU_CHCR(t0)      ; *gpu_chcr = mode;
WaitDMA:
	lw a1, VS_GPU_CHCR(t0)      ; dma = *vs_gpu_chchr;
	li a2, VS_DMA_ENABLE        ; cmd = VS_DMA_ENABLE; (delay slot)
	and a1, a1, a2              ; dma &= cmd;
	bnez a1, WaitDMA            ; if(dma) { goto WaitDMA; }
	nop 
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
	
.data 
FrameBuffer:
	.empty, VS_WIDTH*VS_HEIGHT*2