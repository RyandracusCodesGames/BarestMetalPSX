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
VS_CMD_DISABLE_DMA equ $04000000 
; PlayStation GPU0 Display Attributes
VS_DRAW_MODE equ $000508

; PlayStation Memory Transfer Commands 
VS_CMD_CLEAR_CACHE equ $010000            ; Clears the Cache of the GPU
VS_FILL_VRAM equ $2000000                 ; Fills a Rectangular Area in VRAM in a Monochrome Color
VS_CMD_CPU_TO_VRAM equ $A0000000          ; A Command to Send Data from Main Memory to VRAM 
VS_VRAM_TO_VRAM equ $80000000             ; A Command to Transfer Data from One Area of VRAM to Another Area of VRAM 
VS_GPU_DMA equ $10A0                      ; DMA Channel 2(GPU) Address for Transfering Image Data and Display Lists
VS_GPU_BCR equ $10A4                      ; DMA Block Control Register for Setting DMA Transfer Size
VS_GPU_CHCR equ $10A8                     ; DMA Channel Control Register for Setting Type of DMA Transfer(Read/Write)
VS_CMD_STAT_READY equ $4000000
VS_DMA_ENABLE equ $1000000
VS_CMD_ENABLE_DMA equ $04000002
; PlayStation Rasterization Commands 
VS_CMD_TEXTURE_QUAD equ $2D000000         ; TEXTURES A FOUR-POINT POLYGON, A QUAD, TO THE DISPLAY AREA

VS_RED equ 0 
VS_GREEN equ 0 
VS_BLUE equ 0

VS_MANUAL_VRAM_X equ 256 
VS_MANUAL_VRAM_Y equ 256
VS_DMA_VRAM_X equ 384 
VS_DMA_VRAM_Y equ 256
VS_TEXTURE_W equ 64 
VS_TEXTURE_H equ 32
VS_MANUAL_PALETTE_VRAM_X equ 0 
VS_MANUAL_PALETTE_VRAM_Y equ 256 

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
UploadTextureToVram:
	li a0, VS_MANUAL_PALETTE_VRAM_X       ; vram_x = VS_MANUAL_PALETTE_VRAM_X;
	li a1, VS_MANUAL_PALETTE_VRAM_Y       ; vram_y = VS_MANUAL_PALETTE_VRAM_Y;
	li a2, 16                             ; size = 16;
	la a3, Palette                        ; data = Palette;
	jal VS_TransferPaletteDataToVram      ; VS_TransferPaletteDataToVram(vram_x,vram_y,size,data);
	nop
	li a0, VS_MANUAL_VRAM_X               ; vram_x = VS_MANUAL_VRAM_X;
	li a1, VS_MANUAL_VRAM_Y               ; vram_y = VS_MANUAL_VRAM_Y;
	li a2, VS_TEXTURE_W                   ; image_w = VS_TEXTURE_W;
	li a3, VS_TEXTURE_H                   ; image_h = VS_TEXTURE_H;
	la t1, Texture                        ; image = Texture;
	sw t1, 16(sp)
	jal VS_TransferFourBPPImageDataToVram ; VS_TransferFourBPPImageDataToVram(vram_x,vram_y,image_w,image_h,image);
	nop
	li a0, VS_DMA_VRAM_X                  ; vram_x = VS_DMA_VRAM_X;
	li a1, VS_DMA_VRAM_Y                  ; vram_y = VS_DMA_VRAM_Y;
	li a2, VS_TEXTURE_W                   ; image_w = VS_TEXTURE_W;
	li a3, VS_TEXTURE_H                   ; image_h = VS_TEXTURE_H;
	la t1, Texture                        ; image = Texture;
	sw t1, 16(sp)
	jal VS_DMAFourBPPImageDataToVram      ; VS_DMAFourBPPImageDataToVram(vram_x,vram_y,image_w,image_h,image);
	nop
FillScreen:
	li t0, VS_IO
	li t1, VS_FILL_VRAM                   ; vs_cmd = VS_FILL_VRAM;
	li t2, VS_BLUE                        ; blue = VS_BLUE;
	sll t2, $10                           ; blue <<= 16;
	li t3, VS_GREEN                       ; green = VS_GREEN;
	sll t3, $08                           ; green <<= 8;
	addu t2, t3                           ; blue += green;
	addiu t2, VS_RED                      ; blue += red;
	addu t1, t2                           ; vs_cmd += blue;
	sw t1, VS_GP0(t0)                     ; *vs_gp0 = vs_cmd;
	li t2, VS_DISP_X1                     ; x1 = VS_DISP_X1;
	li t3, VS_DISP_Y1                     ; y1 = VS_DISP_Y1;
	andi t2, $FFFF                        ; x1 &= $FFFF;
	sll t3, t3, $10                       ; y1 <<= 16;
	addu t3, t2                           ; y1 += x1;
	sw t3, VS_GP0(t0)                     ; *vs_gp0 = y1;
	li t2, VS_WIDTH                       ; x2 = VS_WIDTH;
	li t3, VS_HEIGHT                      ; y2 = VS_HEIGHT;
	andi t2, $FFFF                        ; x2 &= $FFFF;
	sll t3, t3, $10                       ; y2 <<= 16;
	addu t3, t2                           ; y2 += x2;
	sw t3, VS_GP0(t0)                     ; *vs_gp0 = y2;
DisplayTexture:
	li a0, 0                              ; mode = 0;
	li a1, 1                              ; alpha = 1;
	li a2, VS_MANUAL_VRAM_X               ; vram_x = VS_MANUAL_VRAM_X;
	li a3, VS_MANUAL_VRAM_Y               ; vram_y = VS_MANUAL_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	move s0, v0
	li a0, VS_MANUAL_PALETTE_VRAM_X       ; palette_x = VS_MANUAL_PALETTE_VRAM_X;
	li a1, VS_MANUAL_PALETTE_VRAM_Y       ; palette_y = VS_MANUAL_PALETTE_VRAM_Y;
	jal VS_GetCLUT                        ; clut = VS_GetCLUT(palette_x,palette_y);        
	nop
	li a0, 34                             ; x = 34;
	li a1, 128                            ; y = 128;
	move a2, s0                    
	move a3, v0
	jal VS_TextureImage                   ; VS_TextureImage(x,y,texpage,clut);
	nop
	jal VS_DrawSync
	move s0, v0
	li a0, 0                              ; mode = 0;
	li a1, 1                              ; alpha = 1;
	li a2, VS_DMA_VRAM_X                  ; vram_x = VS_MANUAL_VRAM_X;
	li a3, VS_DMA_VRAM_Y                  ; vram_y = VS_MANUAL_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	li a0, 134                            ; x = 134;
	li a1, 128                            ; y = 128;
	move a2, v0                    
	move a3, s0
	jal VS_TextureImage                   ; VS_TextureImage(x,y,texpage,clut);
	nop
main:
	b main 
	nop
	addi sp, 64
	
# Function: VS_DrawSync
# Purpose: Halts program execution until all drawing commands have been executed by the gpu 
VS_DrawSync:
	li a0, VS_IO             ; vs_io_addr = (unsigned long*)$1F800000;
DrawSyncLoop:
	lw a1, VS_GP1(a0)        ; gpu1 = *vs_gpu1;
	li a2, VS_CMD_STAT_READY ; gpu1_cmd = VS_CMD_STAT_READY; (delay slot)
	and a1, a1, a2           ; gpu1 &= gpu1_cmd;
	beqz a1, DrawSyncLoop    ; if(gpu1 == 0) { goto DrawSyncLoop; }
	nop 
	jr ra
	nop
	
# Function: VS_DMASync
# Purpose: Halts program execution until all gpu dma transfers have completed
VS_DMASync:
	li a0, VS_IO             ; vs_io_addr = (unsigned long*)$1F800000;
DMASyncLoop:
	lw a1, VS_GPU_CHCR(a0)   ; dma = *vs_gpu_chchr;
	li a2, VS_DMA_ENABLE     ; cmd = VS_DMA_ENABLE; (delay slot)
	and a1, a1, a2           ; dma &= cmd;
	bnez a1, DMASyncLoop     ; if(dma) { goto DMASyncLoop; }
	nop 
	jr ra
	nop
	
# Function: VS_TransferPaletteDataToVram
# Purpose: Peforms a manual transfer of word-aligned indexed color palette data by the CPU from main memory to VRAM 
# a0: x, a1: y, a2: size, a3: data
VS_TransferPaletteDataToVram:
	li t0, VS_IO                ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_CLEAR_CACHE   ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_CPU_TO_VRAM   ; vs_cmd = VS_CMD_CPU_TO_VRAM;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	; x &= 0xFFFF;
	sll a1, 16                	; y <<= 16;
	addu a1, a0             	; y += x; 
	sw a1, VS_GP0(t0)       	; *vs_gp0 = y;
	andi a2, $FFFF          	; size &= 0xFFFF;
	li t1, $10000               ; h = 1 << 16;
	addu t1, a2             	; h += size; 
	sw t1, VS_GP0(t0)       	; *vs_gp0 = h;
	sll a2, 1                   ; size <<= 1;
	sra a2, 2                   ; size /= 4;
TransferPaletteLoop:
	lw a0, 0(a3)                 ; word = *(unsigned long*)data;
	addi a3, 4                   ; data += 4; (Delay Slot)
	subi a2, 1                   ; size--;
	bnez a2, TransferPaletteLoop ; if(size != 0) { goto TransferLoop; } 
	sw a0, VS_GP0(t0)            ; *vs_gp0 = word; (Delay Slot)
	jr ra 
	nop

# Function: VS_TransferFourBPPImageDataToVram
# Purpose: Peforms a manual transfer of word-aligned 4-bpp indexed color image data by the CPU from main memory to VRAM 
# a0: x, a1: y, a2: w, a3: h, 16(sp): data 
VS_TransferFourBPPImageDataToVram:
	li t0, VS_IO                ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_CLEAR_CACHE   ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_CPU_TO_VRAM   ; vs_cmd = VS_CMD_CPU_TO_VRAM;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	; x &= 0xFFFF;
	sll a1, 16                	; y <<= 16;
	addu a1, a0             	; y += x; 
	sw a1, VS_GP0(t0)       	; *vs_gp0 = y;
	sra t1, a2, 2               ; w >>= 2;
	andi t1, $FFFF          	; w &= 0xFFFF;
	sll a0, a3, 16              ; h <<= 16;
	addu a0, t1             	; h += w; 
	sw a0, VS_GP0(t0)       	; *vs_gp0 = h;
	mult a2, a3                 ; size = w * h;
	mflo a0 
	lw a1, 16(sp)
	sra a0, 2                   ; size /= 2;
TransferFourBppLoop:
	lw a2, 0(a1)                  ; word = *(unsigned long*)data;
	addi a1, 4                    ; data += 4; (Delay Slot)
	subi a0, 1                    ; size--;
	bnez a0, TransferFourBppLoop  ; if(size != 0) { goto TransferFourBppLoop; } 
	sw a2, VS_GP0(t0)             ; *vs_gp0 = word; (Delay Slot)
	jr ra 
	nop
	
# Function: VS_DMAFourBPPImageDataToVram
# Purpose: Peforms a DMA transfer of word-aligned indexed color palette data by the CPU from main memory to VRAM 
# a0: x, a1: y, a2: width, a3: height, 16(sp): data
VS_DMAFourBPPImageDataToVram:
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
	sra a0, 2                   ; width >>= 2;
	sll a1, a3, 16              ; height <<= 16;
	addu a1, a0                 ; height += width;
	sw a1, VS_GP0(t0)           ; *vs_gp0 = height;
	li a0, VS_CMD_ENABLE_DMA    ; vs_cmd = VS_CMD_ENABLE_DMA;
	sw a0, VS_GP1(t0)           ; *vs_gp1 = vs_cmd;
	mult a2, a3                 
	mflo a0                     ; size = width*height;
	lw a1, 16(sp)
	sra a0, 1                   ; size /= 4;
	sw a1, VS_GPU_DMA(t0)       ; *vs_gpu_dma = data;
	li a1, $10                  ; dma_size = 16;     
	blt a0, a1, CompleteFourDMA ; if(size < dma_size) { goto CompleteFourDMA; }
	nop                  
vs_four_align:
	andi t1, a0, $f           
	bnez t1, CompleteFourDMA    ; if(!(size % 16)) { goto CompleteFourDMA; }
	nop
vs_four_align_size:
	addiu a0, 15                ; size += 15;
CompleteFourDMA:
	sra a0, a0, 4               ; size /= 16;
	sll a0, a0, 16              ; size <<= 16;
	ori a0, a0, 16    	        ; size |= 16;
	sw a0, VS_GPU_BCR(t0)       ; *gpu_bcr = size;
	li t2, $01000201   	        ; mode = write_mode;
	sw t2, VS_GPU_CHCR(t0)      ; *gpu_chcr = mode;
WaitFourBPPDMA:
	lw a1, VS_GPU_CHCR(t0)      ; dma = *vs_gpu_chchr;
	li a2, VS_DMA_ENABLE        ; cmd = VS_DMA_ENABLE; (delay slot)
	and a1, a1, a2              ; dma &= cmd;
	bnez a1, WaitFourBPPDMA     ; if(dma) { goto WaitFourBPPDMA; }
	nop 
	jr ra 
	nop

# Function: VS_GetTexturePage
# Purpose: Gets the texture page of the texture given the texture parameters
# a0: mode, a1: a, a2: x, a3: y 
VS_GetTexturePage:
	andi a0, a0, $3    ; mode &= 3; 
	sll  a0, a0, $7    ; mode <<= 7;
	andi a1, a1, $3    ; a &= 3; 
	sll  a1, a1, $5    ; a <<= 5;
	or   a0, a0, a1    ; mode |= a;
	andi t1, a3, $100  ; y &= $100;
	sra  t1, t1, $4    ; y >>= 4;
	or   a0, a0, t1    ; mode |= y;
	andi a2, a2, $3ff  ; x &= $3ff;
	sra  a2, a2, $6    ; x >>= 6;
	or   a0, a0, a2    ; mode |= x;
	andi a3, a3, $200  ; y &= $200;
	sll  a3, a3, $2    ; y <<= 2;
	or   v0, a0, a3    ; mode |= y;
	jr   ra 
	nop
	
# Function: VS_GetCLUT
# Purpose: Gets the color palette coordinates in a format that can be given to the GPU 
# a0: x, a1: y 
VS_GetCLUT:
	sll  a1, a1, 6   ; y <<= 6;
	sra  a0, a0, 4   ; x >>= 4;
	andi a0, a0, $3f ; x &= $3f;
	or   v0, a0, a1  ; y |= x;
	jr ra 
	nop
	
# Function: VS_TextureFourPointPoly
# Purpose: Draws a textured four-point polygon, a quad, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): x4, 60(sp): y4, 64(sp): u4, 68(sp): v4
VS_TextureFourPointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	li   t1, VS_CMD_TEXTURE_QUAD        ; gpu0_cmd = VS_CMD_TEXTURE_QUAD;
	sw   t1, VS_GP0(t0)                 ; *vs_gpu0 = gpu0_cmd;
	andi a0, $FFFF                      ; x1 &= 0xFFFF;
	sll  a1, $10                        ; y1 <<= 16;
	or   a1, a0                         ; y1 |= x1;
	sw   a1, VS_GP0(t0)                 ; *vs_gpu0 = y1;
	sll  a2, $10                        ; palette <<= 16;
	lhu  a1, 16(sp)
	andi a3, $FF                        ; u1 &= 0xFF; 
	andi a1, $FF                        ; v1 &= 0xFF;
	sll  a1, $8                         ; v1 <<= 8;
	or   a1, a3                         ; v1 |= u1;
	or   a1, a2                         ; v1 |= palette;
	sw   a1, VS_GP0(t0)                 ; *vs_gpu0 = v1;
	lhu  a0, 20(sp)
	lhu  a1, 24(sp)
	andi a0, $FFFF                      ; x2 &= 0xFFFF;
	sll  a1, $10                        ; y2 <<= 16;
	or   a1, a0                         ; y2 |= x2;
	sw   a1, VS_GP0(t0)                 ; *vs_gpu0 = y2;
	lhu  a1, 36(sp)
	lhu  a2, 28(sp)
	lhu  a3, 32(sp)
	sll  a2, $10                        ; texpage <<= 16;
	andi a3, $FF                        ; u2 &= 0xFF; 
	andi a1, $FF                        ; v2 &= 0xFF;
	sll  a1, $8                         ; v2 <<= 8;
	or   a1, a3                         ; v2 |= u2;
	or   a1, a2                         ; v2 |= texpage;
	sw   a1, VS_GP0(t0)                 ; *vs_gpu0 = v2;
	lhu  a0, 40(sp)
	lhu  a1, 44(sp)
	andi a0, $FFFF                      ; x3 &= 0xFFFF;
	sll  a1, $10                        ; y3 <<= 16;
	or   a1, a0                         ; y3 |= x3;
	sw   a1, VS_GP0(t0)                 ; *vs_gpu0 = y3;
	lhu  a3, 48(sp)
	lhu  a1, 52(sp)
	andi a3, $FF                        ; u3 &= 0xFF; 
	andi a1, $FF                        ; v3 &= 0xFF;
	sll  a1, $8                         ; v3 <<= 8;
	or   a1, a1, a3                     ; v3 |= u3;
	sw   a1, VS_GP0(t0)                 ; *vs_gpu0 = v3;
	lhu  a0, 56(sp)
	lhu  a1, 60(sp)
	andi a0, $FFFF                      ; x4 &= 0xFFFF;
	sll  a1, $10                        ; y4 <<= 16;
	or   a1, a0                         ; y4 |= x4;
	sw   a1, VS_GP0(t0)                 ; *vs_gpu0 = y4;
	lhu  a2, 64(sp)
	lhu  a3, 68(sp)
	andi a2, $FF                        ; u4 &= 0xFF;
	sll  a3, $8                         ; v4 <<= 8;
	or   a3, a2                         ; v4 |= u4;
	sw   a3, VS_GP0(t0)                 ; *vs_gpu0 = v4;
	jr ra
	nop
	
# Function: VS_TextureImage
# Purpose: Textures the player's car to the (X,Y) screen coordinates with alpha transparency turned on 
# a0: x, a1: y, a2: texpage, a3: palette
VS_TextureImage:
	subi sp, sp, 80 
	sw ra, 4(sp)
	move t0, a2
	move a2, a3          
	li a3, $0            ; u1 = 0;
	sw zero, 16(sp)      ; v1 = 0;
	sw a0, 20(sp)        ; x2 = VS_PCAR_X;
	li t1, VS_TEXTURE_H
	add t1, t1, a1 
	sw t1, 24(sp)        ; y2 = VS_PCAR_Y + VS_TEXTURE_H;
	sw t0, 28(sp)        ; texpage = GetTexturePage(2,1,VS_PCAR_X,VS_PBIMGY); 
	sw zero, 32(sp)      ; u2 = 0;
	li t1, VS_TEXTURE_H 
	sw t1, 36(sp)        ; v2 = VS_TEXTURE_H;
	li t1, VS_TEXTURE_W 
	addu t1, t1, a0
	sw t1, 40(sp)        ; x3 = VS_PCAR_X + VS_TEXTURE_W;
	sw a1, 44(sp)        ; y3 = VS_PCAR_Y;
	li t1, VS_TEXTURE_W 
	sw t1, 48(sp)        ; u3 = VS_TEXTURE_W;
	sw zero, 52(sp)      ; v3 = 0;
	li t1, VS_TEXTURE_W 
	add t1, t1, a0
	sw t1, 56(sp)        ; x4 = VS_PCAR_X + VS_TEXTURE_W;
	li t1, VS_TEXTURE_H 
	add t1, t1, a1 
	sw t1, 60(sp)        ; y4 = VS_PCAR_Y + VS_TEXTURE_H;
	li t1, VS_TEXTURE_W 
	sw t1, 64(sp)        ; u4 = VS_TEXTURE_W;
	li t1, VS_TEXTURE_H 
	sw t1, 68(sp)        ; v4 = VS_TEXTURE_H;
	jal VS_TextureFourPointPoly
	nop
	jal VS_DrawSync
	nop
	lw ra, 4(sp)
	addi sp, sp, 80
	jr ra 
	nop
	
.data 
Palette:
	.incbin "palette.bin"
	
Texture:
	.incbin "texture.bin"