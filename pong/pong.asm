#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# Classic Arcade Game: Pong (1972)
#-----------------------------------------------------------
# History 
#-----------------------------------------------------------
# Pong laid the groundwork for and breathed life into the 
# video game industry during its formative years and firmly cemented 
# itself as a landmark title in the annals of video game history.
#-----------------------------------------------------------
# Objective
#-----------------------------------------------------------
# The objective of Pong is simple, as it is an electronic version
# of table tennis. The player controls a paddle that hits the ball 
# back and forth against the other player to try to get the ball 
# past them. Each time the ball moves past the other player, 
# the player is awarded  a point. The first to reach 11 points.
#-----------------------------------------------------------
# Controls: D-Pad
# Up - Move Paddle Up
# Down - Move Paddle Down
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

; Commands Are Sent by Writing Directly to the GPU controls registers(MSB is the command and the lower 24-bits are for the parameter)
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
VS_CMD_FILL_RECT equ $60000000 

; PlayStation JoyPad Commands and Variables
VS_CMD_INIT_PAD equ $15
VS_JOY_UP equ $1000 
VS_JOY_DOWN equ $4000

VS_RED equ 0 
VS_GREEN equ 0 
VS_BLUE equ 0

; IMMUTABLE GAME VARIABLES
VS_DIR_UP_RIGHT equ 0 
VS_DIR_DOWN_RIGHT equ 1 
VS_DIR_UP_LEFT equ 2 
VS_DIR_DOWN_LEFT equ 3
VS_FONTW equ 8 
VS_FONTH equ 11

; MUTABLE GAME VARIABLES
VS_PADDLE_W equ 10 
VS_PADDLE_H equ 60

VS_PLAYER_X equ 15 
VS_PLAYER_Y equ 100 - (VS_PADDLE_W)

VS_PLAYER_X2 equ 235 
VS_PLAYER_Y2 equ 100 - (VS_PADDLE_W)

VS_BALL_X equ 122
VS_BALL_Y equ 110
VS_BALL_W equ 10 
VS_BALL_H equ 10

VS_FENCE_W equ 2
VS_FENCE_H equ 10

VS_VELOCITY equ 2
VS_BALL_VELOCITY equ 3

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
	li t5, VS_HRANGE                      ; vs_hrange = 0xC4E24E;
	li t6, VS_VRANGE                      ; vs_vrange = 0x040010;
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
	andi t2, $3FF                         ; x1 &= 0x3FF;
	andi t3, $1FF                         ; y1 &= 0x1FF;
	sll t3, $0A                           ; y1 <<= 10;
	addu t3, t2                           ; y1 += x1;
	addu t1, t3                           ; vs_cmd += y1;
	sw t1, VS_GP0(t0)    				  ; *vs_gp0 = vs_cmd;
	li t1, VS_CMD_DISP_X2Y2               ; vs_cmd = VS_CMD_DISP_X2Y2;
	li t2, VS_DISP_X2                     ; x2 = VS_DISP_X2;
	li t3, VS_DISP_Y2                     ; y2 = VS_DISP_Y2;
	andi t2, $3FF                         ; x2 &= 0x3FF;
	andi t3, $1FF                         ; y2 &= 0x1FF;
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
	li t1, $300                           ; dma_priority = 0x300;
	sw t1, 0(t2)                          ; *dma_address = dma_priority;
	li t1, $800                           ; gpu_dma_enable = 0x800;
	sw t1, 0(t2)                          ; *dma_address = gpu_dma_enable;
InitPad: 
    li t1,VS_CMD_INIT_PAD                 ; OutdatedPadInitAndStart() Function Is $15
    li a0, $20000001
    li t2, $B0                            ; Call a B-Type BIOS Function 
    li a1, VS_IO                          ; Set Pad Buffer Address To Automatically Update Each Frame
    jalr t2                               ; Jump To BIOS Routine OutdatedPadInitAndStart()
    nop ; Delay Slot
	addi sp, -80
	li s0, VS_IO
	sw zero, 8(s0) 
	sw zero, 12(s0) 
	li t1, VS_PLAYER_X                    ; x = VS_PLAYER_X;
	sw t1, 16(s0)
	li t1, VS_PLAYER_Y                    ; y = VS_PLAYER_Y;
	sw t1, 20(s0)
	li t1, VS_PLAYER_X2                   ; x2 = VS_PLAYER_X2;
	sw t1, 24(s0)
	li t1, VS_PLAYER_Y2                   ; y2 = VS_PLAYER_Y2;
	sw t1, 28(s0)
	la t0, BallXY
	li t1, VS_BALL_X                      ; ball_x = VS_BALL_X;
	sw t1, 0(t0)
	li t1, VS_BALL_Y                      ; ball_y = VS_BALL_Y;
	sw t1, 4(t0)
	li s1, VS_DIR_DOWN_RIGHT              ; ball_dir = VS_DIR_DOWN_RIGHT;
Input:
PRESSUP:
    lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop                  
    andi t0, VS_JOY_UP                    ; pad_data &= VS_JOY_UP;
    beqz t0, PRESSDOWN         		      ; if(!pad_data) { goto PRESSDOWN; }
    nop 
    lw t0, 20(s0)          
    nop
    subi t0, VS_VELOCITY       		      ; y -= VS_VELOCITY;
	bltz t0, PRESSDOWN                    ; if(y < 0) { goto PRESSDOWN; }
	nop
    sw t0, 20(s0)
PRESSDOWN:
    lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_DOWN                  ; pad_data &= VS_JOY_DOWN;
    beqz t0, HandleBallLogic    		  ; if(!pad_data){ goto HandleBallLogic; }
    nop 
    lw t0, 20(s0)
    nop
    addi t0, VS_VELOCITY                  ; y += VS_VELOCITY;
	li t1, VS_HEIGHT - VS_PADDLE_H        
	bge t0, t1, HandleBallLogic 		  ; if(y >= (VS_HEIGHT - VS_PADDLE_H)) { goto HandleBallLogic; }
	nop
    sw t0, 20(s0)
HandleBallLogic:
	beqz s1, PaddleUpRight                ; if(BallDir == VS_DIR_UP_RIGHT) { goto PaddleUpRight; }
	li t1, 1 
	beq s1, t1, PaddleDownRight           ; if(BallDir == VS_DIR_DOWN_RIGHT) { goto PaddleDownRight; }
	li t1, 2 
	beq s1, t1, PaddleUpLeft              ; if(BallDir == VS_DIR_UP_LEFT) { goto PaddleUpLeft; }
	li t1, 3 
	beq s1, t1, PaddleDownLeft            ; if(BallDir == VS_DIR_DOWN_LEFT) { goto PaddleDownLeft; }
	nop
PaddleUpRight:
	lw t1, 28(s0)                         
	nop 
	subi t1, VS_VELOCITY                  ; player_y2 -= VS_VELOCITY;
	bltz t1, BallUpRight                  ; if(player_y2 < 0) { goto BallUpRight; }
	nop
	sw t1, 28(s0)
BallUpRight:
	la t0, BallXY
	lw t1, 0(t0)                          ; x = BallXY->x 
	nop 
	addi t1, VS_BALL_VELOCITY             ; x += VS_BALL_VELOCITY;
	li t2, 244 
	bge t1, t2, PlayerResetBallXY         ; if(x >= 244) { PlayerResetBallXY; }
	nop
	sw t1, 0(t0)                          ; BallXY->x = x;
	lw t1, 4(t0)                          ; y = BallXY->y;
	nop 
	subi t1, VS_BALL_VELOCITY             ; y -= VS_BALL_VELOCITY;
	blez t1, ChangeDirToDownRight         ; if(y <= 0) { goto ChangeDirToDownRight; }
	sw t1, 4(t0)                          ; BallXY->y = y;
	b DetectCollisionWithPlayer           ; goto DetectCollisionWithPlayer;
	nop
PaddleDownRight:
	lw t1, 28(s0)                         
	nop 
	addi t1, VS_VELOCITY                  ; player_y2 += VS_VELOCITY;
	li t2, VS_HEIGHT - VS_PADDLE_H        
	bge t1, t2, BallDownRight 		      ; if(y >= (VS_HEIGHT - VS_PADDLE_H)) { goto BallDownRight; }
	nop
	sw t1, 28(s0)
BallDownRight:
	la t0, BallXY
	lw t1, 0(t0)                          ; x = BallXY->x;
	nop 
	addi t1, VS_BALL_VELOCITY             ; x += VS_BALL_VELOCITY; 
	li t2, 244 
	bge t1, t2, PlayerResetBallXY         ; if(x >= 244) { PlayerResetBallXY; }
	nop
	sw t1, 0(t0)                          ; BallXY->x = x;
	lw t1, 4(t0)                          ; y = BallXY->y;
	nop 
	addi t1, VS_BALL_VELOCITY             ; y += VS_BALL_VELOCITY;
	li t2, VS_HEIGHT - VS_BALL_H    
	bge t1, t2, ChangeDirToUpRight        ; if(y >= (VS_HEIGHT - VS_BALL_H)) { goto ChangeDirToUpRight; }
	sw t1, 4(t0)                          ; BallXY->y = y;
	b DetectCollisionWithPlayer           ; goto DetectCollisionWithPlayer;
	nop
PaddleUpLeft:
	lw t1, 28(s0)                         
	nop 
	subi t1, VS_VELOCITY                  ; player_y2 -= VS_VELOCITY;
	bltz t1, BallUpLeft                   ; if(player_y2 < 0) { goto BallUpLeft; }
	nop
	sw t1, 28(s0)
BallUpLeft:
	la t0, BallXY
	lw t1, 0(t0)                          ; x = BallXY->x 
	nop 
	subi t1, VS_BALL_VELOCITY             ; x -= VS_BALL_VELOCITY;
	blez t1, CPUResetBallXY               ; if(x <= 0) { CPUResetBallXY; }
	nop
	sw t1, 0(t0)                          ; BallXY->x = x;
	lw t1, 4(t0)                          ; y = BallXY->y;
	nop 
	subi t1, VS_BALL_VELOCITY             ; y -= VS_BALL_VELOCITY;
	blez t1, ChangeDirToDownLeft          ; if(y <= 0) { goto ChangeDirToDownLeft; }
	sw t1, 4(t0)                          ; BallXY->y = y;
	b DetectCollisionWithPlayer           ; goto DetectCollisionWithPlayer;
	nop
PaddleDownLeft:
	lw t1, 28(s0)                         
	nop 
	addi t1, VS_VELOCITY                  ; player_y2 += VS_VELOCITY;
	li t2, VS_HEIGHT - VS_PADDLE_H        
	bge t1, t2, BallDownLeft 		      ; if(y >= (VS_HEIGHT - VS_PADDLE_H)) { goto BallDownLeft; }
	nop
	sw t1, 28(s0)
BallDownLeft:
	la t0, BallXY
	lw t1, 0(t0)                          ; x = BallXY->x 
	nop 
	subi t1, VS_BALL_VELOCITY             ; x -= VS_BALL_VELOCITY;
	blez t1, CPUResetBallXY               ; if(x <= 0) { CPUResetBallXY; }
	nop	
	sw t1, 0(t0)                          ; BallXY->x = x;
	lw t1, 4(t0)                          ; y = BallXY->y;
	nop 
	addi t1, VS_BALL_VELOCITY             ; y += VS_BALL_VELOCITY;
	li t2, VS_HEIGHT - VS_BALL_H    
	bge t1, t2, ChangeDirToUpLeft         ; if(y >= (VS_HEIGHT - VS_BALL_H)) { goto ChangeDirToUpLeft; }
	sw t1, 4(t0)                          ; BallXY->y = y;
	b DetectCollisionWithPlayer           ; goto DetectCollisionWithPlayer;
	nop
DetectCollisionWithPlayer:
	lw a0, 16(s0)                         ; x1 = player_x;
	lw a1, 20(s0)                         ; x2 = player_y;
	li a2, VS_PADDLE_W                    ; w1 = VS_PADDLE_W;
	li a3, VS_PADDLE_H                    ; h1 = VS_PADDLE_H;
	la t0, BallXY                         
	lw t1, 0(t0)                          ; x2 = BallXY->x;
	lw t2, 4(t0)                          ; y2 = BallXY->y;
	sw t1, 16(sp)                         
	sw t2, 20(sp)                       
	li t0, VS_BALL_W                      ; w2 = VS_BALL_W;
	sw t0, 24(sp)                         ; h2 = VS_BALL_H;
	li t0, VS_BALL_H                    
	sw t0, 28(sp)                     
	jal DetectAABBCollision               ; collide = DetectAABBCollision(x1,y1,w1,h1,x2,y2,w2,h2);
	nop
	beqz v0, DetectCollisionWithCPU       ; if(!collide) { goto DetectCollisionWithCPU; }
	nop 
HandlePlayerCollision:
	li t0, VS_DIR_UP_LEFT                 
	beq s1, t0, ChangeDirToUpRight        ; if(BallDir == VS_DIR_UP_LEFT) { goto ChangeDirToUpRight; }
	li t0, VS_DIR_DOWN_LEFT
	beq s1, t0, ChangeDirToDownRight      ; if(BallDir == VS_DIR_DOWN_LEFT) { goto ChangeDirToDownRight; }
	nop 
DetectCollisionWithCPU:
	lw a0, 24(s0)                         ; x1 = player_x2;
	lw a1, 28(s0)                         ; x2 = player_y2;
	li a2, VS_PADDLE_W                    ; w1 = VS_PADDLE_W;
	li a3, VS_PADDLE_H                    ; h1 = VS_PADDLE_H;
	la t0, BallXY                         
	lw t1, 0(t0)                          ; x2 = BallXY->x;
	lw t2, 4(t0)                          ; y2 = BallXY->y;
	sw t1, 16(sp)                         
	sw t2, 20(sp)                       
	li t0, VS_BALL_W                      ; w2 = VS_BALL_W;
	sw t0, 24(sp)                         ; h2 = VS_BALL_H;
	li t0, VS_BALL_H                    
	sw t0, 28(sp)                     
	jal DetectAABBCollision               ; collide = DetectAABBCollision(x1,y1,w1,h1,x2,y2,w2,h2);
	nop
	beqz v0, FillScreen                   ; if(!collide) { goto FillScreen; }
	nop 
HandleCPUCollision:
	li t0, VS_DIR_UP_RIGHT                 
	beq s1, t0, ChangeDirToUpLeft         ; if(BallDir == VS_DIR_UP_RIGHT) { goto ChangeDirToUpLeft; }
	li t0, VS_DIR_DOWN_RIGHT
	beq s1, t0, ChangeDirToDownLeft       ; if(BallDir == VS_DIR_DOWN_RIGHT) { goto ChangeDirToDownLeft; }
	nop 
	b FillScreen                          ; goto FillScreen;
	nop
ChangeDirToUpRight:
	li s1, VS_DIR_UP_RIGHT                ; BallDir = VS_DIR_UP_RIGHT;
	b FillScreen                          ; goto FillScreen;
	nop
ChangeDirToDownRight:
	li s1, VS_DIR_DOWN_RIGHT              ; BallDir = VS_DIR_DOWN_RIGHT;
	b FillScreen                          ; goto FillScreen;
	nop
ChangeDirToUpLeft:
	li s1, VS_DIR_UP_LEFT                 ; BallDir = VS_DIR_UP_LEFT;
	b FillScreen                          ; goto FillScreen;
	nop
ChangeDirToDownLeft:
	li s1, VS_DIR_DOWN_LEFT               ; BallDir = VS_DIR_DOWN_LEFT;
FillScreen:
	li t1, VS_FILL_VRAM                   ; vs_cmd = VS_FILL_VRAM;
	li t2, VS_BLUE                        ; blue = VS_BLUE;
	sll t2, $10                           ; blue <<= 16;
	li t3, VS_GREEN                       ; green = VS_GREEN;
	sll t3, $08                           ; green <<= 8;
	addu t2, t3                           ; blue += green;
	addiu t2, VS_RED                      ; blue += red;
	addu t1, t2                           ; vs_cmd += blue;
	sw t1, VS_GP0(s0)                     ; *vs_gp0 = vs_cmd;
	li t2, VS_DISP_X1                     ; x1 = VS_DISP_X1;
	li t3, VS_DISP_Y1                     ; y1 = VS_DISP_Y1;
	andi t2, $FFFF                        ; x1 &= $FFFF;
	sll t3, t3, $10                       ; y1 <<= 16;
	addu t3, t2                           ; y1 += x1;
	sw t3, VS_GP0(s0)                     ; *vs_gp0 = y1;
	li t2, VS_WIDTH                       ; x2 = VS_WIDTH;
	li t3, VS_HEIGHT                      ; y2 = VS_HEIGHT;
	andi t2, $FFFF                        ; x2 &= $FFFF;
	sll t3, t3, $10                       ; y2 <<= 16;
	addu t3, t2                           ; y2 += x2;
	sw t3, VS_GP0(s0)                     ; *vs_gp0 = y2;
DrawPlayerPaddle:
	lw a0, 16(s0)                         ; rect_x = VS_PLAYER_X; 
	lw a1, 20(s0)                         ; rect_y = VS_PLAYER_Y;
	li a2, VS_PADDLE_W                    ; rect_w = VS_PADDLE_W;
	li a3, VS_PADDLE_H                    ; rect_h = VS_PADDLE_H;
	li t1, $FFFFFF                        ; rect_color = $FFFFFF;
	sw t1, 16(sp)                          
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                        
	nop
DrawEnemyPaddle:
	lw a0, 24(s0)                         ; rect_x = VS_PLAYER_X2; 
	lw a1, 28(s0)                         ; rect_y = VS_PLAYER_y2;
	li a2, VS_PADDLE_W                    ; rect_w = VS_PADDLE_W;
	li a3, VS_PADDLE_H                    ; rect_h = VS_PADDLE_H;
	li t1, $FFFFFF                        ; rect_color = $FFFFFF;
	sw t1, 16(sp)                          
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                        
	nop
DrawVirtualFence:
	li t3, 5                              ; fence_start_y = 5;
	li t4, VS_HEIGHT                      ; fence_end_y = VS_HEIGHT;
	li t5, VS_WIDTH / 2                   ; fence_x = VS_WIDTH / 2;
DrawFenceLoop:
	move a0, t5                           ; rect_x = fence_x;
	move a1, t3                           ; rect_y = fence_start_y;
	li a2, VS_FENCE_W                     ; rect_w = VS_FENCE_W;
	li a3, VS_FENCE_H                     ; rect_h = VS_FENCE_H;
	li t2, $FFFFFF                        ; rect_color = $FFFFFF;
	sw t2, 16(sp)       
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop                                   ; fence_start_y += VS_FENCE_H + 5;
	blt t3, t4, DrawFenceLoop             ; if(fence_start_y < fence_end_y) { goto DrawFenceLoop }
	addiu t3, VS_FENCE_H + 5              
DrawBall:
	la t0, BallXY
	lw a0, 0(t0)                          ; rect_x = ball_x; 
	lw a1, 4(t0)                          ; rect_y = ball_y;
	li a2, VS_BALL_W                      ; rect_w = VS_BALL_W;
	li a3, VS_BALL_H                      ; rect_h = VS_BALL_H;
	li t1, $FFFFFF                        ; rect_color = $FFFFFF;
	sw t1, 16(sp)                          
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                        
	nop
HandleScore:
	li t0, 11                             ; max_score = 11;
	lw t1, Player1Score                   ; player1score = Player1Score->score;
	nop 
	bge t1, t0, ResetGame                 ; if(player1score >= max_score){ goto ResetGame; }
	lw t2, Player2Score                   ; player2score = Player2Score->score;
	nop 
	bge t2, t0, ResetGame                 ; if(player2score >= max_score) { goto ResetGame; }
	nop
DrawScore:
	la a0, Player1Text                    ; string = Player1Text;
	lw a1, Player1Score                   ; int = Player1Score;
	nop
	jal VS_Int2String                     ; num_digits = VS_Int2String(string,int);
	nop 
	li a0, 70                             ; x = 70;
	li a1, 276                            ; y = 276;
	la a2, Player1Text                    ; string = Player1Text;
	move a3, v0                           ; strlen = num_digits - 1;
	subi a3, 1 
	jal VS_DrawString                     ; VS_DrawString(x,y,string,strlen);
	nop
	la a0, Player2Text                    ; string = Player2Text;
	lw a1, Player2Score                   ; int = Player2Score;
	nop
	jal VS_Int2String                     ; num_digits = VS_Int2String(string,int);
	nop 
	li a0, 190                            ; x = 190;
	li a1, 276                            ; y = 276;
	la a2, Player2Text                    ; string = Player2Text;
	move a3, v0                           ; strlen = num_digits - 1;
	subi a3, 1 
	jal VS_DrawString                     ; VS_DrawString(x,y,string,strlen);
	nop
BufferSwap:
	li t1, VS_VRAM_TO_VRAM                ; vs_cmd = VS_VRAM_TO_VRAM;
	sw t1, VS_GP0(s0)                     ; *vs_gp0 = vs_cmd;
	li t2, VS_DISP_X1                     ; x1 = VS_DISP_X1;
	li t3, VS_DISP_Y1                     ; y1 = VS_DISP_Y1;
	andi t2, $FFFF                        ; x1 &= $FFFF;
	sll t3, t3, $10                       ; y1 <<= 16;
	addu t3, t2                           ; y1 += x1;
	sw t3, VS_GP0(s0)                     ; *vs_gp0 = y1;
	sw zero, VS_GP0(s0)                   ; *vs_gp0 = 0;
	li t2, VS_WIDTH                       ; x2 = VS_WIDTH;
	li t3, VS_HEIGHT                      ; y2 = VS_HEIGHT;
	andi t2, $FFFF                        ; x2 &= $FFFF;
	sll t3, t3, $10                       ; y2 <<= 16;
	addu t3, t2                           ; y2 += x2;
	sw t3, VS_GP0(s0)                     ; *vs_gp0 = y2;
WaitVSync:                                ; Wait For Vertical Retrace Period & Store XOR Pad Data
    lw  t0, 0(s0)                         ; Load Pad Buffer
    nop               
    beqz t0, WaitVSync                    ; if(pad_buffer == 0){ goto Wait; }
    nor t0, zero                          ; pad_buffer = !(pad_buffer | 0);
    sw zero, 0(s0)                        ; Store Zero To Pad Buffer
    sw t0, 8(s0)                          ; Store Pad Data
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
	li v0, $1 
	jr ra 
	nop
AABBFalse:
	li v0, $0 
	jr ra 
	nop
	
# Function: ResetGame
# Purpose: Resets the core game variables such as the score of the player and CPU, and the X and Y coordinates of the ball.
ResetGame:
	sw zero, Player1Score
	sw zero, Player2Score
	la t0, BallXY 
	li t1, VS_BALL_X    ; x = VS_BALL_X;
	sw t1, 0(t0)        ; BALLXY->x = x;
	jal VS_Rand 
	nop 
	la t0, BallXY
	sb v0, 4(t0)        ; BALLXY->y = VS_Rand();
	jal VS_Rand 
	nop 
	andi v0, 3
	move s1, v0         ; BallDir = VS_Rand() & 3;
	b FillScreen        ; goto FillScreen;
	nop
	
# Function: ResetBallXY
# Purpose: Resets the X coordinate of the ball to its initial value, randomly sets the Y coordinate of the ball, and increments the score of the player
PlayerResetBallXY:
	la t0, BallXY 
	li t1, VS_BALL_X    ; x = VS_BALL_X;
	sw t1, 0(t0)        ; BALLXY->x = x;
	jal VS_Rand 
	nop 
	la t0, BallXY
	sb v0, 4(t0)        ; BALLXY->y = VS_Rand();
	jal VS_Rand 
	nop 
	andi v0, 3
	move s1, v0         ; BallDir = VS_Rand() & 3;
	lw t0, Player1Score
	nop 
	addi t0, 1 
	sw t0, Player1Score
	b FillScreen        ; goto FillScreen;
	nop
	
# Function: ResetBallXY
# Purpose: Resets the X coordinate of the ball to its initial value, randomly sets the Y coordinate of the ball, and increments the score of the CPU
CPUResetBallXY:
	la t0, BallXY 
	li t1, VS_BALL_X    ; x = VS_BALL_X;
	sw t1, 0(t0)        ; BALLXY->x = x;
	jal VS_Rand 
	nop 
	la t0, BallXY
	sb v0, 4(t0)        ; BALLXY->y = VS_Rand();
	jal VS_Rand 
	nop 
	andi v0, 3
	move s1, v0         ; BallDir = VS_Rand() & 3;
	lw t0, Player2Score
	nop 
	addi t0, 1 
	sw t0, Player2Score
	b FillScreen        ; goto FillScreen;
	nop

# Function: VS_Rand
# Purpose: Utilizes the original Doom random function to generate a random unsigned 8-bit integer
VS_Rand:
	la t0, vs_rand_index
	lw t1, 0(t0)
	nop 
	addiu t1, 1          ; vs_rand_index++;
	andi  t1, $ff        ; vs_rand_index &= $ff;
	la  t2, rndtable
	addu t2, t1          ; rndtable += vs_rand_index;
	lbu v0, 0(t2)        ; num = *rndtable;
	sw t1, 0(t0)
	jr ra 
	nop
	
# Function: FillRect
# Purpose: Draws a filled monochrome rectangle to the display area 
# a0: x, a1: y, a2: w, a3: h, 16(sp): color 
FillRect:
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

# Function: DrawSync
# Purpose: Halts program execution until all drawing commands have been executed by the gpu 
DrawSync:
	li t0, VS_IO             ; vs_io_addr = (unsigned long*)$1F800000;
DrawSyncLoop:
	lw t1, VS_GP1(t0)        ; gpu1 = *vs_gpu1;
	li t2, VS_CMD_STAT_READY ; gpu1_cmd = VS_CMD_STAT_READY; (delay slot)
	and t1, t1, t2           ; gpu1 &= gpu1_cmd;
	beqz t1, DrawSyncLoop    ; if(gpu1 == 0) { goto DrawSyncLoop; }
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
	
# Function: VS_DrawString
# Purpose: Draws a string to the display area 
# a0: x, a1: y, a2: string, a3: strlen 
VS_DrawString:
	addiu sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
	move t1, a0          ; orgx = x;
	move t2, a1          ; orgy = y;
	li t0, VS_IO
DrawChar:
	lbu a0, 0(a2)        ; c = *string;
	addiu a2, a2, 0x1    ; string++; (delay slot)
	li t3, 32
	beq  a0, t3, vs_draw_space
	nop
	jal VS_CharData        ; data = VS_CharData(c);
	li t3, VS_CPU_TO_VRAM ; gpu0_cmd = VS_CPU_TO_VRAM; (delay slot)
	sw t3, VS_GP0(t0)    ; *vs_gp0 = gpu0_cmd;
	andi t1, t1, 0xFFFF  ; x &= 0xFFFF;
	sll t3, a1, 0x10     ; y <<= 16;
	addu t3, t3, t1     ; y += x;
	sw t3, VS_GP0(t0)    ; *vs_gp0 = y;
	li t3, VS_FONTW       ; w = VS_IMGW;
	li t4, VS_FONTH       ; h = VS_IMGH;
	sll t4, t4, 0x10     ; h <<= 16;
	addu t4, t4, t3     ; h += w;
	sw t4, VS_GP0(t0)    ; *vs_gp0 = h;
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
	blez a3, end
	subi a3, a3, 0x1     ; strlen--; (delay slot)
	b DrawChar
	nop
vs_draw_space:
	addi t1, t1, 0x8     ; x += 8;
	b   DrawChar
	subi a3, a3, 0x1     ; strlen--;
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
	li t1, $0A        		 ; base = 10;
	move t2, a1        		 ; tempInt = int; 
CountDigits:
	div t2, t1               ; tempInt /= base;
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
	div   a1, t1             ; int = int / base;
	mflo  a1 
	bgtz  a1, ConvertLoop    ; if(int > 0) { goto ConvertLoop; }
	subi  a0, 1              ; string--;
	move v0, t0
	jr ra 
	nop	
	
# Function: VS_CharData
# Purpose: Returns the image data of the input character
# a0: c
VS_CharData:
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
	la v0, VS_0
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
	
.data
BallXY:
	.dw 0
	.dw 0

Player1Score:
	.dw 0

Player2Score:
	.dw 0

Player1Text:
	.dw 0

Player2Text:
	.dw 0

vs_rand_index:
	.dw 0
	
rndtable: 
	.db $0, $8, $6d, $dc, $de, $f1, $95, $6b, $4b, $f8, $fe, $8c, $10, $42, $4a, $15, $d3, $2f, $50, $f2, $9a, $1b, $cd, $80, $a1 
	.db $59, $4d, $24, $5f, $6e, $55, $30, $d4, $8c, $d3, $f9, $16, $4f, $c8, $32, $1c, $bc, $34, $8c, $ca, $78, $44, $91, $3e, $46
	.db $b8, $be, $5b, $c5, $98, $e0, $95, $68, $19, $b2, $fc, $b6, $ca, $b6, $8d, $c5, $4, $51, $b5, $f2, $91, $2a, $27, $e3, $9c 
	.db $c6, $e1, $c1, $db, $5d, $7a, $af, $f9, $0, $af, $8f, $46, $ef, $2e, $f6, $a3, $35, $a3, $6d, $a8, $87, $2, $eb, $19, $5c 
	.db $14, $91, $8a, $4d, $45, $a6, $4e, $b0, $ad, $d4, $a6, $71, $5e, $a1, $29, $32, $ef, $31, $6f, $a4, $46, $3c, $2, $25, $ab 
	.db $4b, $88, $9c, $b, $38, $2a, $92, $8a, $e5, $49, $92, $4d, $3d, $62, $c4, $87, $6a, $3f, $c5, $c3, $56, $60, $cb, $71, $65 
	.db $aa, $f7, $b5, $71, $50, $fa, $6c, $7, $ff, $ed, $81, $e2, $4f, $6b, $70, $a6, $67, $f1, $18, $df, $ef, $78, $c6, $3a, $3c 
	.db $52, $80, $3, $b8, $42, $8f, $e0, $91, $e0, $51, $ce, $a3, $2d, $3f, $5a, $a8, $72, $3b, $21, $9f, $5f, $1c, $8b, $7b, $62 
	.db $7d, $c4, $f, $46, $c2, $fd, $36, $e, $6d, $e2, $47, $11, $a1, $5d, $ba, $57, $f4, $8a, $14, $34, $7b, $fb, $1a, $24, $11 
	.db $2e, $34, $e7, $e8, $4c, $1f, $dd, $54, $25, $d8, $a5, $d4, $6a, $c5, $f2, $62, $2b, $27, $af, $fe, $91, $be, $54, $76, $de 
	.db $bb, $88, $78, $a3, $ec, $f9
	
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