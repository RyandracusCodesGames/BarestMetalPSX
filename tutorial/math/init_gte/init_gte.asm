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
VS_CMD_FILL_TRIANGLE equ $20000000             ; Draws A Filled Monochrome Triangle to the Display Area
VS_CMD_FILL_SEMI_TRANS_TRIANGLE equ $22000000  ; Draws A Semi-Transparent Filled Monochrome Triangle to the Display Area 
VS_CMD_SHADE_TRIANGLE equ $30000000            ; Draws A Gouraud-Shaded Triangle to the Display Area
VS_CMD_SHADE_SEMI_TRANS_TRIANGLE equ $32000000 ; Draws A Semi-Transparennt, Gouraud-Shaded Triangle to the Display Area

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
InitGTE:
	li t0, $40000000                      ; gte_cmd = enable_gte;
	mfc0 t0, r12                          ; *cop0r12 = gte_cmd; (Enables COP2 from a COP0(System Control Coprocessor) Status Register
	li t0, VS_WIDTH / 2                   ; x_offset = VS_WIDTH / 2;
	sll t0, 16                            ; x_offset <<= 16; (GTE X Screen Offset Register is in 16.16 Fixed Point Format)
	ctc2 t0, r24                          ; *cop2r56 = x_offset;
	li t0, VS_HEIGHT / 2                  ; y_offset = VS_HEIGHT / 2;
	sll t0, 16                            ; y_offset <<= 16; (GTE Y Screen Offset Register is in 16.16 Fixed Point Format)
	ctc2 t0, r25                          ; *cop2r57 = y_offset;
	li t0, VS_WIDTH / 2                   ; dest = VS_WIDTH / 2;
	andi t0, $FFFF                        ; dist &= 0xFFFF;
	ctc2 t0, r26                          ; *cop2r58 = dist;
	li a0, 200                            ; translation_x = 200; 
	li a1, 256                            ; translation_y = 256;
	li a2, 128                            ; translation_z = 128;
	ctc2 a0, r5                           ; *cop2r37 = translation_x;
	ctc2 a1, r6                           ; *cop2r38 = translation_y;
	ctc2 a2, r7                           ; *cop2r39 = translation_z;
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
DrawTriangles:
	li a0, 80                            ; x1 = 80;
	li a1, 140 						     ; y1 = 140;
	li a2, 130						     ; x2 = 130;
	li a3, 50                            ; y2 = 50;
	li t1, 180                           ; x3 = 180; 
	li t2, 140                           ; y4 = 140;
	li t3, $0000FF                       ; color1 = 0x0000FF;
	li t4, $00FF00                       ; color2 = 0x00FF00;
	li t5, $FF0000                       ; color3 = 0xFF0000;
	sw t1, 16(sp) 
	sw t2, 20(sp) 
	sw t3, 24(sp) 
	sw t4, 28(sp) 
	sw t5, 32(sp) 
	jal VS_ShadeTriangle                 ; VS_ShadeTriangle(x1,y1,x2,y2,x3,y3,color1,color2,color3);
	nop
	jal VS_DrawSync                      ; VS_DrawSync();
	nop
	li a0, 70                            ; x1 = 70;
	li a1, 140 						     ; y1 = 140;
	li a2, 120						     ; x2 = 120;
	li a3, 50                            ; y2 = 50;
	li t1, 50                            ; x3 = 50; 
	li t2, 70                            ; y4 = 70;
	li t3, $0000FF                       ; color1 = 0x0000FF;
	sw t1, 16(sp) 
	sw t1, 16(sp) 
	sw t2, 20(sp) 
	sw t3, 24(sp) 
	jal VS_FillTriangle                  ; VS_FillTriangle(x1,y1,x2,y2,x3,y3,color1);
	nop
	jal VS_DrawSync                      ; VS_DrawSync();
	nop
	li a0, 190                           ; x1 = 190;
	li a1, 140 						     ; y1 = 140;
	li a2, 140						     ; x2 = 140;
	li a3, 50                            ; y2 = 50;
	li t1, 200                           ; x3 = 200; 
	li t2, 70                            ; y4 = 70;
	li t3, $FF0000                       ; color1 = 0xFF0000;
	sw t1, 16(sp) 
	sw t1, 16(sp) 
	sw t2, 20(sp) 
	sw t3, 24(sp) 
	jal VS_FillSemiTransTriangle         ; VS_FillSemiTransTriangle(x1,y1,x2,y2,x3,y3,color1);
	nop
	jal VS_DrawSync                      ; VS_DrawSync();
	nop
	li a0, 80                            ; x1 = 80;
	li a1, 140 						     ; y1 = 140;
	li a2, 130						     ; x2 = 130;
	li a3, 210                           ; y2 = 210;
	li t1, 180                           ; x3 = 180; 
	li t2, 140                           ; y4 = 140;
	li t3, $0000FF                       ; color1 = 0x0000FF;
	li t4, $00FF00                       ; color2 = 0x00FF00;
	li t5, $FF0000                       ; color3 = 0xFF0000;
	sw t1, 16(sp) 
	sw t2, 20(sp) 
	sw t3, 24(sp) 
	sw t4, 28(sp) 
	sw t5, 32(sp) 
	jal VS_ShadeSemiTransTriangle        ; VS_ShadeSemiTransTriangle(x1,y1,x2,y2,x3,y3,color1,color2,color3);
	nop
	jal VS_DrawSync                      ; VS_DrawSync();
	nop
	li a0, 10                            ; x1 = 10;
	li a1, 200						     ; y1 = 200;
	li a2, 60						     ; x2 = 60;
	li a3, 140                           ; y2 = 140;
	li t1, 120                           ; x3 = 120; 
	li t2, 200                           ; y4 = 200;
	li t3, $0000FF                       ; color1 = 0x0000FF;
	sw t1, 16(sp) 
	sw t1, 16(sp) 
	sw t2, 20(sp) 
	sw t3, 24(sp) 
	jal VS_FillTriangle                  ; VS_FillTriangle(x1,y1,x2,y2,x3,y3,color1);
	nop
	jal VS_DrawSync                      ; VS_DrawSync();
	nop
	li a0, 10                            ; x1 = 10;
	li a1, 220 						     ; y1 = 220;
	li a2, 60						     ; x2 = 60;
	li a3, 160                           ; y2 = 160;
	li t1, 120                           ; x3 = 120; 
	li t2, 220                           ; y4 = 220;
	li t3, $00FF00                       ; color1 = 0x00FF00;
	sw t1, 16(sp) 
	sw t1, 16(sp) 
	sw t2, 20(sp) 
	sw t3, 24(sp) 
	jal VS_FillSemiTransTriangle         ; VS_FillSemiTransTriangle(x1,y1,x2,y2,x3,y3,color1);
	nop
	jal VS_DrawSync                      ; VS_DrawSync();
	nop
main:
	b main 
	nop
	addi sp, 64
	
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