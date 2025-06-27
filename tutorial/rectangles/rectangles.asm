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
DrawRectangles:
	li a0, 128                            ; x = 128;
	li a1, 120                            ; y = 120;
	li a2, 64                             ; w = 64;
	li a3, 64                             ; h = 64;
	li t1, $FF0000                        ; color = 0x82004b;
	sw t1, 16(sp)
	jal VS_FillRectangle                  ; VS_FillRectangle(x,y,w,h,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 80                             ; x = 100;
	li a1, 140                            ; y = 120;
	li a2, 64                             ; w = 64;
	li a3, 64                             ; h = 64;
	li t1, $0000FF                        ; color = 0xFF0000;
	sw t1, 16(sp)
	jal VS_FillSemiTransRectangle         ; VS_FillSemiTransRectangle(x,y,w,h,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 20                             ; x = 20;
	li a1, 20                             ; y = 20;
	li a2, $1B52F1                        ; color = 0x1B52F1;
	jal VS_Fill16x16Rectangle             ; VS_Fill16x16Rectangle(x,y,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 40                             ; x = 400;
	li a1, 20                             ; y = 120;
	li a2, $29cd80                        ; color = 29cd80;
	jal VS_Fill16x16Rectangle             ; VS_Fill16x16Rectangle(x,y,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 20                             ; x = 20;
	li a1, 40                             ; y = 40;
	li a2, $efad00                        ; color = 0xefad00;
	jal VS_Fill16x16Rectangle             ; VS_Fill16x16Rectangle(x,y,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 40                             ; x = 40;
	li a1, 40                             ; y = 40;
	li a2, $9bcfa                         ; color = 0x9bcfa;
	jal VS_Fill16x16Rectangle             ; VS_Fill16x16Rectangle(x,y,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 140                            ; x = 40;
	li a1, 40                             ; y = 40;
	li a2, $00FF00                        ; color = 0x00FF00;
	jal VS_Fill8x8Rectangle               ; VS_Fill8x8Rectangle(x,y,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 55                             ; x = 55;
	li a1, 100                            ; y = 100;
	li a2, $82004B                        ; color = 0x82004B;
	jal VS_Fill8x8Rectangle               ; VS_Fill8x8Rectangle(x,y,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
	li a0, 80                             ; x = 80;
	li a1, 100                            ; y = 100;
	li a2, $82004B                        ; color = 0x82004B;
	jal VS_DrawPixel                      ; VS_DrawPixel(x,y,color);
	nop 
	jal VS_DrawSync                       ; VS_DrawSync();
	nop
main:
	b main 
	nop
	addi sp, 64
	
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