#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# Smooth Horizontal Scrolling Platformer
#-----------------------------------------------------------
# Objective
#-----------------------------------------------------------
#
#-----------------------------------------------------------
# Controls
#-----------------------------------------------------------
#
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

; (U,V) Texture Coordinate Pairs Are Sent by Writing the UV Coordinates to the lower 16-bits of the 32-bit register.
; The U-Coordinate is sent to the lower 8-bits and the V-Coordinate to the Upper 8-bits 
; ex: u = a0, v = a1 
; andi a0, a0, 0xFF 
; sll a1, a1, 8 
; addu a1, a1, a0 
; sw a1, VS_GP0(t0)

; PlayStation GPU1 Display Values
VS_HRANGE equ $C4E24E
VS_VRANGE equ $040010 
VS_HORZ_RES_256 equ 0 
VS_HORZ_RES_320 equ 1 
VS_NTSC equ 0 
VS_PAL equ 8
VS_DISP_X1 equ 0 
VS_DISP_Y1 equ 240 
VS_DISP_X2 equ 256 
VS_DISP_Y2 equ 480
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
VS_CMD_DRAW_LINE equ $40000000            ; Draws A Monochrome Line to the Display Area
VS_CMD_FILL_RECT equ $60000000            ; Draws A Monochrome Rectangle to the Display Area
VS_TEXTURE_FOUR_POINT_POLY equ $2D000000  ; Draws An Opaque Textured Quad to the Display Area

; PlayStation JoyPad Commands and Variables
VS_CMD_INIT_PAD equ $15
VS_JOY_UP equ $1000 
VS_JOY_DOWN equ $4000
VS_JOY_LEFT equ $8000
VS_JOY_RIGHT equ $2000
VS_JOY_X equ $0040

VS_RED equ 0 
VS_GREEN equ 128 
VS_BLUE equ 255

VS_FONTW equ 8 
VS_FONTH equ 11

; IMMUTABLE GAME VARIABLES
VS_TILE_W equ 16 
VS_TILE_H equ 16
VS_GROUND_VRAM_X equ 256 
VS_GROUND_VRAM_Y equ 0
VS_BRICK_VRAM_X equ 512 
VS_BRICK_VRAM_Y equ 0
VS_BLOCK_VRAM_X equ 256 
VS_BLOCK_VRAM_Y equ 256
VS_QUESTION_VRAM_X equ 512 
VS_QUESTION_VRAM_Y equ 256
VS_MONTAGNE1_VRAM_X equ 320 
VS_MONTAGNE1_VRAM_Y equ 0
VS_MONTAGNE2_VRAM_X equ 384 
VS_MONTAGNE2_VRAM_Y equ 0
VS_MONTAGNE3_VRAM_X equ 448 
VS_MONTAGNE3_VRAM_Y equ 0
VS_MONTAGNE4_VRAM_X equ 320 
VS_MONTAGNE4_VRAM_Y equ 256
VS_MONTAGNE5_VRAM_X equ 448 
VS_MONTAGNE5_VRAM_Y equ 256
VS_MONTAGNE6_VRAM_X equ 576 
VS_MONTAGNE6_VRAM_Y equ 0
VS_COIN_VRAM_X equ 640 
VS_COIN_VRAM_Y equ 0
; MUTABLE GAME VARIABLES
VS_PLAYER_X equ (VS_WIDTH / 2)
VS_PLAYER_Y equ 200
VS_VELOCITY equ 1 

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
	addi sp, -80
UploadTilemapToVram:
	la s0, Tilemap                        ; tilemap = (unsigned long*)Tilemap;
	li a0, VS_GROUND_VRAM_X               ; vram_x = VS_GROUND_VRAM_X;
	li a1, VS_GROUND_VRAM_Y               ; vram_y = VS_GROUND_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, GroundTile                     ; data = GroundTile;
	sw a0, 0(s0)                          ; tilemap[0] = vram_x;
	sw a1, 4(s0)                          ; tilemap[1] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_BRICK_VRAM_X                ; vram_x = VS_BRICK_VRAM_X;
	li a1, VS_BRICK_VRAM_Y                ; vram_y = VS_BRICK_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, BrickTile                      ; data = BrickTile;
	sw a0, 8(s0)                          ; tilemap[2] = vram_x;
	sw a1, 12(s0)                         ; tilemap[3] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_BLOCK_VRAM_X                ; vram_x = VS_BLOCK_VRAM_X;
	li a1, VS_BLOCK_VRAM_Y                ; vram_y = VS_BLOCK_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, BlockTile                      ; data = BlockTile;
	sw a0, 16(s0)                         ; tilemap[4] = vram_x;
	sw a1, 20(s0)                         ; tilemap[5] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_QUESTION_VRAM_X             ; vram_x = VS_QUESTION_VRAM_X;
	li a1, VS_QUESTION_VRAM_Y             ; vram_y = VS_QUESTION_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, QuestionTile                   ; data = QuestionTile;
	sw a0, 24(s0)                         ; tilemap[6] = vram_x;
	sw a1, 28(s0)                         ; tilemap[7] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_MONTAGNE1_VRAM_X            ; vram_x = VS_MONTAGNE1_VRAM_X;
	li a1, VS_MONTAGNE1_VRAM_Y            ; vram_y = VS_MONTAGNE1_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, MontagneTile1                  ; data = MontagneTile1;
	sw a0, 32(s0)                         ; tilemap[8] = vram_x;
	sw a1, 36(s0)                         ; tilemap[9] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_MONTAGNE2_VRAM_X            ; vram_x = VS_MONTAGNE2_VRAM_X;
	li a1, VS_MONTAGNE2_VRAM_Y            ; vram_y = VS_MONTAGNE2_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, MontagneTile2                  ; data = MontagneTile2;
	sw a0, 40(s0)                         ; tilemap[10] = vram_x;
	sw a1, 44(s0)                         ; tilemap[11] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_MONTAGNE3_VRAM_X            ; vram_x = VS_MONTAGNE3_VRAM_X;
	li a1, VS_MONTAGNE3_VRAM_Y            ; vram_y = VS_MONTAGNE3_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, MontagneTile3                  ; data = MontagneTile3;
	sw a0, 48(s0)                         ; tilemap[12] = vram_x;
	sw a1, 52(s0)                         ; tilemap[13] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_MONTAGNE4_VRAM_X            ; vram_x = VS_MONTAGNE4_VRAM_X;
	li a1, VS_MONTAGNE4_VRAM_Y            ; vram_y = VS_MONTAGNE4_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, MontagneTile4                  ; data = MontagneTile4;
	sw a0, 56(s0)                         ; tilemap[14] = vram_x;
	sw a1, 60(s0)                         ; tilemap[15] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_MONTAGNE5_VRAM_X            ; vram_x = VS_MONTAGNE5_VRAM_X;
	li a1, VS_MONTAGNE5_VRAM_Y            ; vram_y = VS_MONTAGNE5_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, MontagneTile5                  ; data = MontagneTile5;
	sw a0, 64(s0)                         ; tilemap[16] = vram_x;
	sw a1, 68(s0)                         ; tilemap[17] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_MONTAGNE6_VRAM_X            ; vram_x = VS_MONTAGNE6_VRAM_X;
	li a1, VS_MONTAGNE6_VRAM_Y            ; vram_y = VS_MONTAGNE6_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, MontagneTile6                  ; data = MontagneTile6;
	sw a0, 72(s0)                         ; tilemap[18] = vram_x;
	sw a1, 76(s0)                         ; tilemap[19] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
	li a0, VS_COIN_VRAM_X                 ; vram_x = VS_COIN_VRAM_X;
	li a1, VS_COIN_VRAM_Y                 ; vram_y = VS_COIN_VRAM_Y;
	li a2, VS_TILE_W                      ; image_w = VS_TILE_W;
	li a3, VS_TILE_H                      ; image_h = VS_TILE_H;
	la t1, CoinTile                       ; data = CoinTile;
	sw a0, 80(s0)                         ; tilemap[20] = vram_x;
	sw a1, 84(s0)                         ; tilemap[21] = vram_y;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
InitPad: 
    li t1,VS_CMD_INIT_PAD                 ; OutdatedPadInitAndStart() Function Is $15
    li a0, $20000001
    li t2, $B0                            ; Call a B-Type BIOS Function 
    la a1, PadBuffer                      ; Set Pad Buffer Address To Automatically Update Each Frame
    jalr t2                               ; Jump To BIOS Routine OutdatedPadInitAndStart()
    nop ; Delay Slot
Input:
PRESSLEFT:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop                  
    andi t0, VS_JOY_LEFT                  ; pad_data &= VS_JOY_LEFT;
    beqz t0, PRESSRIGHT         		  ; if(!pad_data) { goto PRESSRIGHT; }
    nop 
	lw t0, MapObject                      ; offset_x = MapObject->offset_x;
	nop 
	subi t0, VS_VELOCITY                  ; offset_x -= VS_VELOCITY;
	blez t0, PRESSRIGHT                   ; if(offset_x <= 0) { goto PRESSRIGHT; }
	nop 
	sw t0, MapObject                      ; MapObject->offset_x = offset_x;
PRESSRIGHT:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_RIGHT                 ; pad_data &= VS_JOY_RIGHT;
    beqz t0, FillScreen    		          ; if(!pad_data){ goto FillScreen; }
    nop  
	lw t0, MapObject                      ; offset_x = MapObject->offset_x;
	nop 
	addi t0, VS_VELOCITY                  ; offset_x += VS_VELOCITY;
	sw t0, MapObject                      ; MapObject->offset_x = offset_x;
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
	la t0, MapObject                      
	lw t1, 0(t0)                          ; offset_x = MapObject->offset_x;         
	lw t2, 4(t0)                          ; real_num_of_cols = MapObject->length;
	addi t1, 16                           ; offset_x += 16;
	ble t1, t2, DrawTilemap               ; if(offset_x <= real_num_of_cols) { goto DrawTilemap; } 
	nop 
	subi t2, 16
	sw t2, MapObject                      ; offset_x = real_num_of_cols;
DrawTilemap:
	la t0, MapObject                       
	la s0, MapFile                        ; map_file = MapFile;
	la s1, Tilemap                        ; tilemap = Tilemap;
	li s3, 14                             ; num_of_rows = 14;
	lw s7, 0(t0)                          ; offset_x = MapObject->offset_x;
	li s4, 0                              ; start_x = 0;
	li s5, 0                              ; start_y = 0;
	la t0, MapObject                       
	lw s2, 4(t0)                          ; real_num_of_cols = MapObject->length;
	move t4, zero                         ; tile_y = 0;
DrawRow:                  
	li s6, 16                          	  ; num_of_cols = 16;
	move s4, zero                         ; start_x = 0;
	move t3, zero                         ; tile_x = 0;
DrawColumn:
	mult t4, s2                           ; tile_offset = tile_y * real_num_of_cols;
	mflo t5 
	addu t5, t3                           ; tile_offset += tile_x;
	addu t5, s7                           ; tile_offset += offset_x;
	addu t5, s0, t5                       ; tile_offset = MapFile + tile_offset;
	lbu t0, 0(t5)                         ; tile = *MapFile;
	subi s6, 1                            ; num_of_cols--; (Delay Slot)
	beqz t0, PrepareNextColumn            ; if(tile == 0) { PrepareNextColumn; }
	nop
	subi t0, 1                            ; tile--;
	sll t0, 3                             ; tile <<= 3;
	addu t0, s1, t0                       ; tilemap_offset = tilemap + tile;
TextureColumn:
	li a0, 2                              ; mode = 2;
	li a1, 1                              ; alpha = 1;
	lw a2, 0(t0)                          ; vram_x = tilemap[0]->vram_x;
	lw a3, 4(t0)                          ; vram_y = tilemap[0]->vram_y;
	nop
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	move a0, s4                           ; x = start_x;
	move a1, s5                           ; y = start_y;
	addi a1, 8                            ; y += 8;
	move a2, v0          
	jal VS_TextureTile                    ; VS_TextureTile(x,y,texpage);
	nop
PrepareNextColumn:
	addi t3, 1                            ; tile_x++;
	bnez s6, DrawColumn                   ; if(num_of_cols != 0) { goto DrawColumn; }
	addi s4, VS_TILE_W                    ; start_x += VS_TILE_W; (Delay Slot)
	subi s3, 1                            ; num_of_rows--;
	addi t4, 1                            ; tile_y++;
	bnez s3, DrawRow                      ; if(num_of_rows != 0) { goto DrawRow; }
	addi s5, VS_TILE_H                    ; start_y += VS_TILE_H (Delay Slot) 
BufferSwap:
	li t0, VS_IO
	li t1, VS_VRAM_TO_VRAM                ; vs_cmd = VS_VRAM_TO_VRAM;
	sw t1, VS_GP0(t0)                     ; *vs_gp0 = vs_cmd;
	li t2, VS_DISP_X1                     ; x1 = VS_DISP_X1;
	li t3, VS_DISP_Y1                     ; y1 = VS_DISP_Y1;
	andi t2, $FFFF                        ; x1 &= $FFFF;
	sll t3, t3, $10                       ; y1 <<= 16;
	addu t3, t2                           ; y1 += x1;
	sw t3, VS_GP0(t0)                     ; *vs_gp0 = y1;
	sw zero, VS_GP0(t0)                   ; *vs_gp0 = 0;
	li t2, VS_WIDTH                       ; x2 = VS_WIDTH;
	li t3, VS_HEIGHT                      ; y2 = VS_HEIGHT;
	andi t2, $FFFF                        ; x2 &= $FFFF;
	sll t3, t3, $10                       ; y2 <<= 16;
	addu t3, t2                           ; y2 += x2;
	sw t3, VS_GP0(t0)                     ; *vs_gp0 = y2;
	la a1, PadBuffer                      ; pad_addr = PadBuffer;
WaitVSync:                                ; Wait For Vertical Retrace Period & Store XOR Pad Data
	lw t0, 0(a1)                          ; data_sent = *(unsigned long*)pad_addr;
	nop                                   
	beqz t0, WaitVSync 					  ; if(!data_sent) { goto WaitVSync; }
	nor t0, r0    						  ; data_sent = !(data_sent | 0); (Delay Slot)
	sw r0,0(a1)                           ; *(unsigned long*)pad_addr = 0;
	sw t0, PadData                        ; *(unsigned long*)PadData = data_sent;
main:
	b Input 
	nop
	addi sp, 80
	
# Function: DetectAABBCollision
# Purpose: Detects whether or two rectangles are colliding with one another 
# a0: x1, a1: y1, a2: w1, a3: h1, 16(sp): x2, 20(sp): y2, 24(sp): w2, 28(sp): h2 
DetectAABBCollision:
	lw t1, 16(sp)
	add t0, a0, a2        ; size1 = x1 + w1;
	ble t0, t1, AABBFalse ; if(size1 < x2) { collide = false; goto AABBFalse; }
	lw t2, 24(sp) 
	nop
	add t0, t1, t2        ; size2 = x2 + w2;
	bge a0, t0, AABBFalse ; if(x1 >= size2) { collide = false; goto AABBFalse; }
	lw t2, 20(sp)
	add t1, a1, a3        ; size1 = y1 + h1;
	ble t1, t2, AABBFalse ; if(size1 < y2) { collide = false; goto AABBFalse; }
	lw t4, 28(sp)
	nop
	add t3, t2, t4        ; size2 = y2 + h2;
	bge a1, t3, AABBFalse ; if(y1 < size2) { collide = false; goto AABBFalse; }
	li v0, 1 
	jr ra 
	nop
AABBFalse:
	li v0, 0 
	jr ra 
	nop
	
# Function: VS_DrawMonochromeLine
# Purpose: Draws a monochrome line to the display area using the GPU 
# a0: x1, a1: y1, a2: x2, a3: y2, 16(sp): color
VS_DrawMonochromeLine:
	lw t2, 16(sp)
	li t0, VS_IO             ; vs_io_addr = (unsigned long*)0x1F800000;
	li t1, VS_CMD_DRAW_LINE  ; vs_cmd = VS_CMD_DRAW_LINE;
	addu t1, t2              ; vs_cmd += color;
	sw t1, VS_GP0(t0)        ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF           ; x1 &= 0xFFFF;
	sll a1, 16               ; y1 <<= 16;
	addu a1, a0              ; y1 += x;
	sw a1, VS_GP0(t0)        ; *vs_gp0 = y1;
	andi a2, $FFFF           ; x2 &= 0xFFFF;
	sll a3, 16               ; y2 <<= 16;
	addu a3, a2              ; y2 += x;
	sw a3, VS_GP0(t0)        ; *vs_gp0 = y2;
	jr ra 
	nop
	
# Function: VS_FillMonochromeRect
# Purpose: Draws a filled monochrome rectangle to the display area 
# a0: x, a1: y, a2: w, a3: h, 16(sp): color 
VS_FillMonochromeRect:
	li t0, VS_IO
	lw t1, 16(sp)
	li t2, VS_CMD_FILL_RECT  ; vs_cmd = VS_CMD_FILL_RECT;
	addu t2, t1              ; vs_cmd += color;
	sw t2, VS_GP0(t0)        ; *vs_gp0 = vs_cmd;
	andi a0, $FFFF           ; x &= $FFFF;
	sll a1, $10              ; y <<= 16;
	addu a1, a0              ; y += x;
	sw a1, VS_GP0(t0)        ; *vs_gp0 = y;
	andi a2, $FFFF           ; w &= $FFFF;
	sll a3, $10              ; h <<= 16;
	addu a3, a2              ; h += w;
	sw a3, VS_GP0(t0)        ; *vs_gp0 = h;
	jr ra 
	nop
	
# Function: VS_TextureFourPointPoly
# Purpose: Draws a textured four-point polygon, a quad, to the display area using the GPU 
# a0: x1, a1: y1, a2: palette, a3: u1, 16(sp): v1, 20(sp): x2, 24(sp): y2, 28(sp): texpage, 32(sp): u2, 36(sp): v2, 40(sp): x3, 44(sp): y3, 48(sp): u3, 52(sp): v3
# 56(sp): x4, 60(sp): y4, 64(sp): u4, 68(sp): v4
VS_TextureFourPointPoly:         
	li   t0, VS_IO                      ; vs_io_addr = (unsigned long*)0x1F800000;
	li   t1, VS_TEXTURE_FOUR_POINT_POLY ; gpu0_cmd = VS_TEXTURE_FOUR_POINT_POLY;
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
	
# Function: VS_TextureTile
# Purpose: Textures a 16x16 tile to the (X,Y) screen coordinates
# a0: x, a1: y, a2: texpage
VS_TextureTile:
	subi sp, sp, 80 
	sw ra, 4(sp)
	move t0, a2
	li a2, $0            ; palette = 0;
	li a3, $0            ; u1 = 0;
	sw zero, 16(sp)      ; v1 = 0;
	sw a0, 20(sp)        ; x2 = x;
	li t1, VS_TILE_H
	add t1, t1, a1 
	sw t1, 24(sp)        ; y2 = y + VS_TILE_H;
	sw t0, 28(sp)        ; texpage = GetTexturePage(2,1,x,y); 
	sw zero, 32(sp)      ; u2 = 0;
	li t1, VS_TILE_H 
	sw t1, 36(sp)        ; v2 = VS_TILE_H;
	li t1, VS_TILE_W 
	addu t1, t1, a0
	sw t1, 40(sp)        ; x3 = x + VS_TILE_W;
	sw a1, 44(sp)        ; y3 = y;
	li t1, VS_TILE_W 
	sw t1, 48(sp)        ; u3 = VS_TILE_W;
	sw zero, 52(sp)      ; v3 = 0;
	li t1, VS_TILE_W 
	add t1, t1, a0
	sw t1, 56(sp)        ; x4 = x + VS_TILE_W;
	li t1, VS_TILE_H 
	add t1, t1, a1 
	sw t1, 60(sp)        ; y4 = y + VS_TILE_H;
	li t1, VS_TILE_W 
	sw t1, 64(sp)        ; u4 = VS_TILE_W;
	li t1, VS_TILE_H 
	sw t1, 68(sp)        ; v4 = VS_TILE_H;
	jal VS_TextureFourPointPoly
	nop
	jal DrawSync
	nop
	lw ra, 4(sp)
	addi sp, sp, 80
	jr ra 
	nop
	
# Function: DrawSync
# Purpose: Halts program execution until all drawing commands have been executed by the gpu 
DrawSync:
	li a0, VS_IO             ; vs_io_addr = (unsigned long*)$1F800000;
DrawSyncLoop:
	lw a1, VS_GP1(a0)        ; gpu1 = *vs_gpu1;
	li a2, VS_CMD_STAT_READY ; gpu1_cmd = VS_CMD_STAT_READY; (delay slot)
	and a1, a1, a2           ; gpu1 &= gpu1_cmd;
	beqz a1, DrawSyncLoop    ; if(gpu1 == 0) { goto DrawSyncLoop; }
	nop 
	jr ra
	nop
	
# Function: DMASync
# Purpose: Halts program execution until all gpu dma transfers have completed
DMASync:
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
	
# Function: TransferImageDataToVram
# Purpose: Performs a manual memory transfer of 16-bit word-aligned image data to VRAM
# a0: x, a1: y, a2: w, a3: h, 16(sp): data
TransferImageDataToVram:
	li t0, VS_IO            
	li t1, VS_CMD_CLEAR_CACHE ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t1, VS_GP0(t0)         ; *vs_gp0 = vs_cmd;
	li t1, VS_CPU_TO_VRAM   ; vs_cmd = VS_CPU_TO_VRAM;
	sw t1, VS_GP0(t0)       ; *vs_gp0 = vs_cmd;
	mult a2, a3             ; size = w * h;
	mflo t1 
	andi a0, $FFFF          ; x &= 0xFFFF;
	sll a1, $10             ; y <<= 16;
	addu a1, a0             ; y += x;
	sw a1, VS_GP0(t0)       ; *vs_gp0 = y;
	andi a2, $FFFF          ; w &= 0xFFFF;
	sll a3, $10             ; h <<= 16;
	addu a3, a2             ; h += w;
	sw a3, VS_GP0(t0)       ; *vs_gp0 = h;
	sll t1, 1               ; size <<= 1;
	lw  a0, 16(sp)        
	sra t1, 2               ; size /= 4;
TransferDataLoop:
	lw t2,0(a0)             ; word = *(unsigned long*)data;
	addiu a0,  $4           ; data += 4; (Delay Slot)
	subi t1, 1                ; size--;
	bnez t1, TransferDataLoop ; if(size != 0) { goto TransferDataLoop; }
	sw t2, VS_GP0(t0)       ; *vs_gpu0 = word; (Delay Slot)
	jr ra 
	nop
	
# Function: VS_DrawString
# Purpose: Draws a string to the display area 
# a0: x, a1: y, a2: string
VS_DrawString:
	addiu sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
	move t1, a0          ; orgx = x;
	move t2, a1          ; orgy = y;
	li t0, VS_IO
	li t3, VS_FONTW      ; w = VS_FONTW;
	li t4, VS_FONTH      ; h = VS_FONTH;
	sll t4, t4, 0x10     ; h <<= 16;
	addu t5, t4, t3      ; size = h +  w;
DrawChar:
	lbu a0, 0(a2)        ; c = *string;
	addiu a2, a2, 0x1    ; string++; (delay slot)
	beqz a0, end 
	li t3, 32
	beq  a0, t3, vs_draw_space
	nop
	li t3, 10
	beq  a0, t3, vs_draw_new_line
	nop
	jal VS_CharData        ; data = VS_CharData(c);
	li t3, VS_CMD_CLEAR_CACHE ; vs_cmd = VS_CMD_CLEAR_CACHE;
	sw t3, VS_GP0(t0)         ; *vs_gp0 = vs_cmd;
	li t3, VS_CPU_TO_VRAM ; gpu0_cmd = VS_CPU_TO_VRAM; (delay slot)
	sw t3, VS_GP0(t0)    ; *vs_gp0 = gpu0_cmd;
	andi t1, t1, 0xFFFF  ; x &= 0xFFFF;
	sll t3, a1, 0x10     ; y <<= 16;
	addu t3, t3, t1     ; y += x;
	sw t3, VS_GP0(t0)    ; *vs_gp0 = y;
	sw t5, VS_GP0(t0)    ; *vs_gp0 = size;
	li t3, VS_FONTW       ; w = VS_FONTW;
	li t4, VS_FONTH       ; h = VS_FONTH;
	addu t1, t1, t3     ; x += w;
	mult t3, t4          ; size = w * h;
	mflo t3 
	sll t3, t3, 0x1      ; size <<= 1;
	sra t3, t3, 0x2      ; size /= 4;
TransferLoop:
	lw t4,0(v0)
	addiu v0, v0, 0x4
	sw t4, VS_GP0(t0)
	bnez t3, TransferLoop
	subi t3, t3, 0x1
	b DrawChar
	nop
vs_draw_space:
	b   DrawChar
	addi t1, t1, VS_FONTW ; x += VS_FONTW;
vs_draw_new_line:
	b   DrawChar
	addi a1, a1, VS_FONTH ; y += VS_FONTH;
end:
	lw ra, 0(sp)
    lw s0, 4(sp)
    addiu sp, sp, 8
    jr ra
	nop
	
# Function: VS_Int2String
# Purpose: Converts an integer into an ASCII string
# a0: string, a1: int
VS_Int2String:
	li t0, 0         		 ; digits = 0;
	bgez a1, InitCountDigits ; if(int >= 0) { goto InitCountDigits; }
	li v1, 0
Abs:
	li v1, 1
	li t1, 45                ; char = '-';
	sb t1, 0(a0)             ; *string = char;
	addi a0, 1               ; string++;
	sub a1, zero, a1         ; int = 0 - int;
InitCountDigits:
	li t1, 10        		 ; base = 10;
	move t2, a1        		 ; tempInt = int; 
CountDigits:
	divu t2, t1              ; tempInt /= base;
	mflo t2       
	addi t0, 1               ; digits++;
	bgtz t2, CountDigits     ; if(tempInt > 0) { goto CountDigits; }
	nop
ConvertInt:
	subi t2, t0, 1   		 ; tempDigits = digits - 1;
	add a0, t2   		     ; buf += tempDigits;
ConvertLoop:         
	divu  a1, t1             ; result = int % base;
	mfhi  t3
	addi  t3, $30            ; result += $30;
	sb    t3, 0(a0)          ; *string = result;
	mflo  a1 
	bgtz  a1, ConvertLoop    ; if(int > 0) { goto ConvertLoop; }
	subi  a0, 1              ; string--;
	beqz v1, finish_digits   ; if(!neg) { goto finish_digits; }
	nop
	addi t0, 1               ; digits++;
finish_digits:
	move v0, t0
	jr ra 
	nop	
	
.include "../lib/string.asm"
	
# Function: VS_CharData
# Purpose: Returns the image data of the input character
# a0: c
VS_CharData:
	li  t7, 45
	beq a0, t7, vs_char_minus
	nop
	li  t7, 48
	beq a0, t7, vs_char_zero 
	li  t8, 49
	beq a0, t8, vs_char_one 
	li  t7, 50 
	beq a0, t7, vs_char_two
	li  t8, 51 
	beq a0, t8, vs_char_three
	li  t7, 52 
	beq a0, t7, vs_char_four
	li  t8, 53 
	beq a0, t8, vs_char_five
	li  t7, 54 
	beq a0, t7, vs_char_six
	li  t8, 55 
	beq a0, t8, vs_char_seven
	li  t7, 56 
	beq a0, t7, vs_char_eight
	li  t8, 57 
	beq a0, t8, vs_char_nine
	li t7, 65
	blt a0, t7, vs_char_zero
	li  t8, 90
	bgt a0, t8, vs_char_zero 
	nop
	la v0, Font                 ; addr = Font;
	li t7, VS_FONTW * VS_FONTH  ; size = VS_FONTW * VS_FONTH;
	subiu a0, 65                ; offset = char - 'A';
	mult a0, t7                 ; offset = offset * size;
	mflo a0 
	sll a0, 1                   ; offset <<= 1;
	addu v0, a0                 ; addr += offset;
	jr ra
	nop
vs_char_zero:
	la v0, VS_0
	jr ra
	nop
vs_char_one:
	la v0, VS_1
	jr ra
	nop	
vs_char_two:
	la v0, VS_2
	jr ra
	nop
vs_char_three:
	la v0, VS_3
	jr ra
	nop
vs_char_four:
	la v0, VS_4
	jr ra
	nop	
vs_char_five:
	la v0, VS_5
	jr ra
	nop
vs_char_six:
	la v0, VS_6
	jr ra
	nop
vs_char_seven:
	la v0, VS_7
	jr ra
	nop
vs_char_eight:
	la v0, VS_8
	jr ra
	nop	
vs_char_nine:
	la v0, VS_9
	jr ra
	nop
vs_char_minus:
	la v0, VS_minus
	jr ra
	nop
	
.include "../lib/audio.asm"

.data
PadBuffer:
	.dw 0 

PadData:
	.dw 0

PlayerLives:
	.dw 0 
	
Score:
	.dw 0 
	
HighScore:
	.dw 0
	
VS_0: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $0 
	.dh $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff, $0, $0, $7fff, $0
	.dh $0, $7fff, $0, $7fff, $0, $0, $7fff, $0, $7fff, $0, $0, $7fff, $0, $0, $7fff, $7fff, $0, $0, $0, $7fff, $0 
	.dh $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0

VS_1: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $0, $0, $0, $0, $0 
	.dh $7fff, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0 
	.dh $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff 
	.dh $7fff, $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0

VS_2: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0
	.dh $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff
	.dh $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $7fff, $7fff
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0

VS_3: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0 
	.dh $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0 
	.dh $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff 
	.dh $7fff, $7fff, $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0

VS_4: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $7fff
	.dh $0, $0, $0, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $7fff, $7fff, $0, $0, $0 
	.dh $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0
	.dh $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
	
VS_5: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $7fff, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0 
	.dh $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $0
	.dh $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff 
	.dh $7fff, $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0

VS_6: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $7fff
	.dh $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0, $0
	.dh $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff, $7fff 
	.dh $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0

VS_7: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0 
	.dh $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0
	.dh $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0 
	.dh $0, $0, $0, $0, $0, $0, $0

VS_8: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $7fff
	.dh $0, $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0 
	.dh $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff 
	.dh $7fff, $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0

VS_9: 
	.dh $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $0, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0 
	.dh $7fff, $0, $0, $0, $0, $7fff, $0, $0, $7fff, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff, $7fff, $7fff, $7fff, $0, $0 
	.dh $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $0, $0, $0, $0, $7fff, $0, $0, $0, $7fff, $7fff 
	.dh $7fff, $7fff, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
	
VS_minus: 
	.dh 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
	.dh 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $7fff, $7fff, $7fff, $7fff, $7fff, $7fff, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.dh 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.align, 4
Font:
	.incbin "font.bin"
	
GroundTile:
	.incbin "ground.bin"
	
BrickTile:
	.incbin "brick.bin"
	
BlockTile:
	.incbin "block.bin"
	
QuestionTile:
	.incbin "question.bin"
	
MontagneTile1:
	.incbin "montagne1.bin"
	
MontagneTile2:
	.incbin "montagne2.bin"
	
MontagneTile3:
	.incbin "montagne3.bin"
	
MontagneTile4:
	.incbin "montagne4.bin"
	
MontagneTile5:
	.incbin "montagne5.bin"
	
MontagneTile6:
	.incbin "montagne6.bin"
	
CoinTile:
	.incbin "coin.bin"
	
ScoreText:
	.ascii "SCORE"
	
HighScoreText:
	.ascii "HIGHSCORE"
	
.align, 4
MapObject:
	.dw 0   ; map_offset_x
	.dw 80  ; length
	
Tilemap:
	.dw 0   ; ground_vram_x
	.dw 0   ; ground_vram_y
	.dw 0   ; brick_vram_x
	.dw 0   ; brick_vram_y
	.dw 0   ; block_vram_x
	.dw 0   ; block_vram_y
	.dw 0   ; question_vram_x
	.dw 0   ; question_vram_y
	.dw 0   ; montagne1_vram_x
	.dw 0   ; montagne1_vram_y
	.dw 0   ; montagne2_vram_x
	.dw 0   ; montagne2_vram_y
	.dw 0   ; montagne3_vram_x
	.dw 0   ; montagne3_vram_y
	.dw 0   ; montagne4_vram_x
	.dw 0   ; montagne4_vram_y
	.dw 0   ; montagne5_vram_x
	.dw 0   ; montagne5_vram_y
	.dw 0   ; montagne6_vram_x
	.dw 0   ; montagne6_vram_y
	.dw 0   ; coin_vram_x
	.dw 0   ; coin_vram_y
	
MapFile:
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11, 11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  4,  4,  0,  0 
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  0,  0,  0, 11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11,  0,  0,  0,  0,  0,  0,  0,  0,  2,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11, 11,  0,  0 
	.db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 11, 11, 11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  0
	.db  0,  0,  0,  0,  0,  0,  0,  4,  0,  0,  0,  2,  4,  2,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.db  0,  0,  0, 10,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 10,  0,  0,  0, 11,  0,  0, 11,  0,  0,  0,  0,  0,  0,  0,  0, 10,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  0,  0,  3,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  0,  0,  3,  3,  0,  0,  0,  2,  4,  2,  0,  0,  0,  0,  0,  0
	.db  0,  0,  9,  6,  8,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  9,  6,  8,  0,  0,  2,  0,  0,  2,  0,  0,  0,  0,  0,  0,  0,  9,  6,  8,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  3,  0,  0,  3,  3,  3,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  3,  0,  0,  3,  3,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0 
	.db  0,  9,  5,  7,  6,  8,  0,  0,  0,  0, 11,  0, 11,  0,  0,  0,  0,  9,  5,  7,  6,  8,  0,  0,  0,  0,  0,  0,  0,  0, 11, 11,  0,  9,  5,  7,  6,  8,  0,  0,  0,  0,  0,  0,  3,  3,  3,  3,  0,  0,  3,  3,  3,  3,  0, 11, 11, 11,  0,  0,  3,  3,  3,  3,  0,  0,  3,  3,  3,  3, 11, 11, 11,  0,  0,  0,  0,  0,  0,  0
	.db  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
	.db  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1