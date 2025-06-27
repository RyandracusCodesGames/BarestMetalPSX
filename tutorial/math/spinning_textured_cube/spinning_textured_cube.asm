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
VS_BPP_15 equ 0
VS_BPP24 equ 16
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
VS_JOY_CIRCLE equ $0020
VS_JOY_TRIANGLE equ $0010

VS_RED equ 75 
VS_GREEN equ 0 
VS_BLUE equ 130

VS_FONTW equ 8 
VS_FONTH equ 11

VS_CUBE_FACES equ 6

VS_DMA_VRAM_X equ 256 
VS_DMA_VRAM_Y equ 0
VS_TEXTURE_W equ 64 
VS_TEXTURE_H equ 64

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
UploadTextureToVram:
	li a0, VS_DMA_VRAM_X                  ; vram_x = VS_DMA_VRAM_X;
	li a1, VS_DMA_VRAM_Y                  ; vram_y = VS_DMA_VRAM_Y;
	li a2, VS_TEXTURE_W                   ; image_w = VS_TEXTURE_W;
	li a3, VS_TEXTURE_H                   ; image_h = VS_TEXTURE_H;
	la t0, Texture                        ; data = Texture;
	sw t0, 16(sp)
	jal VS_DMAImageDataToVram             ; VS_DMAImageDataToVram(vram_x,vram_y,image_w,image_h,data);
	nop
InitGTE:
	jal VS_InitGTE                        ; VS_InitGTE();
	nop
	li a0, VS_WIDTH / 2                   ; center_x = VS_WIDTH / 2;
	jal VS_SetScreenOffsetX               ; VS_SetScreenOffsetX(center_x);
	nop 
	li a0, VS_HEIGHT / 2                  ; center_y = VS_HEIGHT / 2; 
	jal VS_SetScreenOffsetY               ; VS_SetScreenOffsetY(center_y);
	nop
	li a0, VS_WIDTH / 2                   ; center_x = VS_WIDTH / 2;
	jal VS_SetPlaneProjectionDistance     ; VS_SetPlaneProjectionDistance(center_x);
	nop
	jal VS_ClearTranslationVectorGTE      ; VS_ClearTranslationVectorGTE();
	nop
	jal VS_ClearMatrixGTE                 ; VS_ClearMatrixGTE();
	nop
	la t0, Vec3 
	li t1, 400                            ; z = 400;
	sw t1, 8(t0)                          ; Vec3->z = z;
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
	la t0, Vec3 
	lw t1, 0(t0)                          ; translation_x = Vec3->x;
	nop 
	addi t1, 5                            ; translation_x += 5;
	sw t1, 0(t0)                          ; Vec3->x = translation_x;
PRESSRIGHT:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_RIGHT                 ; pad_data &= VS_JOY_RIGHT;
    beqz t0, PRESSUP    		          ; if(!pad_data){ goto PRESSUP; }
    nop  
	la t0, Vec3 
	lw t1, 0(t0)                          ; translation_x = Vec3->x;
	nop 
	subi t1, 5                            ; translation_x -= 5;
	sw t1, 0(t0)                          ; Vec3->x = translation_x;
PRESSUP:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_UP                    ; pad_data &= VS_JOY_UP;
    beqz t0, PRESSDOWN    		          ; if(!pad_data){ goto PRESSDOWN; }
    nop  
	la t0, Vec3 
	lw t1, 4(t0)                          ; translation_y = Vec3->y;
	nop 
	addi t1, 5                            ; translation_y += 5;
	sw t1, 4(t0)                          ; Vec3->y = translation_y;
PRESSDOWN:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_DOWN                  ; pad_data &= VS_JOY_DOWN;
    beqz t0, PRESSX    		              ; if(!pad_data){ goto PRESSX; }
    nop  
	la t0, Vec3 
	lw t1, 4(t0)                          ; translation_y = Vec3->y;
	nop 
	subi t1, 5                            ; translation_y -= 5;
	sw t1, 4(t0)                          ; Vec3->y = translation_y;
PRESSX:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_X                     ; pad_data &= VS_JOY_X;
    beqz t0, PRESSCIRCLE    		      ; if(!pad_data){ goto PRESSCIRCLE; }
    nop  
	la t0, RotateXYZ
	lh t1, 0(t0)                          ; rot_x = RotateXYZ->x;
	nop
	addi t1, 16                           ; rot_x -= 16;
	sh t1, 0(t0)                          ; rot->x = rot-x;
PRESSCIRCLE:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_CIRCLE                ; pad_data &= VS_JOY_CIRCLE;
    beqz t0, PRESSTRIANGLE    		      ; if(!pad_data){ goto PRESSTRIANGLE; }
    nop  
	la t0, RotateXYZ
	lh t1, 4(t0)                          ; rot_z = RotateXYZ->z;
	nop
	addi t1, 16                           ; rot_z -= 16;
	sh t1, 4(t0)                          ; rot->z = rot_z;
PRESSTRIANGLE:
    lw t0, PadData                        ; pad_data = GetPadData();
    nop  
    andi t0, VS_JOY_TRIANGLE              ; pad_data &= VS_JOY_TRIANGLE;
    beqz t0, TransformMatrix    		  ; if(!pad_data){ goto TransformMatrix; }
    nop  
	la t0, RotateXYZ
	lh t1, 2(t0)                          ; rot_y = RotateXYZ->y;
	nop
	addi t1, 16                           ; rot_y -= 16;
	sh t1, 2(t0)                          ; rot->y = rot_y;
TransformMatrix:
	la s0, RotateXYZ                      
	la a0, RotMatX                        ; mat = RotMatX;
	lh a1, 0(s0)                          ; angle = RotateXYZ->x;
	jal VS_MakeMatrixRotationX            ; VS_MakeMatrixRotationX(&mat,angle);
	nop 
	la a0, RotMatY                        ; mat = RotMatY;
	lh a1, 2(s0)                          ; angle = RotateXYZ->y;
	jal VS_MakeMatrixRotationY            ; VS_MakeMatrixRotationY(&mat,angle);
	nop 
	la a0, RotMatZ                        ; mat = RotMatZ;
	lh a1, 4(s0)                          ; angle = RotateXYZ->z;
	jal VS_MakeMatrixRotationZ            ; VS_MakeMatrixRotationZ(&mat,angle);
	nop 
	la a0, OutputMatrix1                  ; mat = OutputMatrix1;
	jal VS_MakeMatrixIdentity             ; VS_MakeMatrixIdentity(&mat);
	nop
	la a0, OutputMatrix2                  ; mat = OutputMatrix2;
	jal VS_MakeMatrixIdentity             ; VS_MakeMatrixIdentity(&mat);
	nop 
	la a0, OutputMatrix1                  ; mat1 = OutputMatrix1;
	la a1, RotMatX                        ; mat2 = RotMatX;
	la a2, OutputMatrix2                  ; out = OutputMatrix2;
	jal VS_MultiplyMatrixByMatrix         ; VS_MultiplyMatrixByMatrix(mat1,mat2,&out);
	nop
	la a0, OutputMatrix1                  ; dest = OutputMatrix1;
	la a1, OutputMatrix2                  ; src = OutputMatrix2;
	jal VS_CopyMatrix                     ; VS_CopyMatrix(&dest,src);
	nop
	la a0, OutputMatrix1                  ; mat1 = OutputMatrix1;
	la a1, RotMatY                        ; mat2 = RotMatY;
	la a2, OutputMatrix2                  ; out = OutputMatrix2;
	jal VS_MultiplyMatrixByMatrix         ; VS_MultiplyMatrixByMatrix(mat1,mat2,&out);
	nop
	la a0, OutputMatrix1                  ; dest = OutputMatrix1;
	la a1, OutputMatrix2                  ; src = OutputMatrix2;
	jal VS_CopyMatrix                     ; VS_CopyMatrix(&dest,src);
	nop
	la a0, OutputMatrix1                  ; mat1 = OutputMatrix1;
	la a1, RotMatZ                        ; mat2 = RotMatZ;
	la a2, OutputMatrix2                  ; out = OutputMatrix2;
	jal VS_MultiplyMatrixByMatrix         ; VS_MultiplyMatrixByMatrix(mat1,mat2,&out);
	nop
	la a0, OutputMatrix1                  ; dest = OutputMatrix1;
	la a1, OutputMatrix2                  ; src = OutputMatrix2;
	jal VS_CopyMatrix                     ; VS_CopyMatrix(&dest,src);
	nop
	la t0, Vec3                           
	la a0, OutputMatrix1                  ; mat = OutputMatrix1;
	lw a1, 0(t0)                          ; x = Vec3->x;
	lw a2, 4(t0)                          ; y = Vec3->y;
	lw a3, 8(t0)                          ; z = Vec3->z;
	jal VS_MakeMatrixTranslation          ; VS_MakeMatrixTranslation(&mat,x,y,z);
	nop
	la a0, OutputMatrix1                  ; mat = OutputMatrix1;
	jal VS_PushMatrixToGTE                ; VS_PushMatrixToGTE(&mat);
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
	li s0, 0                              ; i = 0;
	li s1, VS_CUBE_FACES                  ; size = VS_CUBE_FACES;
	la s2, CubeVerts
	la s3, CubeIndices
DrawCube:
	sll t4, s0, 3                         ; index = i << 3;
	addu t4, s3, t4                       ; index = CubeIndices + index;
	lh t5, 0(t4)                          ; index1 = *index;
	lh t6, 2(t4)                          ; index2 = *(index + 1);
	lh t7, 4(t4)                          ; index3 = *(index + 2);
	sll t5, 3                             ; index1 <<= 3;
	sll t6, 3                             ; index2 <<= 3;
	sll t7, 3                             ; index3 <<= 3;
	addu a0, s2, t5                       ; vec1 = CubeVerts + index1;
	addu a1, s2, t6                       ; vec2 = CubeVerts + index2;
	addu a2, s2, t7                       ; vec3 = CubeVerts + index3;
	jal VS_LoadThreeVectorsToGTE          ; VS_LoadThreeVectorsToGTE(vec1,vec2,vec3);
	nop
	jal VS_RotTransPer3                   ; VS_RotTransPer3();
	nop
	jal VS_NClip                          ; VS_NClip();
	nop
	la a0, Depth
	jal VS_StoreDepth                     ; VS_StoreDepth(&depth);
	nop
	lw a0, Depth
	nop
	blez a0, IncrementLoop                ; if(depth < 0) { goto IncrementLoop; }
	nop
	la a0, Quad                           ; vec4 = Quad;
	jal VS_StoreThreeVectorsFromGTE       ; VS_StoreThreeVectorsFromGTE(&quad);
	nop
	lh t5, 6(t4)                          ; index4 = *(index + 3);
	nop
	sll t5, 3                             ; index4 <<= 3;
	addu a0, s2, t5                       ; vec4 = CubeVerts + index4;
	jal VS_LoadOneVectorToGTE             ; VS_LoadOneVectorToGTE(vec4);
	nop
	jal VS_RotTransPer                    ; VS_RotTransPer();
	nop
	la a0, Quad         
	addiu a0, 12 
	jal VS_StoreOneVectorFromGTE          ; VS_StoreOneVectorFromGTE(quad+12);
	nop
	li a0, 2                              ; mode = 2;
	li a1, 0                              ; alpha = 1;
	li a2, VS_DMA_VRAM_X                  ; vram_x = VS_DMA_VRAM_X;
	li a3, VS_DMA_VRAM_Y                  ; vram_y = VS_DMA_VRAM_Y;
	jal VS_GetTexturePage                 ; texpage = VS_GetTexturePage(mode,alpha,vram_x,vram_y);
	nop
	la t5, Quad 
VS_TextureImage:
	lh a0, 0(t5) ; x1 
	lh a1, 2(t5) ; y1 
	li a2, $0            ; palette = 0;
	li a3, $0            ; u1 = 0;
	sw zero, 16(sp)      ; v1 = 0;
	lh t0, 4(t5) ; x2 
	lh t1, 6(t5) ; y2 
	sh t0, 20(sp)
	sh t1, 24(sp) 
	li t1, VS_TEXTURE_H
	sw v0, 28(sp)        ; texpage = GetTexturePage(2,1,VS_PCAR_X,VS_PBIMGY); 
	sw zero, 32(sp)      ; u2 = 0;
	li t1, VS_TEXTURE_H 
	sw t1, 36(sp)        ; v2 = VS_TEXTURE_H;
	lh t6, 8(t5) ; x3 
	nop
	sh t6, 40(sp)
	lh t6, 10(t5) ; y3 
	nop
	sh t6, 44(sp)
	li t1, VS_TEXTURE_W 
	sw t1, 48(sp)        ; u3 = VS_TEXTURE_W;
	sw zero, 52(sp)      ; v3 = 0;
	lh t6, 12(t5) ; x4 
	nop
	sh t6, 56(sp)
	lh t6, 14(t5) ; y4 
	nop
	sh t6, 60(sp)
	li t1, VS_TEXTURE_W 
	sw t1, 64(sp)        ; u4 = VS_TEXTURE_W;
	li t1, VS_TEXTURE_H 
	sw t1, 68(sp)        ; v4 = VS_TEXTURE_H;
	jal VS_TextureFourPointPoly
	nop
	jal VS_DrawSync
	nop 
IncrementLoop:
	addi s0, 1                            ; i++;
	bne s0, s1, DrawCube                  ; if(i != size) { goto DrawCube; }
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
	
.include "../../../lib/graphics.asm"
.include "../../../lib/math.asm"
.include "../../../lib/string.asm"
	
# Function: VS_DrawString
# Purpose: Draws a string to the display area 
# a0: x, a1: y, a2: string
VS_DrawString:
	addiu sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
	sw a0, 8(sp)
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
TransferCharLoop:
	lw t4,0(v0)
	addiu v0, v0, 0x4
	sw t4, VS_GP0(t0)
	bnez t3, TransferCharLoop
	subi t3, t3, 0x1
	b DrawChar
	nop
vs_draw_space:
	b   DrawChar
	addi t1, t1, VS_FONTW ; x += VS_FONTW;
vs_draw_new_line:
	lw t1, 8(sp)
	b   DrawChar
	addi a1, a1, VS_FONTH ; y += VS_FONTH;
end:
	lw ra, 0(sp)
    lw s0, 4(sp)
    addiu sp, sp, 12
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

.data
PadBuffer:
	.dw 0 

PadData:
	.dw 0	
; Rotation Vector
RotateXYZ:
	.dh 16 
	.dh 0  
	.dh 0
.align, 4
; Translation Vector 
Vec3:
	.dw 0 
	.dw 0 
	.dw 0
; X Rotation Matrix
RotMatX:
	.dh 0, 0, 0 
	.dh 0, 0, 0 
	.dh 0, 0, 0, 0 
	.dw 0, 0, 0
; Y Rotation Matrix 
RotMatY:
	.dh 0, 0, 0 
	.dh 0, 0, 0 
	.dh 0, 0, 0, 0 
	.dw 0, 0, 0
; Z Rotation Matrix 
RotMatZ:
	.dh 0, 0, 0 
	.dh 0, 0, 0 
	.dh 0, 0, 0, 0 
	.dw 0, 0, 0	
; Output Matrices
OutputMatrix1:
	.dh 0, 0, 0 
	.dh 0, 0, 0 
	.dh 0, 0, 0, 0 
	.dw 0, 0, 0
OutputMatrix2:
	.dh 0, 0, 0 
	.dh 0, 0, 0 
	.dh 0, 0, 0, 0 
	.dw 0, 0, 0
; Vertices of the Cube
CubeVerts:
	.dh -100, -100, -100, 0 
	.dh  100, -100, -100, 0 
	.dh -100,  100, -100, 0 
	.dh  100,  100, -100, 0 
	.dh  100, -100,  100, 0 
	.dh -100, -100,  100, 0 
	.dh  100,  100,  100, 0 
	.dh -100,  100,  100, 0
; Indices of the Cube 
CubeIndices:
	.dh 0, 1, 2, 3 
	.dh 4, 5, 6, 7 
	.dh 5, 4, 0, 1 
	.dh 6, 7, 3, 2 
	.dh 0, 2, 5, 7 
	.dh 3, 1, 6, 4
; 24-Bit RGB Colors of Each Face of the Cube 
CubeColors:
	.dw $0000FF
	.dw $00FF00
	.dw $FF0000
	.dw $15FF4B
	.dw $00FFFF
	.dw $FFFF00
Quad:
	.dw 0 
	.dw 0 
	.dw 0 
	.dw 0
Depth:
	.dw 0
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
	
VS_minus: 
	.dh 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
	.dh 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $7fff, $7fff, $7fff, $7fff, $7fff, $7fff, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.dh 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.align, 4
Font:
	.incbin "font.bin"
	
Texture:
	.incbin "texture.bin"