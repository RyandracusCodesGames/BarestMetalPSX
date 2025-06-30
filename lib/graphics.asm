#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# graphics.asm - A low-level software interface for issuing
# commands to the PlayStation's GPU.
#-----------------------------------------------------------
	
	.syntax asmpsx
	.arch psx 
	.text
	
; Commands Are Sent by Writing Directly to the GPU controls registers
; ex: *vs_gp1 = VS_CMD_DISP_ENABLE;
; li t0, VS_IO
; li t1, VS_CMD_DISP_ENABLE
; sw t1, VS_GP1(t0)

; (X,Y) Coordinate Pairs and (W/H) Pairs Are Sent by Writing the Y-Coordinate to the Upper 16-bits of a Register and the X-Coordinate to the Lower 16-bits 
; ex: x = a0, y = a1, t1 = cmd
; li t0, VS_IO 
; sw t1, VS_GP0(t0)
; andi a0, a0, 0xFFFF 
; sll a1, a1, 16 
; addu a1, a1, a0 
; sw a1, VS_GP0(t0)

; (U,V) Texture Coordinate Pairs Are Sent by Writing the UV Coordinates to the lower 16-bits of the 32-bit register.
; The U-Coordinate is sent to the lower 8-bits and the V-Coordinate to the Upper 8-bits 
; ex: u = a0, v = a1 
; andi a0, a0, 0xFF 
; sll a1, a1, 8 
; addu a1, a1, a0 
; sw a1, VS_GP0(t0)

; PlayStation I/O Registers
VS_IO equ $1F800000          ; PlayStation's Base I/O Address For All Registers
VS_GP0 equ $1810             ; PlayStation's First GPU Control Register, Primarily For Drawing Commands and DMA transfers
VS_GP1 equ $1814             ; PlayStation's Second GPU Control Register, Primarily for Display Commands 
VS_IRQ_STAT equ $1F800070
VS_IRQ_VSYNC equ 1

; vs_gp0 = (unsigned long*)(VS_IO + VS_GP0);
; vs_gp1 = (unsigned long*)(VS_IO + VS_GP1);

; PlayStation Memory Transfer Commands
VS_CMD_FLUSH_CACHE equ $01000000 
VS_CMD_FILL_VRAM equ $02000000
VS_CMD_CPU_TO_VRAM equ $A0000000          ; A Command to Send Data from Main Memory to VRAM 
VS_CMD_VRAM_TO_CPU equ $C0000000          ; A Command to Send Data from VRAM to Main Memory
VS_CMD_VRAM_TO_VRAM equ $80000000         ; A Command to Transfer Data from One Area of VRAM to Another Area of VRAM 
VS_GPU_DMA equ $10A0                      ; DMA Channel 2(GPU) Address for Transfering Image Data and Display Lists
VS_GPU_BCR equ $10A4                      ; DMA Block Control Register for Setting DMA Transfer Size
VS_GPU_CHCR equ $10A8                     ; DMA Channel Control Register for Setting Type of DMA Transfer(Read/Write)
VS_CMD_STAT_READY equ $4000000
VS_DMA_ENABLE equ $1000000
VS_CMD_DISABLE_DMA equ $04000000 
VS_CMD_ENABLE_DMA equ $04000002
VS_CMD_ENABLE_DMA_READ equ $04000003
; PlayStation Rasterization Commands 
VS_CMD_DRAW_LINE equ $40000000
VS_CMD_DRAW_SEMI_TRANS_LINE equ $42000000
VS_CMD_SHADE_LINE equ $50000000
VS_CMD_SHADE_SEMI_TRANS_LINE equ $52000000 
VS_CMD_FILL_RECT equ $60000000 
VS_CMD_FILL_SEMI_TRANS_RECT equ $62000000 
VS_CMD_FILL_1x1_RECT equ $68000000
VS_CMD_FILL_SEMI_TRANS_1x1_RECT equ $6A000000
VS_CMD_FILL_8x8_RECT equ $70000000
VS_CMD_FILL_SEMI_TRANS_8x8_RECT equ $72000000
VS_CMD_FILL_16x16_RECT equ $78000000
VS_CMD_FILL_SEMI_TRANS_16x16_RECT equ $7A000000
VS_CMD_FILL_TRIANGLE equ $20000000
VS_CMD_FILL_SEMI_TRANS_TRIANGLE equ $22000000
VS_CMD_SHADE_TRIANGLE equ $30000000
VS_CMD_SHADE_SEMI_TRANS_TRIANGLE equ $32000000
VS_CMD_TEXTURE_BLEND_TRIANGLE equ $24000000
VS_CMD_TEXTURE_TRIANGLE equ $25000000
VS_CMD_TEXTURE_SEMI_TRANS_TRIANGLE equ $27000000
VS_CMD_TEXTURE_BLEND_ST_TRIANGLE equ $26000000
VS_CMD_FILL_QUAD equ $28000000
VS_CMD_FILL_SEMI_TRANS_QUAD equ $2A000000
VS_CMD_SHADE_QUAD equ $38000000
VS_CMD_SHADE_SEMI_TRANS_QUAD equ $3A000000
VS_CMD_TEXTURE_BLEND_QUAD equ $2C000000
VS_CMD_TEXTURE_QUAD equ $2D000000
VS_CMD_TEXTURE_SEMI_TRANS_QUAD equ $2F000000
VS_CMD_TEXTURE_ST_BLEND_QUAD equ $2E000000
VS_CMD_SHADE_TEXTURE_QUAD equ $3C000000

# Function: VS_ResetGPU
# Purpose: Sends a reset command to the GP1 control register
VS_ResetGPU:
	li a0, VS_IO 
	sw zero, VS_GP1(a0)
	jr ra 
	nop
	
# Function: VS_ClearGPUFIFO
# Purpose: Sends a reset gpu FIFO command to the GP1 control register
VS_ClearGPUFIFO:
	li a0, VS_IO 
	li a1, $01000000
	sw a1, VS_GP1(a0)
	jr ra 
	nop

# Function: VS_FillVram
# Purpose: Fills a rectangular area in VRAM with a solid monochrome color
# a0: x, a1: y, a2: w, a3: h, 16(sp): color
VS_FillVram:
	li t0, VS_IO              ; vs_io = (unsigned long*)VS_IO;
	lw t2, 16(sp)
	li t1, VS_CMD_FILL_VRAM   ; vs_cmd = VS_CMD_FILL_VRAM;
	or t1, t2                 ; vs_cmd |= color;
	sw t1, VS_GP0(t0)         ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF            ; x &= 0xFFFF;
	sll a1, 16                ; y <<= 16;
	addu a1, a0               ; y += x;
	sw a1, VS_GP0(t0)         ; *vs_gp0 = y;
	andi a2, $FFFF            ; w &= 0xFFFF;
	sll a3, 16                ; h <<= 16;
	addu a3, a2               ; h += w;
	sw a3, VS_GP0(t0)         ; *vs_gp0 = h;
	jr ra 
	nop
	
# Function: VS_VramToVram
# Purpose: Transfers a source rectangular area of VRAM to a destination rectangular area of VRAM 
# a0: srcx, a1: srcy, a2: destx, a3: desty, 16(sp): width, 20(sp): height
VS_VramToVram:
	li t0, VS_IO                          ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_VRAM_TO_VRAM            ; vs_cmd = VS_VRAM_TO_VRAM;
	sw t1, VS_GP0(t0)                     ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF                        ; srcx &= $FFFF;
	sll a1, a1, $10                       ; srcy <<= 16;
	addu a1, a0                           ; srcy += srcx;
	sw a1, VS_GP0(t0)                     ; *vs_gp0 = srcy;
	andi a2, $FFFF                        ; destx &= $FFFF;
	sll a3, a3, $10                       ; desty <<= 16;
	addu a3, a2                           ; desty += destx;
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)                     ; *vs_gp0 = desty;
	lw a1, 20(sp) 
	andi a0, $FFFF                        ; w &= $FFFF;
	sll a1, a1, $10                       ; h <<= 16;
	addu a1, a0                           ; h += w;
	sw a1, VS_GP0(t0)                     ; *vs_gp0 = h;
	jr ra 
	nop
	
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
	sll  a1, a1, $6  ; y <<= 6;
	sra  a0, a0, $4  ; x >>= 4;
	andi a0, a0, $3f ; x &= $3f;
	or   v0, a0, a1  ; y |= x;
	jr ra 
	nop
	

	
# Function: VS_DrawMonochromeLine
# Purpose: Draws a monochrome line to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): color
VS_DrawMonochromeLine:
	li t0, VS_IO              ; vs_io = (unsigned long*)VS_IO;
	lw t2, 16(sp)
	li t1, VS_CMD_DRAW_LINE   ; vs_cmd = VS_CMD_DRAW_LINE;
	or t1, t2                 ; vs_cmd |= color;
	sw t1, VS_GP0(t0)         ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF            ; x1 &= 0xFFFF;
	sll a1, 16                ; y1 <<= 16;
	addu a1, a0               ; y1 += x1;
	sw a1, VS_GP0(t0)         ; *vs_gp0 = y1;
	andi a2, $FFFF            ; x1 &= 0xFFFF;
	sll a3, 16                ; y2 <<= 16;
	addu a3, a2               ; y2 += x2;
	sw a3, VS_GP0(t0)         ; *vs_gp0 = y2;
	jr ra 
	nop
	
# Function: VS_DrawSemiTransMonochromeLine
# Purpose: Draws a semi-transparent monochrome line to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): color
VS_DrawSemiTransMonochromeLine:
	li t0, VS_IO              			 ; vs_io = (unsigned long*)VS_IO;
	lw t2, 16(sp)
	li t1, VS_CMD_DRAW_SEMI_TRANS_LINE   ; vs_cmd = VS_CMD_DRAW_SEMI_TRANS_LINE;
	or t1, t2                            ; vs_cmd |= color;
	sw t1, VS_GP0(t0)         			 ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF            			 ; x1 &= 0xFFFF;
	sll a1, 16                			 ; y1 <<= 16;
	addu a1, a0               			 ; y1 += x1;
	sw a1, VS_GP0(t0)        			 ; *vs_gp0 = y1;
	andi a2, $FFFF            			 ; x1 &= 0xFFFF;
	sll a3, 16               			 ; y2 <<= 16;
	addu a3, a2              			 ; y2 += x2;
	sw a3, VS_GP0(t0)        			 ; *vs_gp0 = y2;
	jr ra 
	nop
	
# Function: VS_ShadeLine
# Purpose: Draws a gouraud-shaded line to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): color1, 20(sp): color2
VS_ShadeLine:
	li t0, VS_IO              ; vs_io = (unsigned long*)VS_IO;
	lw t2, 16(sp)
	li t1, VS_CMD_SHADE_LINE  ; vs_cmd = VS_CMD_SHADE_LINE;
	or t1, t2                 ; vs_cmd |= color1;
	sw t1, VS_GP0(t0)         ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF            ; x1 &= 0xFFFF;
	sll a1, 16                ; y1 <<= 16;
	addu a1, a0               ; y1 += x1;
	lw t2, 20(sp)
	sw a1, VS_GP0(t0)         ; *vs_gp0 = y1;
	sw t2, VS_GP0(t0)         ; *vs_gp0 = color2;
	andi a2, $FFFF            ; x1 &= 0xFFFF;
	sll a3, 16                ; y2 <<= 16;
	addu a3, a2               ; y2 += x2;
	sw a3, VS_GP0(t0)         ; *vs_gp0 = y2;
	jr ra 
	nop

# Function: VS_ShadeSemiTransLine
# Purpose: Draws a semi-transparent, gouraud-shaded line to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): color1, 20(sp): color2
VS_ShadeSemiTransLine:
	li t0, VS_IO              			 ; vs_io = (unsigned long*)VS_IO;
	lw t2, 16(sp)
	li t1, VS_CMD_SHADE_SEMI_TRANS_LINE  ; vs_cmd = VS_CMD_SHADE_SEMI_TRANS_LINE;
	or t1, t2                 			 ; vs_cmd |= color1;
	sw t1, VS_GP0(t0)        			 ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF           			 ; x1 &= 0xFFFF;
	sll a1, 16              		     ; y1 <<= 16;
	addu a1, a0              			 ; y1 += x1;
	lw t2, 20(sp)
	sw a1, VS_GP0(t0)       		     ; *vs_gp0 = y1;
	sw t2, VS_GP0(t0)        			 ; *vs_gp0 = color2;
	andi a2, $FFFF           			 ; x1 &= 0xFFFF;
	sll a3, 16               			 ; y2 <<= 16;
	addu a3, a2              			 ; y2 += x2;
	sw a3, VS_GP0(t0)        			 ; *vs_gp0 = y2;
	jr ra 
	nop

# Function: VS_FillRectangle
# Purpose: Draws a filled rectangle to the display area
# a0: x, a1: y, a2: w, a3: h, 16(sp): color
VS_FillRectangle:
	li t0, VS_IO              ; vs_io = (unsigned long*)VS_IO;
	lw t2, 16(sp)
	li t1, VS_CMD_FILL_RECT   ; vs_cmd = VS_CMD_FILL_RECT;
	or t1, t2                 ; vs_cmd |= color;
	sw t1, VS_GP0(t0)         ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF            ; x &= 0xFFFF;
	sll a1, 16                ; y <<= 16;
	addu a1, a0               ; y += x;
	sw a1, VS_GP0(t0)         ; *vs_gp0 = y;
	andi a2, $FFFF            ; w &= 0xFFFF;
	sll a3, 16                ; h <<= 16;
	addu a3, a2               ; h += w;
	sw a3, VS_GP0(t0)         ; *vs_gp0 = h;
	jr ra 
	nop
	
# Function: VS_FillSemiTransRectangle
# Purpose: Draws a semi-transparent filled rectangle to the display area
# a0: x, a1: y, a2: w, a3: h, 16(sp): color
VS_FillSemiTransRectangle:
	li t0, VS_IO             			 ; vs_io = (unsigned long*)VS_IO;
	lw t2, 16(sp)
	li t1, VS_CMD_FILL_SEMI_TRANS_RECT   ; vs_cmd = VS_CMD_FILL_SEMI_TRANS_RECT;
	or t1, t2                 			 ; vs_cmd |= color;
	sw t1, VS_GP0(t0)        			 ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF           			 ; x &= 0xFFFF;
	sll a1, 16               			 ; y <<= 16;
	addu a1, a0              			 ; y += x;
	sw a1, VS_GP0(t0)        			 ; *vs_gp0 = y;
	andi a2, $FFFF           			 ; w &= 0xFFFF;
	sll a3, 16               			 ; h <<= 16;
	addu a3, a2              			 ; h += w;
	sw a3, VS_GP0(t0)        			 ; *vs_gp0 = h;
	jr ra 
	nop
	
# Function: VS_DrawPixel
# Purpose: Draws a 1x1 rectangle to the display area, aka, a pixel.
# a0: x, a1: y, a2: color 
VS_DrawPixel:
	li t0, VS_IO            	  ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_FILL_1x1_RECT   ; vs_cmd = VS_CMD_FILL_1x1_RECT;
	or t1, a2                 	  ; vs_cmd |= color;
	sw t1, VS_GP0(t0)        	  ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	  ; x &= 0xFFFF;
	sll a1, 16              	  ; y <<= 16;
	addu a1, a0             	  ; y += x;
	sw a1, VS_GP0(t0)       	  ; *vs_gp0 = y;
	jr ra 
	nop
	
# Function: VS_DrawSemiTransPixel
# Purpose: Draws a semi-transparent 1x1 rectangle to the display area, aka, a pixel.
# a0: x, a1: y, a2: color 
VS_DrawSemiTransPixel:
	li t0, VS_IO            	  		   ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_FILL_SEMI_TRANS_1x1_RECT ; vs_cmd = VS_CMD_FILL_SEMI_TRANS_1x1_RECT;
	or t1, a2                 	  		   ; vs_cmd |= color;
	sw t1, VS_GP0(t0)        	  		   ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	  		   ; x &= 0xFFFF;
	sll a1, 16              	  		   ; y <<= 16;
	addu a1, a0             	 		   ; y += x;
	sw a1, VS_GP0(t0)       	  		   ; *vs_gp0 = y;
	jr ra 
	nop
	
# Function: VS_Fill8x8Rectangle
# Purpose: Draws a filled 8x8 rectangle to the display area.
# a0: x, a1: y, a2: color 
VS_Fill8x8Rectangle:
	li t0, VS_IO            	  ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_FILL_8x8_RECT   ; vs_cmd = VS_CMD_FILL_8x8_RECT;
	or t1, a2                 	  ; vs_cmd |= color;
	sw t1, VS_GP0(t0)        	  ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	  ; x &= 0xFFFF;
	sll a1, 16              	  ; y <<= 16;
	addu a1, a0             	  ; y += x;
	sw a1, VS_GP0(t0)       	  ; *vs_gp0 = y;
	jr ra 
	nop
	
# Function: VS_FillSemiTrans8x8Rectangle
# Purpose: Draws a filled, semi-transparent 8x8 rectangle to the display area.
# a0: x, a1: y, a2: color  
VS_FillSemiTrans8x8Rectangle:
	li t0, VS_IO            	  		   ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_FILL_SEMI_TRANS_8x8_RECT ; vs_cmd = VS_CMD_FILL_SEMI_TRANS_8x8_RECT;
	or t1, a2                 	  		   ; vs_cmd |= color;
	sw t1, VS_GP0(t0)        	  		   ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	  		   ; x &= 0xFFFF;
	sll a1, 16              	  		   ; y <<= 16;
	addu a1, a0             	 		   ; y += x;
	sw a1, VS_GP0(t0)       	  		   ; *vs_gp0 = y;
	jr ra 
	nop
	
# Function: VS_Fill16x16Rectangle
# Purpose: Draws a filled 16x16 rectangle to the display area.
# a0: x, a1: y, a2: color 
VS_Fill16x16Rectangle:
	li t0, VS_IO            	  ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_FILL_16x16_RECT ; vs_cmd = VS_CMD_FILL_16x16_RECT;
	or t1, a2                 	  ; vs_cmd |= color;
	sw t1, VS_GP0(t0)        	  ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	  ; x &= 0xFFFF;
	sll a1, 16              	  ; y <<= 16;
	addu a1, a0             	  ; y += x;
	sw a1, VS_GP0(t0)       	  ; *vs_gp0 = y;
	jr ra 
	nop
	
# Function: VS_FillSemiTrans16x16Rectangle
# Purpose: Draws a filled, semi-transparent 16x16 rectangle to the display area.
# a0: x, a1: y, a2: color  
VS_FillSemiTrans16x16Rectangle:
	li t0, VS_IO            	  		     ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_FILL_SEMI_TRANS_16x16_RECT ; vs_cmd = VS_CMD_FILL_SEMI_TRANS_16x16_RECT;
	or t1, a2                 	  		     ; vs_cmd |= color;
	sw t1, VS_GP0(t0)        	  		     ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	  		     ; x &= 0xFFFF;
	sll a1, 16              	  		     ; y <<= 16;
	addu a1, a0             	 		     ; y += x;
	sw a1, VS_GP0(t0)       	  		     ; *vs_gp0 = y;
	jr ra 
	nop
	
# Function: VS_FillTriangle
# Purpose: Fills a monochrome triangle to the display area 
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): color
VS_FillTriangle:
	li t0, VS_IO 
	lw t2, 24(sp)
	li t1, VS_CMD_FILL_TRIANGLE ; vs_cmd = VS_CMD_FILL_TRIANGLE;
	addu t1, t2                 ; vs_cmd += color;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	        ; x1 &= 0xFFFF;
	sll a1, $10        	        ; y1 <<= 16;
	addu a1, a0                 ; y1 += x1; 
	sw a1, VS_GP0(t0)           ; *vs_gp0 = y1;
	andi a2, $FFFF              ; x2 &= 0xFFFF;
	sll a3, $10                 ; y2 <<= 16;
	addu a3, a2                 ; y2 += x2; 
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)           ; *vs_gp0 = y2;
	lw a1, 20(sp)
	andi a0, $FFFF              ; x3 &= 0xFFFF;
	sll a1, $10                 ; y3 <<= 16;
	addu a1, a0                 ; y3 += x3; 
	sw a1, VS_GP0(t0)           ; *vs_gp0 = y3;
	jr ra 
	nop	
	
# Function: VS_FillSemiTransTriangle
# Purpose: Fills a semi-transparent monochrome triangle to the display area 
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): color
VS_FillSemiTransTriangle:
	li t0, VS_IO 
	lw t2, 24(sp)
	li t1, VS_CMD_FILL_SEMI_TRANS_TRIANGLE ; vs_cmd = VS_CMD_FILL_TRIANGLE;
	addu t1, t2                 		   ; vs_cmd += color;
	sw t1, VS_GP0(t0)          			   ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	    			   ; x1 &= 0xFFFF;
	sll a1, $10        	      			   ; y1 <<= 16;
	addu a1, a0             		       ; y1 += x1; 
	sw a1, VS_GP0(t0)        			   ; *vs_gp0 = y1;
	andi a2, $FFFF          		       ; x2 &= 0xFFFF;
	sll a3, $10              			   ; y2 <<= 16;
	addu a3, a2              			   ; y2 += x2; 
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)        			   ; *vs_gp0 = y2;
	lw a1, 20(sp)
	andi a0, $FFFF            			  ; x3 &= 0xFFFF;
	sll a1, $10               			  ; y3 <<= 16;
	addu a1, a0               			  ; y3 += x3; 
	sw a1, VS_GP0(t0)         			  ; *vs_gp0 = y3;
	jr ra 
	nop	
	
# Function: VS_ShadeTriangle
# Purpose: Fills a gouraud-shaded triange to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): color1, 28(sp): color2, 32(sp): color3
VS_ShadeTriangle:
	li t0, VS_IO 
	lw t2, 24(sp)
	li t1, VS_CMD_SHADE_TRIANGLE ; vs_cmd = VS_CMD_SHADE_TRIANGLE;
	addu t1, t2              	 ; vs_cmd += color1;
	sw t1, VS_GP0(t0)       	 ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	    	 ; x1 &= 0xFFFF;
	sll a1, $10        	    	 ; y1 <<= 16;
	addu a1, a0             	 ; y1 += x1; 
	sw a1, VS_GP0(t0)       	 ; *vs_gp0 = y1;
	lw t2, 28(sp)
	andi a2, $FFFF          	 ; x2 &= 0xFFFF; (delay slot)
	sw t2, VS_GP0(t0)       	 ; *vs_gp0 = color2;
	sll a3, $10             	 ; y2 <<= 16;
	addu a3, a2             	 ; y2 += x2; 
	lw t1, 32(sp)
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)       	 ; *vs_gp0 = y2;
	sw t1, VS_GP0(t0)       	 ; *vs_gp0 = color3;
	lw a1, 20(sp)
	andi a0, $FFFF          	 ; x3 &= 0xFFFF;
	sll a1, $10             	 ; y3 <<= 16;
	addu a1, a0             	 ; y3 += x3; 
	sw a1, VS_GP0(t0)       	 ; *vs_gp0 = y3;
	jr ra 
	nop	
	
# Function: VS_ShadeSemiTransTriangle
# Purpose: Fills a semi-transparent gouraud-shaded triange to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): color1, 28(sp): color2, 32(sp): color3
VS_ShadeSemiTransTriangle:
	li t0, VS_IO 
	lw t2, 24(sp)
	li t1, VS_CMD_SHADE_SEMI_TRANS_TRIANGLE ; vs_cmd = VS_CMD_SHADE_SEMI_TRANS_TRIANGLE;
	addu t1, t2              	            ; vs_cmd += color1;
	sw t1, VS_GP0(t0)       			    ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	    		   	    ; x1 &= 0xFFFF;
	sll a1, $10        	   				 	; y1 <<= 16;
	addu a1, a0             			    ; y1 += x1; 
	sw a1, VS_GP0(t0)       		     	; *vs_gp0 = y1;
	lw t2, 28(sp)
	andi a2, $FFFF          	            ; x2 &= 0xFFFF; (delay slot)
	sw t2, VS_GP0(t0)       	            ; *vs_gp0 = color2;
	sll a3, $10             	            ; y2 <<= 16;
	addu a3, a2             	            ; y2 += x2; 
	lw t1, 32(sp)
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)       	            ; *vs_gp0 = y2;
	sw t1, VS_GP0(t0)       	            ; *vs_gp0 = color3;
	lw a1, 20(sp)
	andi a0, $FFFF          	            ; x3 &= 0xFFFF;
	sll a1, $10             	            ; y3 <<= 16;
	addu a1, a0             	            ; y3 += x3; 
	sw a1, VS_GP0(t0)       	            ; *vs_gp0 = y3;
	jr ra 
	nop	
	
# Function: VS_FillQuad
# Purpose: Fills a monochrome four-point polygon, a quad, to the display area 
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): x4, 28(sp): y4, 32(sp): color
VS_FillQuad:
	li t0, VS_IO 
	lw t2, 32(sp)
	li t1, VS_CMD_FILL_QUAD     ; vs_cmd = VS_CMD_FILL_QUAD;
	addu t1, t2                 ; vs_cmd += color;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	        ; x1 &= 0xFFFF;
	sll a1, $10        	        ; y1 <<= 16;
	addu a1, a0                 ; y1 += x1; 
	sw a1, VS_GP0(t0)           ; *vs_gp0 = y1;
	andi a2, $FFFF              ; x2 &= 0xFFFF;
	sll a3, $10                 ; y2 <<= 16;
	addu a3, a2                 ; y2 += x2; 
	sw a3, VS_GP0(t0)           ; *vs_gp0 = y2;
	lw a0, 16(sp)
	lw a1, 20(sp)
	andi a0, $FFFF              ; x3 &= 0xFFFF;
	sll a1, $10                 ; y3 <<= 16;
	addu a1, a0                 ; y3 += x3; 
	sw a1, VS_GP0(t0)           ; *vs_gp0 = y3;
	lw a0, 24(sp)
	lw a1, 28(sp)
	andi a0, $FFFF              ; x4 &= 0xFFFF;
	sll a1, $10                 ; y4 <<= 16;
	addu a1, a0                 ; y4 += x4; 
	sw a1, VS_GP0(t0)           ; *vs_gp0 = y4;
	jr ra 
	nop	
	
# Function: VS_FillSemiTransQuad
# Purpose: Fills a semi-transparent monochrome four-point polygon, a quad, to the display area 
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): x4, 28(sp): y4, 32(sp): color
VS_FillSemiTransQuad:
	li t0, VS_IO 
	lw t2, 32(sp)
	li t1, VS_CMD_FILL_SEMI_TRANS_QUAD     ; vs_cmd = VS_CMD_FILL_QUAD;
	addu t1, t2                			   ; vs_cmd += color;
	sw t1, VS_GP0(t0)        			   ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	    		       ; x1 &= 0xFFFF;
	sll a1, $10        	    		       ; y1 <<= 16;
	addu a1, a0              			   ; y1 += x1; 
	sw a1, VS_GP0(t0)        			   ; *vs_gp0 = y1;
	andi a2, $FFFF           			   ; x2 &= 0xFFFF;
	sll a3, $10              			   ; y2 <<= 16;
	addu a3, a2              			   ; y2 += x2; 
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)        			   ; *vs_gp0 = y2;
	lw a1, 20(sp)
	andi a0, $FFFF           			   ; x3 &= 0xFFFF;
	sll a1, $10              			   ; y3 <<= 16;
	addu a1, a0              			   ; y3 += x3; 
	sw a1, VS_GP0(t0)         			   ; *vs_gp0 = y3;
	lw a0, 24(sp)
	lw a1, 28(sp)
	andi a0, $FFFF           			   ; x4 &= 0xFFFF;
	sll a1, $10               			   ; y4 <<= 16;
	addu a1, a0              			   ; y4 += x4; 
	sw a1, VS_GP0(t0)        			   ; *vs_gp0 = y4;
	jr ra 
	nop	
	
# Function: VS_ShadeQuad
# Purpose: Fills a gouraud-shaded four-point polygon, a quad, to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): x4, 28(sp): y4, 32(sp): color1, 36(sp): color2, 40(sp): color3, 44(sp): color4
VS_ShadeQuad:
	li t0, VS_IO 
	lw t2, 32(sp)
	li t1, VS_CMD_SHADE_QUAD     ; vs_cmd = VS_CMD_SHADE_QUAD;
	addu t1, t2              	 ; vs_cmd += color1;
	sw t1, VS_GP0(t0)       	 ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	    	 ; x1 &= 0xFFFF;
	sll a1, $10        	    	 ; y1 <<= 16;
	addu a1, a0             	 ; y1 += x1; 
	sw a1, VS_GP0(t0)       	 ; *vs_gp0 = y1;
	lw t2, 36(sp)
	andi a2, $FFFF          	 ; x2 &= 0xFFFF;
	sw t2, VS_GP0(t0)       	 ; *vs_gp0 = color2;
	sll a3, $10             	 ; y2 <<= 16;
	addu a3, a2             	 ; y2 += x2; 
	lw t1, 40(sp)
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)       	 ; *vs_gp0 = y2;
	sw t1, VS_GP0(t0)       	 ; *vs_gp0 = color3;
	lw a1, 20(sp)
	andi a0, $FFFF          	 ; x3 &= 0xFFFF;
	sll a1, $10             	 ; y3 <<= 16;
	addu a1, a0             	 ; y3 += x3; 
	sw a1, VS_GP0(t0)       	 ; *vs_gp0 = y3;
	lw t1, 44(sp)
	lw a0, 24(sp)
	sw t1, VS_GP0(t0)       	 ; *vs_gp0 = color4;
	lw a1, 28(sp)
	andi a0, $FFFF          	 ; x4 &= 0xFFFF;
	sll a1, $10             	 ; y4 <<= 16;
	addu a1, a0             	 ; y4 += x3; 
	sw a1, VS_GP0(t0)       	 ; *vs_gp0 = y4;
	jr ra 
	nop	
	
# Function: VS_ShadeSemiTransQuad
# Purpose: Fills a semi-transparent, gouraud-shaded four-point polygon, a quad, to the display area
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): x3, 20(sp): y3, 24(sp): x4, 28(sp): y4, 32(sp): color1, 36(sp): color2, 40(sp): color3, 44(sp): color4
VS_ShadeSemiTransQuad:
	li t0, VS_IO 
	lw t2, 32(sp)
	li t1, VS_CMD_SHADE_SEMI_TRANS_QUAD     ; vs_cmd = VS_CMD_SHADE_SEMI_TRANS_QUAD;
	addu t1, t2              			    ; vs_cmd += color1;
	sw t1, VS_GP0(t0)       				; *vs_gp0 = vs_cmd;
	andi a0, $FFFF     	    			    ; x1 &= 0xFFFF;
	sll a1, $10        	    	            ; y1 <<= 16;
	addu a1, a0             	            ; y1 += x1; 
	sw a1, VS_GP0(t0)       	            ; *vs_gp0 = y1;
	lw t2, 36(sp)
	andi a2, $FFFF          	            ; x2 &= 0xFFFF;
	sw t2, VS_GP0(t0)       	            ; *vs_gp0 = color2;
	sll a3, $10             	            ; y2 <<= 16;
	addu a3, a2             	            ; y2 += x2; 
	lw t1, 40(sp)
	lw a0, 16(sp)
	sw a3, VS_GP0(t0)       	            ; *vs_gp0 = y2;
	sw t1, VS_GP0(t0)       	            ; *vs_gp0 = color3;
	lw a1, 20(sp)
	andi a0, $FFFF          	            ; x3 &= 0xFFFF;
	sll a1, $10             	            ; y3 <<= 16;
	addu a1, a0             	            ; y3 += x3; 
	sw a1, VS_GP0(t0)       	            ; *vs_gp0 = y3;
	lw t1, 44(sp)
	lw a0, 24(sp)
	sw t1, VS_GP0(t0)       	            ; *vs_gp0 = color4;
	lw a1, 28(sp)
	andi a0, $FFFF          	            ; x4 &= 0xFFFF;
	sll a1, $10             	            ; y4 <<= 16;
	addu a1, a0             	            ; y4 += x3; 
	sw a1, VS_GP0(t0)       	            ; *vs_gp0 = y4;
	jr ra 
	nop	
	
# Function: VS_TextureBlendThreePointPoly
# Purpose: Draws a texture blended three-point polygon, a triangle, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): color 
VS_TextureBlendThreePointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	lw   t2, 56(sp)
	li   t1, VS_CMD_TEXTURE_BLEND_TRIANGLE    ; gpu0_cmd = VS_CMD_TEXTURE_BLEND_TRIANGLE;
	or   t1, t2                         ; gpu0_cmd |= color;
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
	jr ra
	nop
	
	
# Function: VS_TextureBlendSemiTransThreePointPoly
# Purpose: Draws a texture blended semi-transparent three-point polygon, a triangle, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): color 
VS_TextureBlendSemiTransThreePointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	lw   t2, 56(sp)
	li   t1, VS_CMD_TEXTURE_BLEND_ST_TRIANGLE    ; gpu0_cmd = VS_CMD_TEXTURE_BLEND_TRIANGLE;
	or   t1, t2                         ; gpu0_cmd |= color;
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
	jr ra
	nop
	
# Function: VS_TextureThreePointPoly
# Purpose: Draws a textured three-point polygon, a triangle, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
VS_TextureThreePointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	li   t1, VS_CMD_TEXTURE_TRIANGLE    ; gpu0_cmd = VS_CMD_TEXTURE_TRIANGLE;
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
	jr ra
	nop
	
# Function: VS_TextureSemiTransThreePointPoly
# Purpose: Draws a semi-transparent textured three-point polygon, a triangle, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
VS_TextureSemiTransThreePointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	li   t1, VS_CMD_TEXTURE_SEMI_TRANS_TRIANGLE    ; gpu0_cmd = VS_CMD_TEXTURE_TRIANGLE;
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
	jr ra
	nop
	
# Function: VS_TextureBlendFourPointPoly
# Purpose: Draws a texture blended four-point polygon, a quad, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): x4, 60(sp): y4, 64(sp): u4, 68(sp): v4, 72(sp): color 
VS_TextureBlendFourPointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	lw   t2, 72(sp)
	li   t1, VS_CMD_TEXTURE_BLEND_QUAD  ; gpu0_cmd = VS_CMD_TEXTURE_BLEND_QUAD;
	or   t1, t2                         ; gpu0_cmd |= color;
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
	
# Function: VS_TextureBlendSemiTransFourPointPoly
# Purpose: Draws a semi-transparent texture blended four-point polygon, a quad, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): x4, 60(sp): y4, 64(sp): u4, 68(sp): v4, 72(sp): color 
VS_TextureBlendSemiTransFourPointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	lw   t2, 72(sp)
	li   t1, VS_CMD_TEXTURE_ST_BLEND_QUAD  ; gpu0_cmd = VS_CMD_TEXTURE_ST_BLEND_QUAD;
	or   t1, t2                         ; gpu0_cmd |= color;
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
	
# Function: VS_TextureSemiTransFourPointPoly
# Purpose: Draws a semi-transparent textured four-point polygon, a quad, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): x4, 60(sp): y4, 64(sp): u4, 68(sp): v4
VS_TextureSemiTransFourPointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	li   t1, VS_CMD_TEXTURE_SEMI_TRANS_QUAD ; gpu0_cmd = VS_CMD_SEMI_TRANS_TEXTURE_QUAD;
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
	
# Function: VS_ShadeTextureBlendFourPointPoly
# Purpose: Draws a gouraud-shaded, texture blended four-point polygon, a quad, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): x4, 60(sp): y4, 64(sp): u4, 68(sp): v4, 72(sp): color1, 76(sp): color2, 80(sp): color3, 84(sp): color4 
VS_ShadeTextureBlendFourPointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	lw   t2, 72(sp)
	li   t1, VS_CMD_SHADE_TEXTURE_QUAD  ; gpu0_cmd = VS_CMD_SHADE_TEXTURE_QUAD;
	or   t1, t2                         ; gpu0_cmd |= color;
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
	lw   t2, 76(sp)
	lhu  a0, 20(sp)
	sw   t2, VS_GP0(t0)                 ; *vs_gp0 = color2;
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
	lw   t2, 80(sp)
	lhu  a0, 40(sp)
	sw   t2, VS_GP0(t0)                 ; *vs_gp0 = color3;
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
	lw   t2, 84(sp)
	lhu  a0, 56(sp)
	lhu  a1, 60(sp)
	sw   t2, VS_GP0(t0)                 ; *vs_gp0 = color4;
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
	
# Function: VS_TransferImageDataToVram
# Purpose: Peforms a manual transfer of word-aligned data by the CPU from main memory to VRAM 
# a0: x, a1: y, a2: w, a3: h, 16(sp): data 
VS_TransferImageDataToVram:
	li t0, VS_IO                ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_CLEAR_CACHE   ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_CPU_TO_VRAM   ; vs_cmd = VS_CMD_CPU_TO_VRAM;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	; x &= 0xFFFF;
	sll a1, 16                	; y <<= 16;
	addu a1, a0             	; y += x; 
	sw a1, VS_GP0(t0)       	; *vs_gp0 = y;
	andi a2, $FFFF          	; w &= 0xFFFF;
	sll a0, a3, 16              ; h <<= 16;
	addu a0, a2             	; h += w; 
	sw a0, VS_GP0(t0)       	; *vs_gp0 = h;
	mult a2, a3                 ; size = w * h;
	mflo a0 
	sll a0, 1                   ; size <<= 1;
	lw a1, 16(sp)
	sra a0, 2                   ; size /= 4;
TransferLoop:
	lw a2, 0(a1)                ; word = *(unsigned long*)data;
	addi a1, 4                  ; data += 4; (Delay Slot)
	subi a0, 1                  ; size--;
	bnez a0, TransferLoop       ; if(size != 0) { goto TransferLoop; } 
	sw a2, VS_GP0(t0)           ; *vs_gp0 = word; (Delay Slot)
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
	
# Function: VS_TransferIndexImageDataToVram
# Purpose: Peforms a manual transfer of word-aligned indexed color image data by the CPU from main memory to VRAM 
# a0: x, a1: y, a2: w, a3: h, 16(sp): data 
VS_TransferIndexImageDataToVram:
	li t0, VS_IO                ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_CLEAR_CACHE   ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_CPU_TO_VRAM   ; vs_cmd = VS_CMD_CPU_TO_VRAM;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF          	; x &= 0xFFFF;
	sll a1, 16                	; y <<= 16;
	addu a1, a0             	; y += x; 
	sw a1, VS_GP0(t0)       	; *vs_gp0 = y;
	sra t1, a2, 1               ; w >>= 1;
	andi t1, $FFFF          	; w &= 0xFFFF;
	sll a0, a3, 16              ; h <<= 16;
	addu a0, t1             	; h += w; 
	sw a0, VS_GP0(t0)       	; *vs_gp0 = h;
	mult a2, a3                 ; size = w * h;
	mflo a0 
	lw a1, 16(sp)
	sra a0, 2                   ; size /= 4;
TransferIndexLoop:
	lw a2, 0(a1)                ; word = *(unsigned long*)data;
	addi a1, 4                  ; data += 4; (Delay Slot)
	subi a0, 1                  ; size--;
	bnez a0, TransferIndexLoop  ; if(size != 0) { goto TransferIndexLoop; } 
	sw a2, VS_GP0(t0)           ; *vs_gp0 = word; (Delay Slot)
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
	
# Function: VS_DMAImageDataFromVram
# Purpose: Peforms a DMA transfer of word-aligned data by the CPU from VRAM to main memory
# a0: x, a1: y, a2: width, a3: height, 16(sp): data
VS_DMAImageDataFromVram:
	li t0, VS_IO                ; vs_io = (unsigned long*)VS_IO;
	li t1, VS_CMD_DISABLE_DMA   ; vs_cmd = VS_CMD_DISABLE_DMA;
	sw t1, VS_GP1(t0)           ; *vs_gp1 = vs_cmd;
	li t1, VS_CMD_CLEAR_CACHE   ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_VRAM_TO_CPU   ; vs_cmd = VS_CMD_VRAM_TO_CPU;
	sw t1, VS_GP0(t0)           ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF              ; x &= 0xFFFF;
	sll a1, 16                  ; y <<= 16;
	addu a1, a0                 ; y += x;
	sw a1, VS_GP0(t0)           ; *vs_gp0 = y;
	andi a0, a2, $FFFF          ; width &= 0xFFFF; 
	sll a1, a3, 16              ; height <<= 16;
	addu a1, a0                 ; height += width;
	sw a1, VS_GP0(t0)           ; *vs_gp0 = height;
	li a0, VS_CMD_ENABLE_DMA_READ    ; vs_cmd = VS_CMD_ENABLE_DMA_READ;
	sw a0, VS_GP1(t0)           ; *vs_gp1 = vs_cmd;
	mult a2, a3                 
	mflo a0                     ; size = width*height;
	lw a1, 16(sp)
	sra a0, 1                   ; size /= 2;
	sw a1, VS_GPU_DMA(t0)       ; *vs_gpu_dma = data;
	li a1, $10                  ; dma_size = 16;     
	blt a0, a1, CompleteDMARead ; if(size < dma_size) { goto CompleteDMARead; }
	nop                  
vs_align_read:
	andi t1, a0, $f           
	bnez t1, CompleteDMARead    ; if(!(size % 16)) { goto CompleteDMARead; }
	nop
vs_align_read_size:
	addiu a0, 15                ; size += 15;
CompleteDMARead:
	sra a0, a0, 4               ; size /= 16;
	sll a0, a0, 16              ; size <<= 16;
	ori a0, a0, 16    	        ; size |= 16;
	sw a0, VS_GPU_BCR(t0)       ; *gpu_bcr = size;
	li t2, $01000200   	        ; mode = read_mode;
	sw t2, VS_GPU_CHCR(t0)      ; *gpu_chcr = mode;
WaitDMARead:
	lw a1, VS_GPU_CHCR(t0)      ; dma = *vs_gpu_chchr;
	li a2, VS_DMA_ENABLE        ; cmd = VS_DMA_ENABLE; (delay slot)
	and a1, a1, a2              ; dma &= cmd;
	bnez a1, WaitDMARead        ; if(dma) { goto WaitDMA; }
	nop 
	jr ra 
	nop
	
# Function: VS_DMAPaletteDataToVram
# Purpose: Peforms a DMA transfer of word-aligned indexed color palette data by the CPU from main memory to VRAM 
VS_DMAPaletteDataToVram:
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
	sra a0, 1                   ; width >>= 1;
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
	blt a0, a1, CompletePaletteDMA ; if(size < dma_size) { goto CompletePaletteDMA; }
	nop                  
vs_palette_align:
	andi t1, a0, $f           
	bnez t1, CompletePaletteDMA ; if(!(size % 16)) { goto CompletePaletteDMA; }
	nop
vs_pal_align_size:
	addiu a0, 15                ; size += 15;
CompletePaletteDMA:
	sra a0, a0, 4               ; size /= 16;
	sll a0, a0, 16              ; size <<= 16;
	ori a0, a0, 16    	        ; size |= 16;
	sw a0, VS_GPU_BCR(t0)       ; *gpu_bcr = size;
	li t2, $01000201   	        ; mode = write_mode;
	sw t2, VS_GPU_CHCR(t0)      ; *gpu_chcr = mode;
WaitPaletteDMA:
	lw a1, VS_GPU_CHCR(t0)      ; dma = *vs_gpu_chchr;
	li a2, VS_DMA_ENABLE        ; cmd = VS_DMA_ENABLE; (delay slot)
	and a1, a1, a2              ; dma &= cmd;
	bnez a1, WaitPaletteDMA     ; if(dma) { goto WaitPaletteDMA; }
	nop 
	jr ra 
	nop

# Function: VS_DMAIndexImageDataToVram
# Purpose: Peforms a DMA transfer of word-aligned indexed color palette data by the CPU from main memory to VRAM 
# a0: x, a1: y, a2: width, a3: height, 16(sp): data
VS_DMAIndexImageDataToVram:
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
	sra a0, 1                   ; width >>= 1;
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
	blt a0, a1, CompleteIndexDMA ; if(size < dma_size) { goto CompleteIndexDMA; }
	nop                  
vs_dma_align:
	andi t1, a0, $f           
	bnez t1, CompleteIndexDMA   ; if(!(size % 16)) { goto CompleteIndexDMA; }
	nop
vs_dma_align_size:
	addiu a0, 15                ; size += 15;
CompleteIndexDMA:
	sra a0, a0, 4               ; size /= 16;
	sll a0, a0, 16              ; size <<= 16;
	ori a0, a0, 16    	        ; size |= 16;
	sw a0, VS_GPU_BCR(t0)       ; *gpu_bcr = size;
	li t2, $01000201   	        ; mode = write_mode;
	sw t2, VS_GPU_CHCR(t0)      ; *gpu_chcr = mode;
WaitIndexDMA:
	lw a1, VS_GPU_CHCR(t0)      ; dma = *vs_gpu_chchr;
	li a2, VS_DMA_ENABLE        ; cmd = VS_DMA_ENABLE; (delay slot)
	and a1, a1, a2              ; dma &= cmd;
	bnez a1, WaitIndexDMA       ; if(dma) { goto WaitIndexDMA; }
	nop 
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