#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# Classic Arcade Game: Speed Race (1974)
#-----------------------------------------------------------
# History
#-----------------------------------------------------------
# Speed Race, though largely forgotten, has firmly cemented 
# its legacy in the annals of video game history by being the 
# first video game to introduce smooth vertical scrolling and
# featured an early racing wheel controller interface with an 
# accelerator, gear shift, speedometer and tachometer.
#-----------------------------------------------------------
# Objective
#-----------------------------------------------------------
# The objective is to avoid colliding and driving past rival 
# cars in order to rack up points. Addition points are given 
# based on the speed of the car, which will come to a complete 
# stop whenever colliding with another car, and though the game 
# is based on a time limit, the timer can be extended by racking 
# up enough points to earn an increase in time.
#-----------------------------------------------------------
# Controls: D-Pad
# Up - Move Car Up 
# Down - Move Car Down 
# Left - Move Car to the Left 
# Right - Move Car to the Right
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
VS_CMD_FILL_RECT equ $60000000            ; Draw A Monochrome Rectangle to the Display Area
VS_TEXTURE_FOUR_POINT_POLY equ $2D000000  ; Draws An Opaque Textured Quad to the Display Area

; PlayStation JoyPad Commands and Variables
VS_CMD_INIT_PAD equ $15
VS_JOY_UP equ $1000 
VS_JOY_DOWN equ $4000
VS_JOY_LEFT equ $8000
VS_JOY_RIGHT equ $2000

VS_RED equ 125
VS_GREEN equ 125
VS_BLUE equ 125

; IMMUTABLE GAME VARIABLES
VS_FONTW equ 8 
VS_FONTH equ 11
VS_SCORE_W equ 38  
VS_SCORE_H equ 10
VS_LIVES_W equ 38  
VS_LIVES_H equ 9
VS_GRASS_COLOR equ $678C18
VS_ROAD_COLOR equ $5E5E5E

VS_ROAD_X equ 40 
VS_ROAD_Y equ 0
VS_ROAD_W equ 176 
VS_ROAD_H equ 240

VS_RSHOULDER_X equ 0 
VS_RSHOULDER_Y equ 0 

VS_LSHOULDER_X equ 216 
VS_LSHOULDER_Y equ 0 

VS_SHOULDER_W equ 40 
VS_SHOULDER_H equ 240 

VS_PCAR_VRAM_X equ 256 
VS_PCAR_VRAM_Y equ 0 
VS_CPUCAR_VRAM_X equ 512 
VS_CPUCAR_VRAM_Y equ 0 

VS_PCAR_W equ 32 
VS_PCAR_H equ 32

VS_STRIP_X equ 38

VS_STRIP_W equ 2 
VS_STRIP_H equ 16

VS_NUM_STRIPS equ 7
VS_NUM_CARS equ 3
VS_NUM_LIVES equ 5

VS_RESET_COOLDOWN equ 120

VS_DRIVING_SAMPLE_RATE equ 44100 
VS_DRIVING_SIZE equ 101042
VS_INTRO_SAMPLE_RATE equ 44100
VS_INTRO_SIZE equ 65378
VS_SONG_SAMPLE_RATE equ 44100
VS_SONG_SIZE equ 83986

VS_CPU_X1 equ 75 
VS_CPU_Y1 equ 0
VS_CPU_X2 equ 150 
VS_CPU_Y2 equ 90
VS_CPU_X3 equ 75 
VS_CPU_Y3 equ 190

; MUTABLE GAME VARIABLES
VS_SCROLL_VELOCITY equ 5
VS_VELOCITY equ 2
VS_CPU_VELOCITY equ 2
VS_PLAYER_X equ (VS_WIDTH / 2)
VS_PLAYER_Y equ 198

VS_MASTER_VOLUME equ $3FFF
VS_CHANNEL_VOLUME equ ($3FFF / 2)
VS_CHANNEL1_VOLUME equ $3FFF
VS_CHANNEL2_VOLUME equ $305F

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
	addi sp, -80
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
	li a1, VS_DRIVING_SAMPLE_RATE         ; sample_rate = VS_DRIVING_SAMPLE_RATE;
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
	la a0, DrivingAudio                   ; adpcm_addr = DrivingAudio;
	li a1, VS_DRIVING_SIZE                ; size = VS_DRIVING_SIZE;
	jal VS_ManuallyWriteADPCM             ; VS_ManuallyWriteADPCM(apdcm_addr,size);
	nop
	li a0, 0                              ; channel = 0;
	jal VS_TurnOnChannel                  ; VS_TurnOnChannel(channel);
	nop
	li a0, 1                              ; channel = 1;
	li a1, VS_CHANNEL1_VOLUME             ; volume = VS_CHANNEL1_VOLUME;
	jal VS_SetChannelVolume               ; VS_SetChannelVolume(channel,volume);
	nop
	li a0, 1                              ; channel = 1;
	li a1, VS_INTRO_SAMPLE_RATE           ; sample_rate = VS_INTRO_SAMPLE_RATE;
	jal VS_SetChannelSampleRate           ; VS_SetChannelSampleRate(channel, sample_rate);
	nop 
	li a0, $1010 + VS_DRIVING_SIZE + 64   ; addr = 0x1010 + VS_DRIVING_SIZE + 64;
	jal VS_SetADPCMAddr                   ; VS_SetChannelADPCMAddr(channel,addr);
	nop
	li a0, 1                              ; channel = 1;
	li a1, $1010 + VS_DRIVING_SIZE + 64   ; addr = 0x1010 + VS_DRIVING_SIZE + 64;
	jal VS_SetChannelADPCMAddr            ; VS_SetChannelADPCMAddr(channel,addr);
	nop
	li a0, $1                             ; channel = 1;
	li a1, $f                             ; sustain = 15;
	jal VS_SetChannelSustainLevel         ; VS_SetChannelSustainLevel(channel, sustain);
	nop
	la a0, IntroAudio                     ; adpcm_addr = DrivingAudio;
	li a1, VS_INTRO_SIZE                  ; size = VS_DRIVING_SIZE;
	jal VS_ManuallyWriteADPCM             ; VS_ManuallyWriteADPCM(adpcm_addr,size);
	nop
	li a0, 1                              ; channel = 1;
	jal VS_TurnOnChannel                  ; VS_TurnOnChannel(channel);
	nop
	li a0, 2                              ; channel = 2;
	li a1, VS_CHANNEL2_VOLUME             ; volume = VS_CHANNEL2_VOLUME;
	jal VS_SetChannelVolume               ; VS_SetChannelVolume(channel,volume);
	nop
	li a0, 2                              ; channel = 2;
	li a1, VS_SONG_SAMPLE_RATE            ; sample_rate = VS_INTRO_SAMPLE_RATE;
	jal VS_SetChannelSampleRate           ; VS_SetChannelSampleRate(channel, sample_rate);
	nop 
	li a0, $1010 + VS_DRIVING_SIZE + VS_INTRO_SIZE + 128  ; addr = 0x1010 + VS_DRIVING_SIZE + 64;
	jal VS_SetADPCMAddr                                   ; VS_SetChannelADPCMAddr(channel,addr);
	nop
	li a0, 2                                              ; channel = 2;
	li a1, $1010 + VS_DRIVING_SIZE + VS_INTRO_SIZE + 128  ; addr = 0x1010 + VS_DRIVING_SIZE + 64;
	jal VS_SetChannelADPCMAddr                            ; VS_SetChannelADPCMAddr(channel,addr);
	nop
	li a0, $2                            ; channel = 2;
	li a1, $f                            ; sustain = 15;
	jal VS_SetChannelSustainLevel        ; VS_SetChannelSustainLevel(channel, sustain);
	nop
	la a0, Song                          ; adpcm_addr = Song;
	li a1, VS_SONG_SIZE                  ; size = VS_SONG_SIZE;
	jal VS_ManuallyWriteADPCM            ; VS_ManuallyWriteADPCM(adpcm_addr,size);
	nop
TransferSpritesToVram:
	li a0, VS_PCAR_VRAM_X                 ; vram_x = VS_PCAR_VRAM_X;
	li a1, VS_PCAR_VRAM_Y                 ; vram_y = VS_PCAR_VRAM_Y;
	li a2, VS_PCAR_W                      ; image_w = VS_PCAR_W;
	li a3, VS_PCAR_H                      ; image_h = VS_PCAR_H;
	la t1, PlayerCarImage                 ; image = PlayerCarImage;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,image);
	nop
	li a0, VS_CPUCAR_VRAM_X               ; vram_x = VS_CPUCAR_VRAM_X;
	li a1, VS_CPUCAR_VRAM_Y               ; vram_y = VS_CPUCAR_VRAM_Y;
	li a2, VS_PCAR_W                      ; image_w = VS_PCAR_W;
	li a3, VS_PCAR_H                      ; image_h = VS_PCAR_H;
	la t1, CPUCarImage                    ; image = CPUCarImage;
	sw t1, 16(sp)
	jal TransferImageDataToVram           ; TransferImageDataToVram(vram_x,vram_y,image_w,image_h,image);
	nop
	sw zero, HighScore                    ; *HighScore = 0;
InitPad: 
    li t1,VS_CMD_INIT_PAD                 ; OutdatedPadInitAndStart() Function Is 0x15
    li a0, $20000001
    li t2, $B0                            ; Call a B-Type BIOS Function 
    li a1, VS_IO                          ; Set Pad Buffer Address To Automatically Update Each Frame
    jalr t2                               ; Jump To BIOS Routine OutdatedPadInitAndStart()
    nop ; Delay Slot
	li s0, VS_IO
	sw zero, 8(s0) 
	b InitGame
	sw zero, 12(s0) 
InitStrips:
	la t0, StripYCoords                   ; y_coords = (unsigned long*)StripYCoords;
	li t1, VS_NUM_STRIPS                  ; size = VS_NUM_STRIPS;
	li t2, 0                              ; y = 0;
InitStripsLoop:
	sw t2, 0(t0)                          ; *y_coords = y;
	addi t0, 4                            ; y_coords += 4;
	addi t2, 32                           ; y += 32;
	bnez t1, InitStripsLoop               ; if(size != 0) { goto InitStripsLoop; }
	subi t1, 1                            ; size-- (Delay Slot)
	li s5, 0
Input:
	li a0, 1                              ; channel = 1;
	jal VS_GetChannelStatus               ; status = VS_GetChannelStatus(channel);
	nop 
	beqz v0, ContinueLivesCheck           ; if(!status) { goto ContinueLivesCheck; }
	nop
PlaySong:
	bnez s5, ContinueLivesCheck           ; if(!bool) { goto ContinueLivesCheck; }
	li a0, 2                              ; channel = 2; (Delay Slot)
	jal VS_TurnOnChannel                  ; VS_TurnOnChannel(channel);
	li s5, 1                              ; bool = true;
ContinueLivesCheck:
	lw t0, PlayerLives                    ; lives = *(unsigned long*)PlayerLives;
	li s1, 0                              ; scroll = 0;
	blez t0, InitGame                     ; if(lives <= 0) { goto InitGame; }
	nop
PRESSDOWN:
    lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_DOWN                  ; pad_data &= VS_JOY_DOWN;
    beqz t0, PRESSLEFT    		          ; if(!pad_data){ goto PRESSLEFT; }
    nop 
    lw t0, 20(s0)
    nop
    addi t0, VS_VELOCITY                  ; y += VS_VELOCITY;
	li t1, VS_PLAYER_Y      
	bge t0, t1, PRESSLEFT 		          ; if(y >= (VS_PLAYER_Y) { goto PRESSLEFT; }
	li s1, 1                              ; scroll = 1;
    sw t0, 20(s0)
PRESSLEFT:
    lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop                  
    andi t0, VS_JOY_LEFT                  ; pad_data &= VS_JOY_LEFT;
    beqz t0, PRESSRIGHT         		  ; if(!pad_data) { goto PRESSRIGHT; }
    nop 
    lw t0, 16(s0)          
    nop
    subi t0, VS_VELOCITY       		      ; x -= VS_VELOCITY;
	bltz t0, PRESSRIGHT                   ; if(x < 0) { goto PRESSRIGHT; }
	nop
    sw t0, 16(s0)
PRESSRIGHT:
    lw t0, 8(s0)                          ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_RIGHT                 ; pad_data &= VS_JOY_RIGHT;
    beqz t0, UpdateStrips    		      ; if(!pad_data){ goto UpdateStrips; }
    nop 
    lw t0, 16(s0)
    nop
    addi t0, VS_VELOCITY                  ; x += VS_VELOCITY;
	li t1, VS_WIDTH - VS_PCAR_W        
	bge t0, t1, UpdateStrips 		      ; if(x >= VS_WIDTH - VS_PCAR_W)) { goto UpdateStrips; }
	nop
    sw t0, 16(s0)
UpdateStrips:
	beqz s1, UpdateCPUCars                ; if(!scroll) { goto UpdateCPUCars; }
	nop 
	la t0, StripYCoords                   ; y_coords = (unsigned long*)StripYCoords;
	li t1, VS_NUM_STRIPS                  ; size = VS_NUM_STRIPS;
UpdateStripsLoop:
	lw t2, 0(t0)                          ; strip_y = *y_coords;
	nop
	addi t2, VS_SCROLL_VELOCITY           ; strip_y += VS_SCROLL_VELOCITY; 
	andi t2, $ff                          ; strip_y &= 0xFF;
	sw t2, 0(t0)                          ; *y_coords = strip_y;
	addi t0, 4                            ; y_coords += 4;
	bnez t1, UpdateStripsLoop             ; if(size != 0) { goto UpdateStripsLoop; }
	subi t1, 1                            ; size--; (Delay Slot)
UpdateCPUCars:
	la t0, CPUCarArr                      ; car_arr = (unsigned long*)CPUCarArr;
	beqz s1, MoveCarsUp
	li t1, VS_NUM_CARS                    ; size = VS_NUM_CARS; (Delay Slot)
MoveCarsDown:
	lw t2, 4(t0)                          ; y = car_arr[1];
	subi t1, 1                            ; size--; (Delay Slot)
	blez t2, NoCarReset                   ; if(y <= 0) { goto NoCarReset; }
	addi t2, VS_CPU_VELOCITY              ; y += VS_CPU_VELOCITY (Delay Slot);
WrapCar:
	li t3, 255                            ; max_y = 255;
	ble t2, t3, NoCarReset                ; if(y <= max_y) { goto NoCarReset; }
	nop
	jal VS_Rand                           ; rand = VS_Rand();
	li t2, -VS_PCAR_W                     ; y = -VS_PCAR_W; (Delay Slot)
	lw t3, PlayerScore                    ; score = *(unsigned long*)PlayerScore;
	sw v0, 0(t0)                          ; car_arr[0] = rand; (Delay Slot)
	andi v0, 1                            ; rand_dir = rand & 1;
	sw v0, 8(t0)                          ; carr_arr[2] = rand_dir;
	lw t5, HighScore                      ; highscore = *HighScore;
	addi t3, 75                           ; score += 75; (Delay Slot)
	blt t3, t5, ContinueWrapCar           ; if(score < highscore) { goto ContinueWrapCar; }
	nop
UpdateHighScore:
	sw t3, HighScore                      ; *HighScore = score;
ContinueWrapCar:
	lw t4, 16(s0)                         ; x = player_x;
	li t5, VS_ROAD_X                      ; out_of_bounds = VS_ROAD_X;
	blt t4, t5, OutOfBounds               ; if(x < out_of_bounds) { goto OutOfBounds; }
	nop
	li t5, 186                            ; out_of_bounds = 186;
	bge t4, t5, OutOfBounds               ; if(x >= out_of_bounds) { goto OutOfBounds; }
	nop
	lw t4, CooldownObj                    ; cooldown = CooldownObj;
	bgtz t4, NoCarReset                   ; if(cooldown > 0) { goto NoCarReset; }
	nop
	sw t3, PlayerScore                    ; *(unsigned long*)PlayerScore = score;
	b NoCarReset                          ; goto NoCarReset;
	nop
OutOfBounds:
	subi t3, 100                          ; score -= 100;
	blez t3, NoCarReset                   ; if(score <= 0) { goto NoCarReset; }
	nop
	sw t3, PlayerScore                    ; *(unsigned long*)PlayerScore = score;
NoCarReset:
	sw t2, 4(t0)                          ; car_arr[1] = y;
	bnez t1, MoveCarsDown                 ; if(size != 0) { goto MoveCarsDown; }
	addi t0, 12                           ; car_arr += 12; (Delay Slot)
	b SwerveCars                          ; goto SwerveCars;
	nop
MoveCarsUp:
	lw t2, 4(t0)                          ; y = car_arr[1];
	subi t1, 1                            ; size--; (Delay Slot)
	subi t2, VS_CPU_VELOCITY + 1          ; y -= VS_CPU_VELOCITY + 1;
	sw t2, 4(t0)                          ; car_arr[1] = y;
	bnez t1, MoveCarsUp                   ; if(size != 0) { goto MoveCarsUp; }
	addi t0, 12                           ; car_arr += 12; (Delay Slot)
SwerveCars:
	la t0, CPUCarArr                      ; car_arr = (unsigned long*)CPUCarArr;
	li t1, VS_NUM_CARS                    ; size = VS_NUM_CARS; (Delay Slot) 
SwerveCarLoop:
	lw t2, 8(t0)                          ; dir = car_arr[2];
	nop
	beqz t2, SwerveCarLeft                ; if(!dir) { goto SwerveCarLeft; }
	nop
SwerveCarRight:
	lw t2, 0(t0)                          ; x = car_arr[0];
	subi t1, 1                            ; size--; (Delay Slot)
	addi t2, 1                            ; x++;
	li t3, 178                            ; right_edge = 178;
	blt t2, t3, ContinueSwerveRight       ; if(x > right_edge) { goto ContinueSwerveRight; }
	nop
SwitchDirToLeft:
	sw zero, 8(t0)                        ; car_arr[2] = 0;
ContinueSwerveRight:
	sw t2, 0(t0)	                      ; car_arr[0] = x;
	bnez t1, SwerveCarLoop                ; if(size != 0) { goto SwerveCarLoop; }
	addi t0, 12                           ; car_arr += 12; (Delay Slot)
	b DrawRoad
	nop
SwerveCarLeft:
	lw t2, 0(t0)                          ; x = car_arr[0];
	subi t1, 1                            ; size--; (Delay Slot)
	subi t2, 1                            ; x--;
	li t3, 40                             ; left_edge = 40;
	bgt t2, t3, ContinueSwerveLeft        ; if(x > left_edge) { goto ContinueSwerveLeft; }
	nop
SwitchDirToRight:
	li t3, 1
	sw t3, 8(t0)                          ; car_arr[2] = 1;
ContinueSwerveLeft:
	sw t2, 0(t0)	                      ; car_arr[0] = x;
	bnez t1, SwerveCarLoop                ; if(size != 0) { goto SwerveCarLoop; }
	addi t0, 12                           ; car_arr += 12; (Delay Slot)
DrawRoad:
	li a0, VS_ROAD_X                      ; rect_x = VS_ROAD_X;
	li a1, VS_ROAD_Y                      ; rect_y = VS_ROAD_Y;
	li a2, VS_ROAD_W                      ; rect_w = VS_ROAD_W;
	li a3, VS_ROAD_H                      ; rect_h = VS_ROAD_H;
	li t1, VS_ROAD_COLOR                  ; rect_color = VS_ROAD_COLOR;
	sw t1, 16(sp)
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                          ; DrawSync();
	nop
DrawShoulders:
	li a0, VS_RSHOULDER_X                 ; rect_x = VS_RSHOULDER_X;
	li a1, VS_RSHOULDER_Y                 ; rect_y = VS_RSHOULDER_Y;
	li a2, VS_SHOULDER_W                  ; rect_w = VS_SHOULDER_W;
	li a3, VS_SHOULDER_H                  ; rect_h = VS_SHOULDER_H;
	li t1, VS_GRASS_COLOR                 ; rect_color = VS_GRASS_COLOR;
	sw t1, 16(sp)
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                          ; DrawSync();
	nop 
	li a0, VS_LSHOULDER_X                 ; rect_x = VS_SHOULDER_X;
	li a1, VS_LSHOULDER_Y                 ; rect_y = VS_SHOULDER_Y;
	li a2, VS_SHOULDER_W                  ; rect_w = VS_SHOULDER_W;
	li a3, VS_SHOULDER_H                  ; rect_h = VS_SHOULDER_H;
	li t1, VS_GRASS_COLOR                 ; rect_color = VS_GRASS_COLOR;
	sw t1, 16(sp)
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                          ; DrawSync();
	nop
DrawStrips:
	la t3, StripYCoords                   ; y_coords = (unsigned long*)StripYCoords;
	li t4, VS_NUM_STRIPS                  ; size = VS_NUM_STRIPS;
DrawStripsLoop:
	li a0, VS_STRIP_X                     ; rect_x = VS_STRIP_X;
	lw a1, 0(t3)                          ; rect_y = *y_coords;
	li a2, VS_STRIP_W                     ; rect_w = VS_STRIP_W;
	li a3, VS_STRIP_H                     ; rect_h = VS_STRIP_H;
	li t1, $FFFFFF                        ; rect_color = 0xFFFFFF;
	sw t1, 16(sp)
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                          ; DrawSync();
	nop
	li a0, VS_STRIP_X + 178               ; rect_x = VS_STRIP_X + 178;
	lw a1, 0(t3)                          ; rect_y = *y_coords;
	li a2, VS_STRIP_W                     ; rect_w = VS_STRIP_W;
	li a3, VS_STRIP_H                     ; rect_h = VS_STRIP_H;
	li t1, $FFFFFF                        ; rect_color = 0xFFFFFF;
	sw t1, 16(sp)
	jal FillRect                          ; FillRect(rect_x,rect_y,rect_w,rect_h,rect_color);
	nop
	jal DrawSync                          ; DrawSync();
	addi t3, 4                            ; y_coords += 4; (Delay Slot)
	bnez t4, DrawStripsLoop               ; if(size != 0) { goto DrawStripsLoop; }
	subi t4, 1                            ; size--; (Delay Slot)
DrawCPUCars:
	la t3, CPUCarArr                      
	li t4, VS_NUM_CARS                    ; size = VS_NUM_CARS;
DrawCPUCarLoop:
	lw a0, CooldownObj                    ; cooldown = *(unsigned long*)CooldownObj;
	nop 
	bgtz a0, GetCPUTPage                  ; if(cooldown > 0) { goto GetCPUTPage; }
	move s3, t3
	move s4, t4
	lw a0, 0(t3)                          ; x1 = CPUCarArr[0];   
	lw a1, 4(t3)                          ; y1 = CPUCarArr[1];
	li t5, -3000                          ; min_y = -3000;
	ble a1, t5, ResetLevel                ; if(y1 <= miny) { goto ResetLevel; }
	li a2, VS_PCAR_W                      ; w1 = VS_PCAR_W;
	li a3, VS_PCAR_H                      ; h1 = VS_PCAR_H;
	lw t0, 16(s0)                         
	lw t1, 20(s0)
	sw t0, 16(sp)                         ; x2 = player_x;
	sw t1, 20(sp)                         ; y2 = player_y;
	addi t0, 1
	addi t1, 1
	li t0, VS_PCAR_W - 1
	sw t0, 24(sp)                         ; w2 = VS_PCAR_W;
	li t1, VS_PCAR_H - 1
	sw t0, 28(sp)                         ; h2 = VS_PCAR_H;
	jal DetectAABBCollision               ; collide = DetectAABBCollision(x1,y1,w1,h1,x2,y2,w2,h2);
	nop
	bnez v0, ResetLevel                   ; if(collide) { goto ResetLevel; }
	move t3, s3 
	move t4, s4
GetCPUTPage:
	li a0, 0x2                            ; mode = 16-bit;
	li a1, 0x1                            ; alpha = true;
	li a2, VS_CPUCAR_VRAM_X               ; vram_x = VS_CPUCAR_VRAM_X;
	li a3, VS_CPUCAR_VRAM_Y               ; vram_y = VS_CPUCAR_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	lw a1, 4(t3)                          ; y = CPUCarArr[4];
	lw a0, 0(t3)                          ; x = CPUCarArr[0];   
	bltz a1, LoopBlock                    ; if(y < 0) { goto LoopBlock; }
	move a2, v0    
TextureCPUCar:
	jal VS_TexturePlayerCar               ; VS_TexturePlayerCar(x,y,texpage);
    nop
LoopBlock:
	subi t4, 1                            ; size--; (Delay Slot)
	bnez t4, DrawCPUCarLoop               ; if(size != 0) { goto DrawCPUCarLoop; }
	addi t3, 12                           ; CPUCarArr += 12; (Delay Slot)
DrawPlayerCar:
	li a0, 0x2                            ; mode = 16-bit;
	li a1, 0x1                            ; alpha = true;
	li a2, VS_PCAR_VRAM_X                 ; vram_x = VS_PCAR_VRAM_X;
	li a3, VS_PCAR_VRAM_Y                 ; vram_y = VS_PCAR_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	lw a0, 16(s0)                         ; x = player_x;
	lw a1, 20(s0)                         ; y = player_y;
	move a2, v0                           
	jal VS_TexturePlayerCar               ; VS_TexturePlayerCar(x,y,texpage);
	nop
DrawScoreText:
	li a0, 1                              ; x = 1;
	li a1, 259                            ; y = 259;
	la a2, ScoreText                      ; string = ScoreText;
	li a3, 4                              ; len = 5;
	jal VS_DrawString                     ; VS_DrawString(x,y,string,len);
	nop
DrawLivesText:
	li a0, 1                              ; x = 1;
	li a1, 309                            ; y = 309;
	la a2, LivesText                      ; string = LivesText;
	li a3, 4                              ; len = 5;
	jal VS_DrawString                     ; VS_DrawString(x,y,string,len);
	nop
DrawHIScoreText:
	li a0, 1                              ; x = 1;
	li a1, 359                            ; y = 359;
	la a2, HighScoreText                  ; string = HighScoreText;
	li a3, 6                              ; len = 7;
	jal VS_DrawString                     ; VS_DrawString(x,y,string,len);
	nop
DrawScore:
	la a0, PlayerText                     ; string = PlayerText;
	lw a1, PlayerScore                    ; int = PlayerScore;
	nop
	jal VS_Int2String                     ; num_digits = VS_Int2String(string,int);
	nop 
	li a0, 2                              ; x = 2;
	li a1, 276                            ; y = 276;
	la a2, PlayerText                     ; string = PlayerText;
	move a3, v0                           ; strlen = num_digits - 1;
	subi a3, 1 
	jal VS_DrawString                     ; VS_DrawString(x,y,string,strlen);
	nop
	la a0, PlayerText                     ; string = PlayerText;
	lw a1, PlayerLives                    ; int = PlayerLives;
	nop
	jal VS_Int2String                     ; num_digits = VS_Int2String(string,int);
	nop 
	li a0, 2                              ; x = 2;
	li a1, 326                            ; y = 326;
	la a2, PlayerText                     ; string = PlayerText;
	move a3, v0                           ; strlen = num_digits - 1;
	subi a3, 1 
	jal VS_DrawString                     ; VS_DrawString(x,y,string,strlen);
	nop
	la a0, PlayerText                     ; string = PlayerText;
	lw a1, HighScore                      ; int = HighScore;
	nop
	jal VS_Int2String                     ; num_digits = VS_Int2String(string,int);
	nop 
	li a0, 2                              ; x = 2;
	li a1, 374                            ; y = 374;
	la a2, PlayerText                     ; string = PlayerText;
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
	li v0, $1 
	jr ra 
	nop
AABBFalse:
	li v0, $0 
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
	
# Function: VS_TexturePlayerCar
# Purpose: Textures the player's car to the (X,Y) screen coordinates with alpha transparency turned on 
# a0: x, a1: y, a2: texpage
VS_TexturePlayerCar:
	subi sp, sp, 80 
	sw ra, 4(sp)
	move t0, a2
	li a2, $0            ; palette = 0;
	li a3, $0            ; u1 = 0;
	sw zero, 16(sp)      ; v1 = 0;
	sw a0, 20(sp)        ; x2 = VS_PCAR_X;
	li t1, VS_PCAR_H
	add t1, t1, a1 
	sw t1, 24(sp)        ; y2 = VS_PCAR_Y + VS_PCAR_H;
	sw t0, 28(sp)        ; texpage = GetTexturePage(2,1,VS_PCAR_X,VS_PBIMGY); 
	sw zero, 32(sp)      ; u2 = 0;
	li t1, VS_PCAR_H 
	sw t1, 36(sp)        ; v2 = VS_PCAR_H;
	li t1, VS_PCAR_W 
	addu t1, t1, a0
	sw t1, 40(sp)        ; x3 = VS_PCAR_X + VS_PCAR_W;
	sw a1, 44(sp)        ; y3 = VS_PCAR_Y;
	li t1, VS_PCAR_W 
	sw t1, 48(sp)        ; u3 = VS_PCAR_W;
	sw zero, 52(sp)      ; v3 = 0;
	li t1, VS_PCAR_W 
	add t1, t1, a0
	sw t1, 56(sp)        ; x4 = VS_PCAR_X + VS_PCAR_W;
	li t1, VS_PCAR_H 
	add t1, t1, a1 
	sw t1, 60(sp)        ; y4 = VS_PCAR_Y + VS_PCAR_H;
	li t1, VS_PCAR_W 
	sw t1, 64(sp)        ; u4 = VS_PCAR_W;
	li t1, VS_PCAR_H 
	sw t1, 68(sp)        ; v4 = VS_PCAR_H;
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
	and a1, a2               ; gpu1 &= gpu1_cmd;
	beqz a1, DrawSyncLoop    ; if(gpu1 == 0) { goto DrawSyncLoop; }
	nop 
	jr ra
	nop
	
# Function: DMASync
# Purpose: Halts program execution until all gpu dma transfers have completed
DMASync:
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

# Function: InitGame
# Purpose: Initializes the core game variables
InitGame:
	sw zero, PlayerScore   ; *(unsigned long*)PlayerScore = 0;
	li t0, VS_NUM_LIVES    ; lives = VS_NUM_LIVES;
	sw t0, PlayerLives     ; *(unsigned long*)PlayerLives = lives;
	li t0, VS_PLAYER_X     ; player_x = VS_PLAYER_X
	sw t0, 16(s0)
	li t0, VS_PLAYER_Y     ; player_y = VS_PLAYER_Y
	sw t0, 20(s0)
	la t0, CPUCarArr
	li t1, VS_CPU_X1       ; cpu_car_x1 = VS_CPU_X1;
	sw t1, 0(t0)
	li t1, VS_CPU_Y1       ; cpu_car_y1 = VS_CPU_Y1;
	sw t1, 4(t0)
	sw zero, 8(t0)         ; cpu_car_dir1 = 0;
	li t1, VS_CPU_X2       ; cpu_car_x2 = VS_CPU_X2;
	sw t1, 12(t0)
	li t1, VS_CPU_Y2       ; cpu_car_y2 = VS_CPU_Y2;
	sw t1, 16(t0)
	li t1, 1 
	sw t1, 20(t0)          ; cpu_car_dir2 = 1;
	li t1, VS_CPU_X3       ; cpu_car_x3 = VS_CPU_X3;
	sw t1, 24(t0)
	li t1, VS_CPU_Y3       ; cpu_car_y3 = VS_CPU_Y3;
	sw t1, 28(t0)
	sw zero, 32(t0)        ; cpu_car_dir3 = 0;
	sw zero, CooldownObj   ; *(unsigned long*)CooldownObj = 0; (Delay Slot)
	b InitStrips           ; goto InitStrips;
	nop

# Function: ResetLevel
# Purpose: Decrements the number of player lives and resets all vehicles to their initial positions
ResetLevel:
	li t0, VS_RESET_COOLDOWN ; cooldown = VS_RESET_COOLDOWN;
	sw t0, CooldownObj       ; *(unsigned long*)CooldownObj = cooldown;
	lw t0, PlayerLives    ; lives = *(unsigned long*)PlayerLives;
	nop 
	subi t0, 1            ; lives--;
	sw t0, PlayerLives    ; *(unsigned long*)PlayerLives = lives;
	lw t0, PlayerScore    ; score = *(unsigned long*)PlayerScore;
	nop 
	subi t0, 150          ; score -= 150; (Delay Slot)
	bgez t0, SetScore     ; if(score >= 0) { goto SetScore; }
	nop
ClampScoreToZero:
	move t0, zero         ; score = 0;
SetScore:
	sw t0, PlayerScore    ; *(unsigned long*)PlayerScore = score;
	li t0, VS_PLAYER_X    ; player_x = VS_PLAYER_X;
	sw t0, 16(s0)      
	li t0, VS_PLAYER_Y    ; player_y = VS_PLAYER_Y;
	sw t0, 20(s0)
	la t0, CPUCarArr
	li t1, VS_CPU_X1       ; cpu_car_x1 = VS_CPU_X1;
	sw t1, 0(t0)
	li t1, VS_CPU_Y1       ; cpu_car_y1 = VS_CPU_Y1;
	sw t1, 4(t0)
	sw zero, 8(t0)         ; cpu_car_dir1 = 0;
	li t1, VS_CPU_X2       ; cpu_car_x2 = VS_CPU_X2;
	sw t1, 12(t0)
	li t1, VS_CPU_Y2       ; cpu_car_y2 = VS_CPU_Y2;
	sw t1, 16(t0)
	li t1, 1 
	sw t1, 20(t0)          ; cpu_car_dir2 = 1;
	li t1, VS_CPU_X3       ; cpu_car_x3 = VS_CPU_X3;
	sw t1, 24(t0)
	li t1, VS_CPU_Y3       ; cpu_car_y3 = VS_CPU_Y3;
	sw t1, 28(t0)
	sw zero, 32(t0)       ; cpu_car_dir3 = 0;
	b DrawRoad            ; goto DrawRoad;
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
	andi t1, t1, $FFFF  ; x &= $FFFF;
	sll t3, a1, 16  ; y <<= 16;
	addu t3, t3, t1     ; y += x;
	sw t3, VS_GP0(t0)    ; *vs_gp0 = y;
	li t3, VS_FONTW       ; w = VS_IMGW;
	li t4, VS_FONTH       ; h = VS_IMGH;
	sll t4, t4, 16     ; h <<= 16;
	addu t4, t4, t3     ; h += w;
	sw t4, VS_GP0(t0)    ; *vs_gp0 = h;
	li t3, VS_FONTW       ; w = VS_FONTW;
	li t4, VS_FONTH       ; h = VS_FONTH;
	addu t1, t1, t3     ; x += w;
	mult t3, t4          ; size = w * h;
	mflo t3 
	sll t3, t3, 1      ; size <<= 1;
	sra t3, t3, 2      ; size /= 4;
TransferLoop:
	lw t4,0(v0)
	addiu v0, v0, 4
	sw t4, VS_GP0(t0)
	bnez t3, TransferLoop
	subi t3, t3, 1
	blez a3, end
	subi a3, 1     ; strlen--; (delay slot)
	b DrawChar
	nop
	
vs_draw_space:
	addi t1, 8     ; x += 8;
	b   DrawChar
	subi a3, 1     ; strlen--;
	
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
	
.include "../lib/audio.asm"

.data
PlayerCarImage:
	.incbin "player_car.bin"
	
CPUCarImage:
	.incbin "cpu_car.bin"
	
.align, 4
StripYCoords:
	.empty, 32
	
CPUCarArr:
	.empty, VS_NUM_CARS * 12
	
vs_rand_index:
	.dw 0
	
PlayerScore:
	.dw 0
	
HighScore:
	.dw 0
	
PlayerLives:
	.dw 0
	
CooldownObj:
	.dw 0
	
PlayerText:
.empty, 16
	
rndtable: 
	.db $2d,$ae,$2d,$82,$36,$5b,$35,$76,$62,$90,$50,$54,$95,$52,$8d,$76,$51,$66,$8c,$89,$48,$51,$54,$5b,$8a,$4b,$aa,$a1,$81
	.db $29,$74,$6e,$9e,$70,$3b,$6a,$8e,$a5,$7d,$5f,$2b,$40,$42,$4a,$af,$8e,$38,$79,$7f,$96,$3d,$84,$4e,$59,$af,$94,$97,$99
	.db $50,$b2,$a8,$43,$9d,$7c,$81,$8f,$a3,$5d,$47,$4b,$29,$4b,$a4,$29,$69,$7e,$98,$a7,$3e,$52,$4e,$90,$4e,$a3,$3a,$8f,$6e
	.db $70,$83,$93,$2d,$9e,$28,$3a,$a2,$65,$a7,$36,$31,$80,$5d,$2e,$4a,$a9,$61,$5f,$55,$2a,$a2,$ae,$6c,$7f,$83,$9d,$aa,$83
	.db $80,$2e,$43,$29,$3a,$9d,$5b,$a2,$a8,$43,$b0,$3f,$85,$94,$8d,$6d,$4c,$45,$53,$8e,$48,$31,$83,$47,$83,$65,$47,$86,$71
	.db $a8,$7e,$94,$b2,$5f,$8d,$83,$55,$9f,$a2,$62,$ae,$9c,$b1,$6a,$64,$89,$73,$33,$36,$a6,$9f,$2e,$72,$9d,$73,$94,$40,$6d
	.db $5b,$3f,$47,$a3,$2a,$74,$73,$3f,$49,$31,$38,$9e,$2d,$6a,$66,$96,$83,$4e,$54,$9c,$7e,$6f,$a5,$55,$57,$7c,$2d,$2c,$88
	.db $72,$33,$ab,$40,$94,$3c,$90,$87,$51,$35,$93,$28,$63,$a8,$35,$63,$9e,$58,$4c,$61,$9e,$a8,$58,$85,$9c,$6c,$91,$7c,$9f
	.db $91,$75,$38,$2d,$aa,$94,$a1,$b1,$89,$a9,$43,$63,$54,$93,$59,$84,$3a,$87,$66,$97,$2b,$36,$6d,$43

.align, 4
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

.align, 16	
DrivingAudio:
	.incbin "driving.adpcm"
	
.align, 16
IntroAudio:
	.incbin "intro.adpcm"
	
.align, 16
Song:
	.incbin "song.adpcm"
	
ScoreText:	
	.ascii "SCORE"

LivesText:
	.ascii "LIVES"
	
HighScoreText:
	.ascii "HISCORE"
