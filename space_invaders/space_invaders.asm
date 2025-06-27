#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# Classic Arcade Game: Space Invaders (1978)
#-----------------------------------------------------------
# History 
#-----------------------------------------------------------
# Space Invaders is the culmunation of all technological
# and gameplay advancements of the early 70's arcade era
# packed into one of the greatest arcade shooters of all time.
# One of its primary gameplay innovations was introducing the 
# indefinite game loop allowing for a continuous stream of 
# gameplay that didn't rely on timers or a fixed-amount of stages.
# Its port to the Atari 2600 quadrupled the sales of the console
# becoming the first "Killer App" of its kind in the console space.
#-----------------------------------------------------------
# Objective
#-----------------------------------------------------------
# The overall objective of Space Invaders is to defend an 
# alien invasion from the ground by firing misslies into the 
# waves of enemy hordes and avoiding counter fire from above.
# To clear a level, the player must defeat the entire alien 
# horde before they reach the bottom of the screen. If the 
# player is defeated or an alien ship reaches the bottom of 
# the screen, the player loses a life and the level resets.
#-----------------------------------------------------------
# Controls:
# X Button - Shoot
# Left - Move Player Left 
# Right - Move Player Right
#-----------------------------------------------------------
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
VS_GREEN equ 0 
VS_BLUE equ 0

VS_FONTW equ 8 
VS_FONTH equ 11

; IMMUTABLE GAME VARIABLES
VS_DEFENDER_VRAM_X equ 256 
VS_DEFENDER_VRAM_Y equ 0 
VS_DEFENDER_W equ 13 
VS_DEFENDER_H equ 8
VS_ALIEN_VRAM_X equ 512 
VS_ALIEN_VRAM_Y equ 0 
VS_ALIEN_W equ 11 
VS_ALIEN_H equ 8
VS_NUM_LIVES equ 3
VS_ALIEN_NUM_ROWS equ 5 
VS_ALIEN_NUM_COLS equ 10
VS_BULLET_W equ 1 
VS_BULLET_H equ 5
VS_NUM_ALIENS equ VS_ALIEN_NUM_COLS * VS_ALIEN_NUM_ROWS
VS_BULLET_COOLDOWN equ 20
; MUTABLE GAME VARIABLES
VS_PLAYER_X equ (VS_WIDTH / 2)
VS_PLAYER_Y equ 200
VS_VELOCITY equ 1 
VS_BULLET_VELOCITY equ 3
VS_FIXED_VELOCITY equ 1524
VS_MASTER_VOLUME equ $3FFF
VS_CHANNEL_VOLUME equ $3FFF
VS_SHOOT_SAMPLE_RATE equ 44100
VS_SHOOT_SFX_SIZE equ 9122

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
InitGameAudio:
	jal InitAudio                         ; InitAudio();
	nop
	li a0, VS_MASTER_VOLUME               ; master_volume = VS_MASTER_VOLUME;
	jal VS_SetMasterVolume                ; VS_SetMasterVolume(master_volume);
	nop
	li a0, $0                             ; reverb_volume = 0;
	jal VS_SetReverbVolume                ; VS_SetReverbVolume(reverb_volume);
	nop
	li a0, $0                             ; channel = 0;
	li a1, VS_CHANNEL_VOLUME              ; volume = VS_CHANNEL_VOLUME;
	jal VS_SetChannelVolume               ; VS_SetChannelVolume(channel,volume);
	nop
	li a0, $0                             ; channel = 0;
	li a1, VS_SHOOT_SAMPLE_RATE           ; sample_rate = VS_SHOOT_SAMPLE_RATE;
	jal VS_SetChannelSampleRate           ; VS_SetChannelSampleRate(channel, sample_rate);
	nop 
	li a0, $1010                          ; addr = $1010;
	jal VS_SetADPCMAddr                   ; VS_SetADPCMAddr(addr);
	nop
	li a0, 0                              ; channel = 0;
	li a1, $1010                          ; addr = $1010;
	jal VS_SetChannelADPCMAddr            ; VS_SetChannelADPCMAddr(channel,addr);
	nop
	li a0, $0                             ; channel = 0;
	li a1, $f                             ; sustain = 15;
	jal VS_SetChannelSustainLevel         ; VS_SetChannelSustainLevel(channel, sustain);
	nop
	la a0, ShootSFX                       ; adpcm_addr = ShootSFX;
	li a1, VS_SHOOT_SFX_SIZE              ; size = VS_SHOOT_SFX_SIZE;
	jal VS_ManuallyWriteADPCM             ; VS_ManuallyWriteADPCM(apdcm_addr,size);
	nop
UploadTexturesToVram:
	li a0, VS_DEFENDER_VRAM_X             ; vram_x = VS_DEFENDER_VRAM_X;
	li a1, VS_DEFENDER_VRAM_Y             ; vram_y = VS_DEFENDER_VRAM_Y;
	li a2, VS_DEFENDER_W                  ; image_w = VS_DEFENDER_W;
	li a3, VS_DEFENDER_H                  ; image_h = VS_DEFENDER_H;
	la t0, DefenderTexture                ; image = DefenderTexture;
	sw t0, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,image);
	nop
	li a0, VS_ALIEN_VRAM_X                ; vram_x = VS_ALIEN_VRAM_X;
	li a1, VS_ALIEN_VRAM_Y                ; vram_y = VS_ALIEN_VRAM_Y;
	li a2, VS_ALIEN_W                     ; image_w = VS_ALIEN_W;
	li a3, VS_ALIEN_H                     ; image_h = VS_ALIEN_H;
	la t0, AlienTexture                   ; image = AlienTexture;
	sw t0, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,image);
	nop
InitPad: 
    li t1,VS_CMD_INIT_PAD                 ; OutdatedPadInitAndStart() Function Is $15
    li a0, $20000001
    li t2, $B0                            ; Call a B-Type BIOS Function 
    li a1, VS_IO                          ; Set Pad Buffer Address To Automatically Update Each Frame
    jalr t2                               ; Jump To BIOS Routine OutdatedPadInitAndStart()
    nop ; Delay Slot
	li s0, VS_IO
	sw zero, 8(s0) 
	sw zero, 12(s0) 
	addi sp, -80
	b InitGame 
	sw zero, HighScore
Input:
	lw t0, PlayerLives                    ; lives = *(unsigned long*)PlayerLives
	nop 
	beqz t0, InitGame                     ; if(lives == 0) { goto InitGame; }
	nop 
	jal CountNumAliensAlive               ; alive_aliens = CountNumAliensAlive();
	nop
	beqz v0, ResetLevel                   ; if(alive_aliens == 0) { goto ResetLevel; }
	nop
	la t0, AlienHordeXY
	lw t1, 8(t0)                          ; dir = AlienHordeXY->dir;
	nop 
	bnez t1, AlienHordeLeft               ; if(dir != 0) { goto AlienHordeLeft; }
	nop 
	lw t1, 0(t0)                          ; x = AlienHordeXY->x;
	li t2,(VS_WIDTH / 2) - VS_ALIEN_W- 15 ; max_x = (VS_WIDTH / 2) - VS_ALIEN_W - 15;
	sll t2, 12 
	addi t1, VS_FIXED_VELOCITY            ; x += VS_FIXED_VELOCITY;   
	bge t1, t2, SwitchDirection           ; if(x >= max_x) { goto SwitchDirection; }
	sw t1, 0(t0)                          ; AlienHordeXY->x = x;
	b BulletLogic
	nop
AlienHordeLeft:
	lw t1, 0(t0)                          ; x = AlienHordeXY->x;
	nop 
	subi t1, VS_FIXED_VELOCITY            ; x -= VS_FIXED_VELOCITY;
	bltz t1, SwitchDirection              ; if(x < 0) { goto SwitchDirection; }
	sw t1, 0(t0)                          ; AlienHordeXY->x = x;
	b BulletLogic
	nop
SwitchDirection:
	la t0, AlienHordeXY
	lw t1, 8(t0)                          ; dir = AlienHordeXY->dir;
	lw t2, 4(t0)                          ; y = AlienHordeXY->y;
	nor t1, t1, zero                      ; dir = !(dir | 0)
	sw t1, 8(t0)                          ; AlienHordeXY->dir = dir;
	addi t2, VS_ALIEN_H                   ; y += VS_ALIEN_H;
	sw t2, 4(t0)                          ; AlienHordeXY->y = y;
	li t1, 224 - ((VS_ALIEN_H+5)*VS_ALIEN_NUM_ROWS) - 30 ; max_y = 224 - ((VS_ALIEN_H+5)*VS_ALIEN_NUM_ROWS) - 30;
	bge t2, t1, PrepareReset              ; if(y >= max_x) { goto PrepareReset; }
	nop
	b BulletLogic                         ; goto BulletLogic;
	nop 
PrepareReset:
	lw t0, PlayerLives                    ; lives = *(unsigned long*)PlayerLives; (Delay Slot)
	nop
	subi t0, 1                            ; lives--;
	beqz t0, InitGame                     ; if(lives == 0) { goto InitGame; }
	nop
	sw t0, PlayerLives                    ; *(unsigned long*)PlayerLives = lives; (Delay Slot)
	b ResetLevel                          ; goto ResetLevel;
	nop
BulletLogic:
	la t0, BulletXY
	lw t1, 8(t0)                          ; active = BulletXY->active;
	nop 
	beqz t1, PRESSLEFT                    ; if(!active) { goto PRESSLEFT; }
	nop 
	lw t1, 4(t0)                          ; y = BulletXY->y;
	nop
	subi t1, VS_BULLET_VELOCITY           ; y -= VS_BULLET_VELOCITY;
	blez t1, ResetBullet                  ; if(y <= 0) { goto ResetBullet; }
	nop
	sw t1, 4(t0)                          ; BulletXY->y = y;
	b PRESSLEFT                           ; goto PRESSLEFT;
	nop
ResetBullet:
	sw zero, 8(t0)                        ; BulletXY->active = 0;
PRESSLEFT:
    lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop                  
    andi t0, VS_JOY_LEFT                  ; pad_data &= VS_JOY_LEFT;
    beqz t0, PRESSRIGHT         		  ; if(!pad_data) { goto PRESSDOWN; }
    nop 
	lw t0, 16(s0)
	nop 
	subi t0, VS_VELOCITY                  ; player_x -= VS_VELOCITY;
	blez t0, PRESSRIGHT                   ; if(player_x <= 0) { goto PRESSRIGHT; }
	nop
	sw t0, 16(s0)
PRESSRIGHT:
    lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_RIGHT                 ; pad_data &= VS_JOY_RIGHT;
    beqz t0, PRESSX    		              ; if(!pad_data){ goto PRESSX; }
    nop  
	lw t0, 16(s0)
	li t1, VS_WIDTH - VS_DEFENDER_W       ; w = VS_WIDTH - VS_DEFENDER_W; (Delay Slot)
	addi t0, VS_VELOCITY                  ; player_x += VS_VELOCITY;
	bge t0, t1, PRESSX                    ; if(player_x >= w) { goto PRESSX; }
	nop
	sw t0, 16(s0)
PRESSX:
	lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_X                     ; pad_data &= VS_JOY_X;
    beqz t0, FillScreen    		          ; if(!pad_data){ goto FillScreen; }
	nop 
	la t0, BulletXY
	lw t1, 8(t0)                          ; active = BulletXY->active;
	nop 
	bnez t1, FillScreen                   ; if(active) { goto FillScreen; }
	li t2, 1                              ; new_active = 1; (Delay Slot)
	lw t1, 16(s0)                         ; x = player_x;
	lw t3, 20(s0)                         ; y = player_y;
	addi t1, (VS_DEFENDER_W / 2)          ; x += (VS_DEFENDER_W / 2);
	subi t3, VS_DEFENDER_H                ; y -= VS_DEFENDER_H;
	sw t2, 8(t0)                          ; BulletXY->active = new_active;
	sw t1, 0(t0)                          ; BulletXY->x = x;
	sw t3, 4(t0)                          ; BulletXY->y = y;
	move a0, zero                         ; channel = 0;
	jal VS_TurnOnChannel                  ; VS_TurnOnChannel(channel);
	nop
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
DrawAlienHorde:
	li a0, 2                              ; mode = 0x2;
	li a1, 1                              ; alpha = true;
	li a2, VS_ALIEN_VRAM_X                ; vram_x = VS_ALIEN_VRAM_X;
	li a3, VS_ALIEN_VRAM_Y                ; vram_y = VS_ALIEN_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop 
	la t0, AlienHordeXY
	la s1, AlienArr                       ; arr = AlienArr;
	li s2, VS_ALIEN_NUM_ROWS              ; rows = VS_ALIEN_NUM_ROWS;
	lw s5, 4(t0)                          ; start_y = AlienHordeXY;
	move s6, v0
DrawAlienColumn:
	li s3, VS_ALIEN_NUM_COLS              ; cols = VS_ALIEN_NUM_COLS;
	addi s5, VS_ALIEN_H + 5               ; start_y += VS_ALIEN_H + 5;
	la t0, AlienHordeXY
	lw s4, 0(t0)                          ; start_x = AlienHordeXY->x;
	nop 
	sra s4, 12
DrawAlienLoop:
	la t0, BulletXY                       
	lw t1, 8(t0)                          ; active = BulletXY->active;
	nop 
	beqz t1, LoadAlienFromArr             ; if(!active) { goto LoadAlienFromArr; }
	nop 
	lbu a0, 0(s1)                         ; alien_alive = *arr;
	nop
	beqz a0, LoadAlienFromArr             ; if(!alien_alive) { goto LoadAlienFromArr; }
	nop
	lw a0, 0(t0)                          ; x1 = BulletXY->x;
	lw a1, 4(t0)                          ; x2 = BulletXY->y;
	li a2, VS_BULLET_W                    ; w1 = VS_BULLET_W;
	li a3, VS_BULLET_H                    ; h1 = VS_BULLET_H;
	sw s4, 16(sp)                         ; x2 = start_x;                  
	sw s5, 20(sp)                         ; y2 = start_y;
	li t0, VS_ALIEN_W                     ; w2 = VS_ALIEN_W;
	sw t0, 24(sp)                         ; h2 = VS_ALIEN_H;
	li t0, VS_ALIEN_H                    
	sw t0, 28(sp)                     
	jal DetectAABBCollision               ; collide = DetectAABBCollision(x1,y1,w1,h1,x2,y2,w2,h2);
	nop
	beqz v0, LoadAlienFromArr             ; if(!collide) { goto LoadAlienFromArr; } 
	nop
	la t0, BulletXY
	sb zero, 0(s1)                        ; *arr = 0;
	sw zero, 8(t0)                        ; BulletXY->active = 0;
	lw t0, Score                          ; score = *Score;
	nop 
	addi t0, 50                           ; score += 50;
	sw t0, Score                          ; *Score = score;
	lw t1, HighScore                      ; highscore = *HighScore;
	nop 
	ble t0, t1, LoadAlienFromArr          ; if(score <= highscore) { goto LoadAlienFromArr; }
	nop 
	sw t0, HighScore                      ; *HighScore = score;
LoadAlienFromArr:
	lbu a0, 0(s1)                         ; alien_alive = *arr;
	addi s1, 1                            ; arr++; (Delay Slot)
	beqz a0, IncrementAlienArr            ; if(!alien_alive) { goto IncrementAlienArr; }
	nop 
TextureAlien:	
	move a0, s4                           ; x = start_x;
	move a1, s5                           ; y = start_y;
	move a2, s6
	jal VS_TextureDefender                ; VS_TextureDefender(x,y,texpage);
	nop
IncrementAlienArr:
	subi s3, 1                            ; cols--;
	bnez s3, DrawAlienLoop                ; if(cols != 0) { goto DrawAlienLoop; }
	addi s4, VS_ALIEN_W + 5               ; start_x += VS_ALIEN_W + 5; (Delay Slot)
	subi s2, 1                            ; rows--;
	bnez s2, DrawAlienColumn              ; if(rows != 0) { goto DrawAlienColumn; }
	nop
DrawHUD:
	li a0, 0                              ; x1 = 0;
	li a1, 210                            ; y1 = 210;
	li a2, VS_WIDTH                       ; x2 = VS_WIDTH;
	li a3, 210                            ; y2 = 210;
	li t0, $00FF00                        ; color = 0x00FF00;
	sw t0, 16(sp)
	jal VS_DrawMonochromeLine             ; VS_DrawMonochromeLine(x1,y1,x2,y2,color);
	nop
	lw s1, PlayerLives                    ; lives = *(unsigned long*)PlayerLives
	li s2, 10                             ; start_x = 10;
	li a0, 2                              ; mode = 16-bit;
	li a1, 1                              ; alpha = true;
	li a2, VS_DEFENDER_VRAM_X             ; vram_x = VS_DEFENDER_VRAM_X;
	li a3, VS_DEFENDER_VRAM_Y             ; vram_y = VS_DEFENDER_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	move s3, v0
	la a0, ScoreText                      ; string = ScoreText;
	addi a0, 6                            ; string += strlen("SCORE ");
	lw a1, Score                          ; int = *Score;
	nop 
	jal VS_Int2String                     ; digits = VS_Int2String(string,int);
	nop
	li a0, 80                             ; x = 80;
	li a1, 456                            ; y = 456;
	la a2, ScoreText                      ; string = ScoreText;
	move a3, v0 
	addi a3, 5                            ; len = digits + strlen("SCORE ") - 1;
	jal VS_DrawString                     ; VS_DrawString(string, len);
	nop
	la a0, HighScoreText                  ; string = ScoreText;
	addi a0, 10                           ; string += strlen("HIGHSCORE ");
	lw a1, HighScore                      ; int = *HighScore;
	nop 
	jal VS_Int2String                     ; digits = VS_Int2String(string,int);
	nop
	li a0, 10                             ; x = 10;
	li a1, 252                            ; y = 252;
	la a2, HighScoreText                  ; string = HighScoreText;
	move a3, v0 
	addi a3, 9                            ; len = digits + strlen("HIGHSCORE ") - 1;
	jal VS_DrawString                     ; VS_DrawString(string, len);
	nop
DrawLivesLoop:
	move a0, s2                           ; x = start_x;
	li a1, 215                            ; y = 215;
	move a2, s3                           
	jal VS_TextureDefender                ; VS_TextureDefender(x,y,texpage);
	subi s1, 1                            ; lives--; (Delay Slot)
	bgtz s1, DrawLivesLoop                ; if(lives > 0) { goto DrawLivesLoop; }
	addi s2, VS_DEFENDER_W + 5            ; start_x += VS_DEFENDER_W + 5; (Delay Slot)
DrawDefender:
	li a0, 2                              ; mode = 16-bit;
	li a1, 1                              ; alpha = true;
	li a2, VS_DEFENDER_VRAM_X             ; vram_x = VS_DEFENDER_VRAM_X;
	li a3, VS_DEFENDER_VRAM_Y             ; vram_y = VS_DEFENDER_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	lw a0, 16(s0)                         ; x = player_x;
	lw a1, 20(s0)                         ; y = player_y;
	move a2, v0                           
	jal VS_TextureDefender                ; VS_TextureDefender(x,y,texpage);
	nop
DrawBullet:
	la t0, BulletXY
	lw t1, 8(t0)                          ; active = BulletXY->active;
	nop 
	beqz t1, SetupRandomization           ; if(!active) { goto SetupRandomization; }
	nop
	lw a0, 0(t0)                          ; x = BulletXY->x;
	lw a1, 4(t0)                          ; y = BulletXY->y;
	li a2, VS_BULLET_W                    ; w = VS_BULLET_W;
	li a3, VS_BULLET_H                    ; h = VS_BULLET_H;
	li t0, $FFFFFF                        ; color = 0xFFFFFF;
	sw t0, 16(sp)
	jal VS_FillMonochromeRect             ; VS_FillMonochromeRect(x,y,w,h,color);
	nop
SetupRandomization:
	lw t0, CooldownObj                    ; cooldown = *CooldownObj;
	nop 
	bnez t0, SetupAlienBullets            ; if(cooldown != 0) { SetupAlienBullets; }
	nop
	jal CountNumAliensAlive               ; count = CountNumAliensAlive();
	nop
	beqz v0, SetupAlienBullets            ; if(count == 0) { goto SetupAlienBullets; }
	nop
	la t0, AlienBulletArr                 ; bullet_arr = AlienBulletArr;
	la t1, AlienArr                       ; arr = AlienArr;
	li t2, 0                              ; count = 0;
	li t3, VS_NUM_ALIENS                  ; size = VS_NUM_ALIENS;
AllowRandomAlienToShoot:
	bge t2, t3, SetupAlienBullets         ; if(count >= size) { goto SetupAlienBullets; }
	nop
	jal VS_Rand                           ; rand = VS_Rand();
	addi t2, 1                            ; size++; (Delay Slot)
	addu t4, t1, v0                       ; temp_arr = arr + rand;
	lbu t4, 0(t4)                         ; alive = *temp_arr;
	nop 
	beqz t4, AllowRandomAlienToShoot      ; if(!alive) { goto AllowRandomAlienToShoot; }
	nop
	li t4, 12                             ; bullet_struct_size = 12;
	mult t4, v0                           ; offset = bullet_struct_size * rand;
	mflo t4 
	addu t4, t0, t4                       ; bullet = bullet_arr + offset;
	lw t5, 8(t4)                          ; active = bullet->active;
	nop 
	bnez t5, AllowRandomAlienToShoot      ; if(active) { goto AllowRandomAlienToShoot; } 
	nop 
	li t5, 1
	sw t5, 8(t4)                          ; bullet->active = 1;
	li t5, VS_BULLET_COOLDOWN             ; cooldown = VS_BULLET_COOLDOWN;
	sw t5, CooldownObj                    ; *CooldownObj = cooldown;
SetupAlienBullets:
	jal UpdateAlienBullets
	nop
	jal UpdateOffsetArr
	nop
	la s2, AlienBulletArr                 ; arr = AlienBulletArr;
	li s3, VS_NUM_ALIENS                  ; size = VS_NUM_ALIENS;
DrawAlienBullets:
	beqz s3, DetectCollision              ; if(size == 0) { goto DetectCollision }
	lw t2, 8(s2)                          ; active = arr[0]->active; (Delay Slot)
	subi s3, 1                            ; size--; (Delay Slot)
	beqz t2, IncrBulletArr                ; if(!active) { goto IncrBulletArr; }
	nop
DrawAlienBullet:
	lw a0, 0(s2)                          ; x = arr[0]->x;
	lw a1, 4(s2)                          ; y = arr[0]->y;
	li a2, VS_BULLET_W                    ; w = VS_BULLET_W;
	li a3, VS_BULLET_H                    ; h = VS_BULLET_H;
	li t3, $FFFFFF                        ; color = 0xFFFFFF;
	sw t3, 16(sp)
	jal VS_FillMonochromeRect             ; VS_FillMonochromeRect(x,y,w,h,color);
	nop
IncrBulletArr:
	bnez s3, DrawAlienBullets             ; if(size != 0) { DrawAlienBullets; } 
	addi s2, 12                           ; arr += 12; (Delay Slot)
DetectCollision:
	jal DetectAlienBulletCollision        ; collide = DetectAlienBulletCollision();
	nop
	beqz v0, BufferSwap                   ; if(!collide) { goto BufferSwap; }
	nop
	lw t0, PlayerLives                    ; lives = PlayerLives;
	nop 
	subi t0, 1                            ; lives--;
	sw t0, PlayerLives                    ; PlayerLives = lives; (Delay Slot)
	b ResetLevel
	nop
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
WaitVSync:                                ; Wait For Vertical Retrace Period & Store XOR Pad Data
    lw  t0, 0(s0)                         ; Load Pad Buffer
    nop               
    beqz t0, WaitVSync                    ; if(pad_buffer == 0){ goto Wait; }
    nor t0, zero                          ; pad_buffer = !(pad_buffer | 0);
    sw zero, 0(s0)                        ; Store Zero To Pad Buffer
    sw t0, 8(s0)                          ; Store Pad Data
Cooldown:
	lw t0, CooldownObj                    ; cooldown = *(unsigned long*)ResetCooldown;
	nop 
	blez t0, main                         ; if(cooldown <= 0) { goto main; }
	nop 
	subi t0, 1                            ; cooldown--;
	sw t0, CooldownObj                    ; *(unsigned long*)ResetCooldown = cooldown;
main:
	b Input 
	nop
	jal VS_ShutdownAudio
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
	
# Function: VS_TextureDefender
# Purpose: Textures the player to the (X,Y) screen coordinates
# a0: x, a1: y, a2: texpage
VS_TextureDefender:
	subi sp, sp, 80 
	sw ra, 4(sp)
	move t0, a2
	li a2, $0            ; palette = 0;
	li a3, $0            ; u1 = 0;
	sw zero, 16(sp)      ; v1 = 0;
	sw a0, 20(sp)        ; x2 = VS_PLAYER_X;
	li t1, VS_DEFENDER_H
	add t1, t1, a1 
	sw t1, 24(sp)        ; y2 = VS_PCAR_Y + VS_DEFENDER_H;
	sw t0, 28(sp)        ; texpage = GetTexturePage(2,1,VS_PLAYER_X,VS_PLAYER_Y); 
	sw zero, 32(sp)      ; u2 = 0;
	li t1, VS_DEFENDER_H 
	sw t1, 36(sp)        ; v2 = VS_DEFENDER_H;
	li t1, VS_DEFENDER_W 
	addu t1, t1, a0
	sw t1, 40(sp)        ; x3 = VS_PLAYER_X + VS_DEFENDER_W;
	sw a1, 44(sp)        ; y3 = VS_PCAR_Y;
	li t1, VS_DEFENDER_W 
	sw t1, 48(sp)        ; u3 = VS_DEFENDER_W;
	sw zero, 52(sp)      ; v3 = 0;
	li t1, VS_DEFENDER_W 
	add t1, t1, a0
	sw t1, 56(sp)        ; x4 = VS_PLAYER_X + VS_DEFENDER_W;
	li t1, VS_DEFENDER_H 
	add t1, t1, a1 
	sw t1, 60(sp)        ; y4 = VS_PCAR_Y + VS_DEFENDER_H;
	li t1, VS_DEFENDER_W 
	sw t1, 64(sp)        ; u4 = VS_DEFENDER_W;
	li t1, VS_DEFENDER_H 
	sw t1, 68(sp)        ; v4 = VS_DEFENDER_H;
	jal VS_TextureFourPointPoly
	nop
	jal DrawSync
	nop
	lw ra, 4(sp)
	addi sp, sp, 80
	jr ra 
	nop
	
# Function: VS_TextureAlien
# Purpose: Textures an alien to the (X,Y) screen coordinates
# a0: x, a1: y, a2: texpage
VS_TextureAlien:
	subi sp, sp, 80 
	sw ra, 4(sp)
	move t0, a2
	li a2, $0            ; palette = 0;
	li a3, $0            ; u1 = 0;
	sw zero, 16(sp)      ; v1 = 0;
	sw a0, 20(sp)        ; x2 = x;
	li t1, VS_ALIEN_H
	add t1, t1, a1 
	sw t1, 24(sp)        ; y2 = y + VS_ALIEN_H;
	sw t0, 28(sp)        ; texpage = GetTexturePage(2,1,x,y); 
	sw zero, 32(sp)      ; u2 = 0;
	li t1, VS_ALIEN_H 
	sw t1, 36(sp)        ; v2 = VS_ALIEN_H;
	li t1, VS_ALIEN_W 
	addu t1, t1, a0
	sw t1, 40(sp)        ; x3 = x + VS_ALIEN_W;
	sw a1, 44(sp)        ; y3 = y;
	li t1, VS_ALIEN_W 
	sw t1, 48(sp)        ; u3 = VS_ALIEN_W;
	sw zero, 52(sp)      ; v3 = 0;
	li t1, VS_ALIEN_W 
	add t1, t1, a0
	sw t1, 56(sp)        ; x4 = x + VS_ALIEN_W;
	li t1, VS_ALIEN_H 
	add t1, t1, a1 
	sw t1, 60(sp)        ; y4 = y + VS_ALIEN_H;
	li t1, VS_ALIEN_W 
	sw t1, 64(sp)        ; u4 = VS_ALIEN_W;
	li t1, VS_ALIEN_H 
	sw t1, 68(sp)        ; v4 = VS_ALIEN_H;
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
# a0: x, a1: y, a2: string, a3: strlen 
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
	blez a3, end
	subi a3, a3, 0x1     ; strlen--; (delay slot)
	b DrawChar
	nop
vs_draw_space:
	addi t1, t1, VS_FONTW ; x += VS_FONTW;
	b   DrawChar
	subi a3, a3, 0x1      ; strlen--;
vs_draw_new_line:
	addi a1, a1, VS_FONTH ; y += VS_FONTH;
	b   DrawChar
	subi a3, a3, 0x1      ; strlen--;
end:
	lw ra, 0(sp)
    lw s0, 4(sp)
    addiu sp, sp, 8
    jr ra
	nop
	
# Function: VS_Int2String
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
	
# Function: InitGame
# Purpose: Initializes all the primary game variables
InitGame:
	sw zero, Score
	sw zero, CooldownObj
	la t0, AlienHordeXY               
	li t1, 10                             ; start_x = 10;
	sw t1, 0(t0)                          ; AlienHordeXY->x = start_x;
	li t1, 15                             ; start_y = 15;
	sw t1, 4(t0)                          ; AlienHordeXY->y = start_y;
	sw zero, 8(t0)                        ; AlienHordeXY->dir = 0;
	li t0, VS_NUM_LIVES                   ; lives = VS_NUM_LIVES;
	sw t0, PlayerLives                    ; *(unsigned long*)PlayerLives = lives;
	li t1, VS_PLAYER_X                    ; x = VS_PLAYER_X;
	sw t1, 16(s0)
	li t1, VS_PLAYER_Y                    ; y = VS_PLAYER_Y;
	sw t1, 20(s0)
	la t0, BulletXY                       
	sw zero, 0(t0)                        ; BulletXY->x = 0;
	sw zero, 4(t0)                        ; BulletXY->z = 0;
	sw zero, 8(t0)                        ; BulletXY->active = 0;
	la t0, AlienArr                       ; arr = AlienArr;
	li t1, VS_NUM_ALIENS                  ; size = VS_NUM_ALIENS;
	li t2, 1            
	la t3, AlienBulletArr                 ; bullet_arr = AlienBulletArr;
InitAlienLoop:
	sw zero, 0(t3)                        ; bullet_arr[0]->x = 0;
	sw zero, 4(t3)                        ; bullet_arr[0]->y = 0;
	sw zero, 8(t3)                        ; bullet_arr[0]->active = 0;
	addi t3, 12                           ; bullet_arr += 12;
	sb t2, 0(t0)                          ; *arr = 1;
	subi t1, 1                            ; size--;
	bnez t1, InitAlienLoop                ; if(size != 0) { goto InitAlienLoop; }
	addi t0, 1                            ; arr++; (Delay Slot)
	b Input 
	nop
	
# Function: ResetLevel
# Purpose: Resets all the primary game variables
ResetLevel:
	sw zero, CooldownObj
	la t0, AlienHordeXY               
	li t1, 10                             ; start_x = 10;
	sw t1, 0(t0)                          ; AlienHordeXY->x = start_x;
	li t1, 15                             ; start_y = 15;
	sw t1, 4(t0)                          ; AlienHordeXY->y = start_y;
	sw zero, 8(t0)                        ; AlienHordeXY->dir = 0;
	li t1, VS_PLAYER_X                    ; x = VS_PLAYER_X;
	sw t1, 16(s0)
	li t1, VS_PLAYER_Y                    ; y = VS_PLAYER_Y;
	sw t1, 20(s0)
	la t0, BulletXY                       
	sw zero, 0(t0)                        ; BulletXY->x = 0;
	sw zero, 4(t0)                        ; BulletXY->z = 0;
	sw zero, 8(t0)                        ; BulletXY->active = 0;
	la t0, AlienArr                       ; arr = AlienArr;
	li t1, VS_NUM_ALIENS                  ; size = VS_NUM_ALIENS;
	li t2, 1          
	la t3, AlienBulletArr                 ; bullet_arr = AlienBulletArr;
ResetAlienLoop:
	sw zero, 0(t3)                        ; bullet_arr[0]->x = 0;
	sw zero, 4(t3)                        ; bullet_arr[0]->y = 0;
	sw zero, 8(t3)                        ; bullet_arr[0]->active = 0;
	addi t3, 12                           ; bullet_arr += 12;	
	sb t2, 0(t0)                          ; *arr = 1;
	subi t1, 1                            ; size--;
	bnez t1, ResetAlienLoop               ; if(size != 0) { goto ResetAlienLoop; }
	addi t0, 1                            ; arr++; (Delay Slot)
	b Input 
	nop
	
# Function: CountNumAliensAlive
# Purpose: Returns the number of aliens alive in the alien horde
CountNumAliensAlive:
	la t0, AlienArr                       ; arr = AlienArr
	li t1, VS_NUM_ALIENS                  ; size = VS_NUM_ALIENS;
	move v0, zero                         ; count = 0;
AliveAliens:
	beqz t1, AliveAlienEnd                ; if(size == 0) { goto AliveAlienEnd; }
	lbu t3, 0(t0)                         ; alive = *arr; (Delay Slot)
	subi t1, 1                            ; size--; (Delay Slot)
	beqz t3, AliveAliens                  ; if(!alive) { goto AliveAliens };
	addi t0, 1                            ; arr++; (Delay Slot)
	bnez t1, AliveAliens                  ; if(size != 0) { goto AliveAliens; }
	addi v0, 1                            ; count++; (Delay Slot)
AliveAlienEnd:
	jr ra 
	nop
	
# Function: UpdateAlienBullets
# Purpose: Increments the y-value of all active bullets and deactives the ones that go off screen 
UpdateAlienBullets:
	la t0, AlienBulletArr       ; arr = AlienBulletArr;
	li t1, VS_NUM_ALIENS        ; size = VS_NUM_ALIENS;
AlienBulletLoop:
	lw t2, 8(t0)                ; active = arr[0]->active;
	subi t1, 1                  ; size--; (Delay Slot)
	beqz t2, FinishItr          ; if(!active) { goto FinishItr; }
	nop 
	lw t2, 4(t0)                ; y = arr[0]->y;
	li t3, VS_HEIGHT            ; max_y = VS_HEIGHT; 
	addi t2, VS_BULLET_VELOCITY ; y += VS_BULLET_VELOCITY;
	blt t2, t3, FinishItr       ; if(y < max_y) { goto FinishItr; }
	sw t2, 4(t0)                ; arr[0]->y = y;
ResetAlienBullet:
	sw zero, 8(t0)              ; arr[0]->active = 0;
FinishItr:
	addi t4, 8                  ; offset_arr += 8;
	bnez t1, AlienBulletLoop    ; if(size != 0) { goto AlienBulletLoop; }
	addi t0, 12                 ; arr += 12; (Delay Slot)
	jr ra 
	nop
	
# Function: DetectAlienBulletCollision
# Purpose: Resets the level and removes a life from the player if a bullet from the alien horde collides with the player 
DetectAlienBulletCollision:
	la s1, AlienBulletArr        ; bullet_arr = AlienBulletArr;
	li s2, VS_NUM_ALIENS         ; size = VS_NUM_ALIENS;
	addi sp, -36                 
	sw ra, 4(sp)
BulletCollisionLoop:
	lw t0, 8(s1)                 ; active = bullet_arr[0]->active;
	subi s2, 1                   ; size--; (Delay Slot)
	beqz t0, DoItr               ; if(!active) { goto DoItr; }
	nop
	lw a0, 0(s1)                 ; x1 = bullet_arr[0]->x;
	lw a1, 4(s1)                 ; x2 = bullet_arr[0]->y;
	li a2, VS_BULLET_W           ; w1 = VS_BULLET_W;
	li a3, VS_BULLET_H           ; h1 = VS_BULLET_H;
	lw t0, 16(s0)
	lw t1, 20(s0)
	sw t0, 16(sp)                ; x2 = player_x;                  
	sw t1, 20(sp)                ; y2 = player_y;
	li t0, VS_DEFENDER_W         ; w2 = VS_DEFENDER_W;
	sw t0, 24(sp)                ; h2 = VS_DEFENDER_H;
	li t0, VS_DEFENDER_H                    
	sw t0, 28(sp)                     
	jal DetectAABBCollision      ; collide = DetectAABBCollision(x1,y1,w1,h1,x2,y2,w2,h2);
	nop
	bnez v0, BulletCollided      ; if(collide) { goto BulletCollided; }
	nop
DoItr:
	bnez s2, BulletCollisionLoop ; if(size != 0) { goto BulletCollisionLoop; }
	addi s1, 12                  ; bullet_arr += 12; (Delay Slot)
	lw ra, 4(sp)
	addi sp, 36
	move v0, zero 
	jr ra 
	nop
BulletCollided:
	lw ra, 4(sp)
	addi sp, 32
	jr ra 
	nop
	
# Function: UpdateOffsetArr
# Purpose: Updates the (X,Y) coordinate pair locations of each alien in the alien horde 
UpdateOffsetArr:
	la t0, AlienHordeXY
	li t1, VS_ALIEN_NUM_ROWS              ; rows = VS_ALIEN_NUM_ROWS;
	lw t2, 4(t0)                          ; start_y = AlienHordeXY;
	la t5, AlienBulletArr                 ; bullet_arr = AlienBulletArr;
	addi t2, 15
	lw t6, 0(t0)                          ; org_x = AlienHordeXY->x;
	nop 
	sra t6, 12
	addi t6, 5
UpdateAlienColumn:
	li t3, VS_ALIEN_NUM_COLS              ; cols = VS_ALIEN_NUM_COLS;
	move t4, t6                           ; start_x = org_x;
UpdateAlienRow:
	lw t7, 8(t5)                          ; active = bullet_arr[2];
	nop 
	bnez t7, FinishUpdate
	nop
StoreCoords:
	sw t4, 0(t5)                          ; bullet_arr[0] = start_x;
	sw t2, 4(t5)                          ; bullet_arr[1] = start_y;
FinishUpdate:
	addi t5, 12                           ; bullet_arr += 8;
	subi t3, 1                            ; cols--;
	bnez t3, UpdateAlienRow               ; if(cols != 0) { goto UpdateAlienRow; }
	addi t4, VS_ALIEN_W + 5               ; start_x += VS_ALIEN_W + 5; (Delay Slot)
	subi t1, 1                            ; rows--;
	bnez t1, UpdateAlienColumn            ; if(rows != 0) { goto UpdateAlienColumn; }
	addi t2, VS_ALIEN_H + 5               ; start_y += VS_ALIEN_H + 5;
	jr ra 
	nop
	
# Function: VS_Rand
# Purpose: Utilizes the original Doom random function to generate a random unsigned 8-bit integer
VS_Rand:
	la a0, vs_rand_index
	lw a1, 0(a0)
	nop 
	addiu a1, 1          ; vs_rand_index++;
	andi  a1, $ff        ; vs_rand_index &= $ff;
	la  a2, rndtable
	addu a2, a1          ; rndtable += vs_rand_index;
	lbu v0, 0(a2)        ; num = *rndtable;
	sw a1, 0(a0)
	jr ra 
	nop
	
.include "../lib/audio.asm"

.data
PlayerLives:
	.dw 0 
	
CooldownObj:
	.dw 0 
	
BulletXY:
	.dw 0 
	.dw 0
	.dw 0
	
AlienHordeXY:
	.dw 0 
	.dw 0 
	.dw 0
	
Score:
	.dw 0 
	
HighScore:
	.dw 0
	
vs_rand_index:
	.dw 0
	
AlienBulletArr:
	.empty, VS_NUM_ALIENS * 12
	
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

.align, 4
Font:
	.incbin "font.bin"
	
.align, 4 
DefenderTexture:
	.dh 0,0,0,0,0,0,$3e0,0,0,0,0,0,0,0,0,0,0,0,$3e0,$3e0,$3e0,0,0,0,0,0,0,0,0,0,0,$3e0,$3e0,$3e0,0,0,0,0
	.dh 0,0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0
	.dh $3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0
	.dh $3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0,$3e0
	
.align, 4 
AlienTexture:
	.dh 0,0,$7fff,0,0,0,0,0,$7fff,0,0,0,0,0,$7fff,0,0,0,$7fff,0,0,0,0,0,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff
	.dh 0,0,0,$7fff,$7fff,0,$7fff,$7fff,$7fff,0,$7fff,$7fff,0,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff
	.dh $7fff,$7fff,$7fff,0,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,0,$7fff,$7fff,0,$7fff,0,0,0,0,0,$7fff,0,$7fff
	.dh 0,0,0,$7fff,$7fff,0,$7fff,$7fff,0,0,0
	
AlienArr:
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	
ScoreText:
	.ascii "SCORE               "
	
HighScoreText:
	.ascii "HIGHSCORE               "
	
rndtable:
	.db 18,26,14,8,8,38,11,17,8,46,13,6,2,5,28,3,46,3,43,0,27,27,46,39,22,35,34,29,15,12,1,26,11,11,15,48,10,43,37,2,47,11,47
	.db 12,39,24,7,5,45,39,39,34,18,43,11,15,34,7,23,21,20,22,6,9,38,49,16,25,43,2,21,36,42,23,14,45,4,14,36,12,47,35,15,34,28
	.db 17,33,27,18,35,47,30,21,21,12,5,22,48,27,46,8,4,25,39,21,14,31,9,42,6,45,44,49,44,28,43,14,36,35,39,27,28,43,3,9,15,8
	.db 24,48,47,15,10,46,11,24,23,44,26,34,23,9,23,27,34,22,40,49,41,36,41,18,16,16,40,6,1,6,45,31,17,32,40,19,4,1,46,0,9,19
	.db 41,46,1,17,19,48,7,47,5,38,49,44,5,39,46,49,6,0,31,37,30,7,42,20,33,31,3,28,44,8,9,10,47,39,20,21,25,23,35,33,42,25,9
	.db 1,4,16,16,46,2,20,44,35,11,28,9,32,21,41,16,29,41,32,23,38,9,24,14,48,8,15,46,36,3,22,22,18,29,42,41,6,8,16,36,12,30,19,17
	
.align, 16 
ShootSFX:
	.incbin "shoot.adpcm"