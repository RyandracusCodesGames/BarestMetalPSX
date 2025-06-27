#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# audio.asm - An audio library for the PlayStation's Sound 
# Processing Unit(SPU)
#-----------------------------------------------------------
	.syntax asmpsx
	.arch ps1
	
VS_IO equ $1F800000
VS_SPU_CTRL_ADDR equ $1DAA
VS_SPU_STATUS_ADDR equ $1DAE
VS_SPU_ENABLE equ $8000
VS_SPU_STATUS_TIMEOUT equ $100000
VS_SPU_BUS_CONFIG_ADDR equ $1014
VS_SPU_MASTER_VOLUME_LEFT_ADDR	equ $1D80
VS_SPU_MASTER_VOLUME_RIGHT_ADDR	equ $1D82
VS_SPU_REVERB_VOLUME_LEFT_ADDR	equ $1D84
VS_SPU_REVERB_VOLUME_RIGHT_ADDR	equ $1D86
VS_SPU_NOISE_MODE1 equ $1D94
VS_SPU_NOISE_MODE2 equ $1D96
VS_SPU_REVERB_MODE1 equ $1D98
VS_SPU_REVERB_MODE2 equ $1D9A
VS_SPU_CD_VOLUME_LEFT_ADDR equ $1DB0
VS_SPU_CD_VOLUME_RIGHT_ADDR equ $1DB2
VS_SPU_EXT_VOLUME_LEFT_ADDR equ $1DB4
VS_SPU_EXT_VOLUME_RIGHT_ADDR equ $1DB6
VS_SPU_KEY_ON1_ADDR	equ $1D88
VS_SPU_KEY_ON2_ADDR	equ $1D8A
VS_SPU_KEY_OFF1_ADDR equ $1D8C
VS_SPU_KEY_OFF2_ADDR equ $1D8E
VS_SPU_FM_MODE1_ADDR equ $1D90
VS_SPU_FM_MODE2_ADDR equ $1D92
VS_DPCR_ADDR equ $10F0
VS_SPU_DMA_M_ADDR equ $10C0
VS_SPU_DMA_BCR_ADDR equ $10C4
VS_SPU_DMA_CHCR_ADDR equ $10C8
VS_SPU_CHANNEL_VOLUME_LEFT_ADDR equ $1F801C00
VS_SPU_CHANNEL_VOLUME_RIGHT_ADDR equ $1F801C02
VS_SPU_CHANNEL_SAMPLE_RATE_ADDR equ $1F801C04
VS_SPU_CHANNEL_ADPCM_ADDR equ $1F801C06
VS_SPU_CHANNEL_ADPCM_REPEAT_ADDR equ $1F801C0E
VS_SPU_DATA_TRANSFER_ADDR equ $1DA6

.text
InitAudio:
	li t0, VS_IO                           ; vs_io_addr = (unsigned long*)$1F800000;
	li t1, $200931e1                      
	sw t1, VS_SPU_BUS_CONFIG_ADDR(t0)      ; *(unsigned long*)VS_SPU_BUS_CONFIG_ADDR = $200931e1;
	sh zero, VS_SPU_CTRL_ADDR(t0)          ; *(unsigned short*)VS_SPU_CTRL_ADDR = 0;
	li t1, VS_SPU_STATUS_TIMEOUT           ; spu_status_timeout = VS_SPU_STATUS_TIMEOUT;
	li t2, $001f                           ; mask = $001f;
WaitInitAudio:
	beqz t1, ContinueInitAudio             ; if(spu_status_timeout == 0) { goto ContinueInitAudio; }
	lhu t3, VS_SPU_STATUS_ADDR(t0)         ; vs_spu_stat = *(unsigned short*)VS_SPU_STATUS_ADDR;
	subi t1, t1, $1                        ; spu_status_timeout--;
	and t3, t3, t2                         ; vs_spu_stat &= mask;
	beqz t3, WaitInitAudio
	nop
ContinueInitAudio:
	sh  zero, VS_SPU_MASTER_VOLUME_LEFT_ADDR(t0)      ; *(unsigned short*)VS_SPU_MASTER_VOLUME_LEFT_ADDR = 0;
	sh  zero, VS_SPU_MASTER_VOLUME_RIGHT_ADDR(t0)     ; *(unsigned short*)VS_SPU_MASTER_VOLUME_RIGHT_ADDR = 0;
	sh  zero, VS_SPU_REVERB_VOLUME_LEFT_ADDR(t0)      ; *(unsigned short*)VS_SPU_REVERB_VOLUME_LEFT_ADDR = 0;
	sh  zero, VS_SPU_REVERB_VOLUME_RIGHT_ADDR(t0)     ; *(unsigned short*)VS_SPU_REVERB_VOLUME_RIGHT_ADDR = 0;
	sw  zero, VS_SPU_NOISE_MODE1(t0)                  ; *(unsigned long*)VS_SPU_NOISE_MODE1 = 0;
	sw  zero, VS_SPU_REVERB_MODE1(t0)                 ; *(unsigned long*)VS_SPU_REVERB_MODE1 = 0;
	sh  zero, VS_SPU_CD_VOLUME_LEFT_ADDR(t0)          ; *(unsigned short*)VS_SPU_CD_VOLUME_LEFT_ADDR  = 0;
	sh  zero, VS_SPU_CD_VOLUME_RIGHT_ADDR(t0)         ; *(unsigned short*)VS_SPU_CD_VOLUME_RIGHT_ADDR  = 0;
	sh  zero, VS_SPU_EXT_VOLUME_LEFT_ADDR(t0)         ; *(unsigned short*)VS_SPU_EXT_VOLUME_LEFT_ADDR  = 0;
	sh  zero, VS_SPU_EXT_VOLUME_RIGHT_ADDR(t0)        ; *(unsigned short*)VS_SPU_EXT_VOLUME_RIGHT_ADDR  = 0;
	li  t1, $FFFF
	sh  t1, VS_SPU_KEY_OFF1_ADDR(t0)                  ; *(unsigned short*)VS_SPU_KEY_OFF1_ADDR  = $FFFF;
	li  t1, $00FF
	sh  t1, VS_SPU_KEY_OFF2_ADDR(t0)                  ; *(unsigned short*)VS_SPU_KEY_OFF2_ADDR  = $00FF;
	sh  zero, VS_SPU_FM_MODE1_ADDR(t0)                ; *(unsigned short*)VS_SPU_FM_MODE1_ADDR  = 0;
	sh  zero, VS_SPU_FM_MODE2_ADDR(t0)                ; *(unsigned short*)VS_SPU_FM_MODE2_ADDR  = 0;
	lw  t1,   VS_DPCR_ADDR(t0)                        ; dpcr = *(unsigned long*)VS_DPCR_ADDR;
	nop 
	sra t2, t1, $10                                   ; channel = dpcr >> 16;
	li t2, $fff0ffff
	and t1, t1, t2                                    ; dpcr &= $fff0ffff;
	li t2, $b0000
	or  t1, t1, t2
	sw t1, VS_DPCR_ADDR(t0)
	li t1, $00000201
	sw t1, VS_SPU_DMA_CHCR_ADDR(t0)                   ; *(unsigned long*)VS_SPU_DMA_CHCR_ADDR = $00000201;
	li t1, $0004                                         
	sh t1, $1DAC(t0)                                  ; dma_ctrl_addr = $0004;
	li t1, $0707
	sh t1, $1DA8(t0)
	li t1, $C000
	sh t1, VS_SPU_CTRL_ADDR(t0)                       ; *(unsigned short*)VS_SPU_CTRL_ADDR = $C000;
	li t1, VS_SPU_STATUS_TIMEOUT     		          ; spu_status_timeout = VS_SPU_STATUS_TIMEOUT;
	li t3, $1
FinishWait:
	beqz t1, InitVoiceChannels                   ; if(spu_status_timeout == 0) { goto InitVoiceChannels; }
	lhu  t2, VS_SPU_STATUS_ADDR(t0) 		     ; spu_stat = *VS_SPU_STATUS_ADDR;
	subi t1, t1, $1                              ; spu_status_timeout--; (delay slot)
	andi t2, t2, $003f                           ; spu_stat &= $001f;
	bne  t3, t3, FinishWait                      ; if(spu_stat != 1) { goto finish_wait; }
	nop
	li t1, $0                                    ; i = 0;
InitVoiceChannels:
	li    t2, VS_SPU_CHANNEL_VOLUME_LEFT_ADDR   ; VS_SPU_CHANNEL_VOLUME_LEFT_ADDR = (unsigned short*)$1F801C00;
	sll   t3, t1, $4                            ; channel = i * 16;
	addu  t2, t2, t3                            ; VS_SPU_CHANNEL_VOLUME_LEFT_ADDR += channel;
	sh    zero, 0(t2)                           ; *(unsigned short*)VS_SPU_CHANNEL_VOLUME_LEFT_ADDR = 0;
	addiu t2, t2, $2                            ; VS_SPU_CHANNEL_VOLUME_LEFT_ADDR += 2;
	sh    zero, 0(t2)                           ; *(unsigned short*)VS_SPU_CHANNEL_VOLUME_LEFT_ADDR = 0;
	li    t2, VS_SPU_CHANNEL_SAMPLE_RATE_ADDR   ; *(unsigned short*)VS_SPU_CHANNEL_SAMPLE_RATE_ADDR = (u16*)$1F801C04;
	addu  t2, t2, t3                            ; VS_SPU_CHANNEL_SAMPLE_RATE_ADDR += channel;
	li    t4, $1000
	sh    t4, 0(t2)                             ; *(unsigned short*)VS_SPU_CHANNEL_SAMPLE_RATE_ADDR = $1000;
	li    t2, VS_SPU_CHANNEL_ADPCM_ADDR         ; VS_SPU_CHANNEL_ADPCM_ADDR = (u16*)$1F801C06;
	addu  t2, t2, t3                            ; VS_SPU_CHANNEL_ADPCM_ADDR += channel;
	li    t4, $200
	sh    t4, 0(t2)                             ; *(unsigned short*)VS_SPU_CHANNEL_ADPCM_ADDR = $200;
	li    t2, VS_SPU_CHANNEL_ADPCM_REPEAT_ADDR  ; VS_SPU_CHANNEL_ADPCM_REPEAT_ADDR = (u16*)$1F801C0E;
	addu  t2, t2, t3                            ; VS_SPU_CHANNEL_ADPCM_REPEAT_ADDR += channel;
	sh    t4, 0(t2)                             ; *(unsigned short*)VS_SPU_CHANNEL_ADPCM_REPEAT_ADDR = $200;
	addiu t1, t1, $1                            ; i++;
	li t2, 24
	bne   t1, t2, InitVoiceChannels             ; if(i != 24) { goto InitVoiceChannels; }
	nop 
	jr ra
	nop
	
# Function: VS_ShutdownAudio
# Purpose:
VS_ShutdownAudio:
	li t0, VS_IO                  ; vs_io_addr = (unsigned long*)VS_IO;
	sw zero, VS_SPU_CTRL_ADDR(t0) ; *VS_SPU_CTRL_ADDR = 0;
	jr ra 
	nop
	
# Function: VS_SetLeftMasterVolume
# Purpose: Sets the volume of the left master channel
# a0: volume 
VS_SetLeftMasterVolume:
	li t0, VS_IO                               ; vs_io_addr = (unsigned long*)VS_IO;
	sh a0, VS_SPU_MASTER_VOLUME_LEFT_ADDR(t0)  ; *(unsigned short*)VS_SPU_MASTER_VOLUME_LEFT_ADDR = volume;
	jr ra 
	nop
	
# Function: VS_SetRightMasterVolume
# Purpose: Sets the volume of the right master channel
# a0: volume 
VS_SetRightMasterVolume:
	li t0, VS_IO                               ; vs_io_addr = (unsigned long*)VS_IO;
	sh a0, VS_SPU_MASTER_VOLUME_LEFT_ADDR(t0)  ; *(unsigned short*)VS_SPU_MASTER_VOLUME_LEFT_ADDR = volume;
	jr ra 
	nop
	
# Function: VS_SetMasterVolume
# Purpose: Sets the volume of both the left and right master channels
# a0: volume 
VS_SetMasterVolume:
	li t0, VS_IO                                ; vs_io_addr = (unsigned long*)VS_IO;
	sh a0, VS_SPU_MASTER_VOLUME_LEFT_ADDR(t0)   ; *(unsigned short*)VS_SPU_MASTER_VOLUME_LEFT_ADDR = volume;
	sh a0, VS_SPU_MASTER_VOLUME_RIGHT_ADDR(t0)  ; *(unsigned short*)VS_SPU_MASTER_VOLUME_RIGHT_ADDR = volume;
	jr ra 
	nop
	
# Function: VS_SetReverbVolume
# Purpose: Sets the volume of both the left and right reverb channels
# a0: volume 
VS_SetReverbVolume:
	li t0, VS_IO                                ; vs_io_addr = (unsigned long*)VS_IO;
	sh a0, VS_SPU_REVERB_VOLUME_LEFT_ADDR(t0)   ; *(unsigned short*)VS_SPU_REVERB_VOLUME_LEFT_ADDR = volume;
	sh a0, VS_SPU_REVERB_VOLUME_RIGHT_ADDR(t0)  ; *(unsigned short*)VS_SPU_REVERB_VOLUME_RIGHT_ADDR = volume;
	jr ra 
	nop
	
# Function: VS_SetLeftCDVolume
# Purpose: Sets the volume of the left CD channel
# a0: volume 
VS_SetLeftCDVolume:
	li t0, VS_IO                           ; vs_io_addr = (unsigned long*)VS_IO;
	sh a0, VS_SPU_CD_VOLUME_LEFT_ADDR(t0)  ; *(unsigned short*)VS_SPU_CD_VOLUME_LEFT_ADDR = volume;
	jr ra 
	nop
	
# Function: VS_SetRightCDVolume
# Purpose: Sets the volume of the right CD channel
# a0: volume 
VS_SetRightCDVolume:
	li t0, VS_IO                           ; vs_io_addr = (unsigned long*)VS_IO;
	sh a0, VS_SPU_CD_VOLUME_LEFT_ADDR(t0)  ; *(unsigned short*)VS_SPU_CD_VOLUME_LEFT_ADDR = volume;
	jr ra 
	nop
	
# Function: VS_SetCDVolume
# Purpose: Sets the volume of both the left and right CD channels
# a0: volume 
VS_SetCDrVolume:
	li t0, VS_IO                            ; vs_io_addr = (unsigned long*)VS_IO;
	sh a0, VS_SPU_CD_VOLUME_LEFT_ADDR(t0)   ; *(unsigned short*)VS_SPU_CD_VOLUME_LEFT_ADDR = volume;
	sh a0, VS_SPU_CD_VOLUME_RIGHT_ADDR(t0)  ; *(unsigned short*)VS_SPU_CD_VOLUME_RIGHT_ADDR = volume;
	jr ra 
	nop

# Function: VS_SetChannelSampleRate
# Purpose: Sets the audio sample rate of an SPU voice channel
# a0: channel, a1: sample_rate
VS_SetChannelSampleRate:
	sll  a1, a1, $0C                          ; sample_rate <<= 12;
	li t1, 44100
	divu a1, t1                               ; sample_rate /= 44100;
	mflo a1  
	la   t1, VS_SPU_CHANNEL_SAMPLE_RATE_ADDR  ; channel_sample_rate = $1F801C04;
	sll a0, 4                                 ; channel *= 16;
	addu t1, t1, a0                           ; channel_sample_rate += channel;
	sh   a1, 0(t1)                            ; *(unsigned short*)channel_sample_rate = sample_rate;
	jr   ra 
	nop
	
# Function: VS_GetSPUSampleRate
# Purpose: Converts a given 16-bit integer audio sample rate into an equivalent value for an SPU voice channel 
# a0: sample_rate
VS_GetSPUSampleRate:
	sll  a0, a0, $0C      ; sample_rate <<= 12;
	li t1, 44100
	divu a0, t1           ; sample_rate /= 44100;
	mflo v0 
	jr   ra               ; return sample_rate;
	nop
	
# Function: VS_SetChannelVolume
# Purpose: Sets the volume of an SPU voice channel 
# a0: channel, a1: volume
VS_SetChannelVolume:
	la   t1, $1F801C00   ; VS_SPU_CHANNEL_VOLUME_LEFT_ADDR = (u16*)$1F801C00;
	sll a0, 4            ; channel *= 16;
	addu t1, t1, a0      ; VS_SPU_CHANNEL_VOLUME_LEFT_ADDR += channel;
	sh   a1, 0(t1)       ; *VS_SPU_CHANNEL_VOLUME_LEFT_ADDR = volume;
	addi t1, t1, $2
	sh   a1, 0(t1)       ; *VS_SPU_CHANNEL_VOLUME_RIGHT_ADDR = volume;
	jr   ra 
	nop 
	
# Function: VS_SetChannelSustainLevel
# Purpose: Sets the sustain level of an SPU voice channel 
# a0: channel, a1: sustain 
VS_SetChannelSustainLevel:
	li   t1, $1F801C08  ; adsr_channel_addr = (u32*)$1F801C08;
	sll a0, 4           ; channel *= 16;
	addu t1, t1, a0     ; adsr_channel_addr += channel;
	lhu  t2, 0(t1)      ; adsr = *adsr_channel_addr;
	andi a1, a1, $f     ; sustain &= $f;
	or   a1, a1, t2     ; adsr |= sustain;
	sh   a1, 0(t1)      ; *adsr_channel_addr = adsr;
	jr   ra
	nop
	
# Function: VS_TurnOnChannel
# Purpose: Turns on the audio playback of an SPU voice channel 
# a0: channel
VS_TurnOnChannel:
	li   t1, $1F801D88 ; spu_key_on_addr = (u16*)$1F801D88;
	li   t2, $1        ; bit = 1;
	sll  t2, t2, a0
	sh   t2, 0(t1)     ; *spu_key_on_addr = bit;
	li   t1, $1F801D8A
	sra  t2, t2, $10
	sh   t2, 0(t1)
	jr  ra 
	nop
	
# Function: VS_TurnOffChannel
# Purpose: Turns off the audio playback of an SPU voice channel 
# a0: channel
VS_TurnOffChannel:
	li t0, $1F801D88 ; spu_key_off_addr = (u16*)$1F801D88;
	li   t2, 1       ; bit = 1;
	sll  t2, t2, a0
	sh   t2, 0(t1)   ; *spu_key_off_addr = bit;
	nop
	
# Function: VS_TurnOnChannelModulation
# Purpose: Turns the pitch modulation on of an SPU voice channel 
# a0: channel
VS_TurnOnChannelModulation:
	li   t1, $1F801D90 ; spu_pitch_mod_on = (u16*)$1F801D90;
	li   t2, 1         ; bit = 1;
	sll  t2, a0
	sh   t2, 0(t1)     ; *spu_pitch_mod_on = bit;
	jr  ra 
	nop
	
# Function: VS_EnableReverb
# Purpose: Enables reverb in the SPU Control Register
VS_EnableReverb:
	li t0, VS_IO                 ; vs_io_addr = (unsigned long*)VS_IO; 
	lhu t1, VS_SPU_CTRL_ADDR(t0) ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	li t2, $80                   ; enable_reverb = 0x80;
	or t1, t2                    ; ctrl |= enable_reverb;
	sh t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr ra
	nop	
	
# Function: VS_DisableReverb
# Purpose: Disables reverb in the SPU Control Register
VS_DisableReverb:
	li t0, VS_IO                 ; vs_io_addr = (unsigned long*)VS_IO; 
	lhu t1, VS_SPU_CTRL_ADDR(t0) ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	li t2, $FF7F                 ; disable_reverb = 0xFF7F;
	and t1, t2                   ; ctrl &= disable_reverb;
	sh t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr ra
	nop	
	
# Function: VS_EnableCDAudio
# Purpose: Enables CD Audio in the SPU Control Register
VS_EnableCDAudio:
	li t0, VS_IO                 ; vs_io_addr = (unsigned long*)VS_IO; 
	lhu t1, VS_SPU_CTRL_ADDR(t0) ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	ori t1, 1                    ; ctrl |= enable_cd_audio;
	sh t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr ra
	nop	
	
# Function: VS_DisableCDAudio
# Purpose: Disables CD Audio in the SPU Control Register
VS_DisableCDAudio:
	li t0, VS_IO                 ; vs_io_addr = (unsigned long*)VS_IO; 
	lhu t1, VS_SPU_CTRL_ADDR(t0) ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	li t2, $FFFE                 ; disable_cd_audio = FFFE;
	and t1, t2                   ; ctrl &= disable_cd_audio;
	sh t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr ra
	nop	
	
# Function: VS_EnableCDAudioReverb
# Purpose: Enables CD Audio Reverb in the SPU Control Register
VS_EnableCDAudioReverb:
	li t0, VS_IO                 ; vs_io_addr = (unsigned long*)VS_IO; 
	lhu t1, VS_SPU_CTRL_ADDR(t0) ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	ori t1, 4                    ; ctrl |= enable_cd_audio_reverb;
	sh t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr ra
	nop	
	
# Function: VS_DisableCDAudioReverb
# Purpose: Disables CD Audio reverb in the SPU Control Register
VS_DisableCDAudioReverb:
	li t0, VS_IO                 ; vs_io_addr = (unsigned long*)VS_IO; 
	lhu t1, VS_SPU_CTRL_ADDR(t0) ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	li t2, $FFFB                 ; disable_cd_audio_reverb = FFFB;
	and t1, t2                   ; ctrl &= disable_cd_audio_reverb;
	sh t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr ra
	nop	

# Function: VS_GetChannelStatus
# Purpose: Returns the current playback status of the audio channel where 1 is finished and 0 is playing 
# a0: channel 
VS_GetChannelStatus:
	li   t1, $1F801D9C      ; key_status_addr = (u32*)$1F801D9C;
	lw   v0, 0(t1)          ; value = *key_status_addr;
	nop 
	sra  v0, v0, a0         ; value >>= channel;
	andi v0, v0, 1          ; value &= 1;
	jr ra 
	nop
	
# Function: VS_SetADPCMAddr
# Purpose: Sets the sound ram data transfer address
# a0: addr
VS_SetADPCMAddr:
	li t0, VS_IO                           ; vs_io_addr = VS_IO;
	sra a0, a0, $3                         ; addr >>= 3;
	sh a0, VS_SPU_DATA_TRANSFER_ADDR(t0)   ; *(unsigned short*)spu_trans_addr = addr;
	jr ra
	nop 

# Function: VS_SetChannelADPCMAddr
# Purpose: Sets the sound ram data transfer address of an SPU channel
# a0: channel, a1: addr
VS_SetChannelADPCMAddr:
	la t1, $1F801C06    ; VS_SPU_CHANNEL_ADPCM_ADDR = (u16*)$1F801C06;
	sll a0, 4           ; channel *= 16;
	addu t1, t1, a0     ; VS_SPU_CHANNEL_ADPCM_ADDR += channel;
	sra a1, $3          ; addr >>= 3;
	sh a1, 0(t1)        ; *(unsigned short*)VS_SPU_CHANNEL_ADPCM_ADDR = addr;
	jr ra
	nop 	
	
# Function: VS_SetChannelRepeatAddr
# Purpose: Sets the sound ram repeat data transfer address of an SPU channel
# a0: channel, a1: addr
VS_SetChannelRepeatAddr:
	la t1, $1F801C0E    ; repeat_addr = (u16*)$1F801C06;
	sll a0, 4           ; channel *= 16;
	addu t1, t1, a0     ; repeat_addr += channel;
	sra a1, $3          ; addr >>= 3;
	sh a1, 0(t1)        ; *(unsigned short*)repeat_addr = addr;
	jr ra
	nop 	
	
# Function: VS_WaitForSpuDMATransfer
# Purpose: Pause program execution until APCM data has completed its data transfer to the sound ram of the SPU via dma
VS_WaitForSpuDMATransfer:
	li t0, VS_IO
	li t1, VS_SPU_STATUS_TIMEOUT     ; i = VS_SPU_STATUS_TIMEOUT;
vs_wait_loop:
	beqz t1, vs_wait_loop_end        ; if(i == 0) { goto vs_wait_loop_end; }
	lhu  t2, VS_SPU_STATUS_ADDR(t0)  ; stat = *(unsigned short*)VS_SPU_STATUS_ADDR;
	subi  t1, 1                      ; i--; (delay slot)
	andi t2, $400                    ; stat &= mask;
	bnez t2, vs_wait_loop            ; if(stat != 0) { goto vs_wait_loop; }
	nop
vs_wait_loop_end:
	jr ra
	nop
	
# Function: VS_ClearADSR
# Purpose: Sets the attack, sustain, decay, and release rates to zero for a specific SPU channel
# a0: channel
VS_ClearADSR:
	li  t1, $1F801C08
	li t2, $10
	mult  a0, t2
	mflo a0
	addu t1, t1, a0 
	sh   zero, 0(t1)
	jr   ra
	nop
	
# Function: VS_SetDMAWrite
# Purpose: Sets the sound ram transfer mode to dma write
VS_SetDMAWrite:
	li   t0, VS_IO                             ; vs_io_addr = VS_IO;
	lw   t1, VS_SPU_BUS_CONFIG_ADDR(t0)        ; bus_config = *(unsigned long*)VS_SPU_BUS_CONFIG_ADDR;
	nop
	li   t2, $f0ffffff
	and  t1, t1, t2                            ; bus_config &= $f0ffffff;
	sw   t1, VS_SPU_BUS_CONFIG_ADDR(t0)        ; *(unsigned long*)VS_SPU_BUS_CONFIG_ADDR = bus_config;
	lhu  t1, VS_SPU_CTRL_ADDR(t0)  	           ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	nop
	andi t1, t1, $ffcf                         ; ctrl &= disable_current_dma_req;
	sh   t1, VS_SPU_CTRL_ADDR(t0)              ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	li   t1, VS_SPU_STATUS_TIMEOUT             ; spu_status_timeout = VS_SPU_STATUS_TIMEOUT;
WaitSpuDMA:
	beqz t1, FinishInitSPUDMA                  ; if(spu_status_timeout == 0) { goto FinishInitSPUDMA; }
	lhu  t2, VS_SPU_STATUS_ADDR(t0)            ; spu_stat = *(unsigned short*)VS_SPU_STATUS_ADDR;
	subi  t1, t1, $1       	                   ; spu_status_timeout--; (delay slot)
	andi t2, t2, $0030                         ; cond = spu_stat & $0030;
	bnez t2, WaitSpuDMA                        ; if(!cond) { goto WaitSpuDMA; }
	nop 
FinishInitSPUDMA:
	lhu  t1, VS_SPU_CTRL_ADDR(t0)              ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	nop
	ori  t1, t1, $0020                         ; ctrl |= write_mode;
	sh   t1, VS_SPU_CTRL_ADDR(t0)              ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	li   t1, VS_SPU_STATUS_TIMEOUT             ; spu_status_timeout = VS_SPU_STATUS_TIMEOUT;
WaitCtrlReg:
	beqz t1, FinishSetDMAWrite                 ; if(spu_status_timeout == 0) { goto dma_end; }
	lhu  t2, VS_SPU_STATUS_ADDR(t0)            ; spu_stat = *(unsigned short*)VS_SPU_STATUS_ADDR;
	subi t1, t1, 1                             ; spu_status_timeout-- (delay slot)
	andi t2, t2, $0030                         ; spu_stat &= $0030;
	li t3, $0020
	bne  t2, t3, WaitCtrlReg                   ; if(spu_stat != $0020) { goto WaitCtrlReg; }  
	nop
FinishSetDMAWrite:
	jr   ra
	nop
	
# Function: VS_SetDMAOff
# Purpose:
VS_SetDMAOff:
	li   t0, VS_IO                  ; vs_io_addr = VS_IO;
	lhu  t1, VS_SPU_CTRL_ADDR(t0)  ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	nop
	andi t1, t1, $ffcf            ; ctrl &= disable_current_dma_req;
	sh   t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr   ra 
	nop
	
# Function: VS_WriteADPCM
# Purpose: Writes APCM data via a dma request to the spu transfer address
# a0: apcm_addr, a1: size
VS_WriteADPCM:
	addi sp, sp, -8 
	sw   ra, 4(sp)
	jal  VS_SetDMAWrite                ; VS_SetDMAWrite();
	nop
	li   t0, VS_IO                    ; vs_io_addr = VS_IO;
	sw   a0, VS_SPU_DMA_M_ADDR(t0)   ; *(unsigned long*)VS_SPU_DMA_M_ADDR = apcm_addr;
	sra  a1, a1, $2                 ; size /= 4;
	andi t1, a1, $f                 
	beqz t1, align_size               ; if(size % 16) { goto align_size; }
	li   t2, $01000201 
	sra a1, a1, $4                  ; size /= 16;
	sll a1, a1, $10                 ; size <<= 16;
	ori a1, a1, $10
	sw  a1, VS_SPU_DMA_BCR_ADDR(t0)  ; *(unsigned long*)VS_SPU_DMA_BCR_ADDR = size;
	sw  t2, VS_SPU_DMA_CHCR_ADDR(t0) ; *(unsigned long*)VS_SPU_DMA_CHCR_ADDR  = $01000201;
	jal VS_WaitForSpuDMATransfer       ; VS_WaitForSpuDMATransfer();
	nop
	jal VS_SetDMAOff                   ; VS_SetDMAOff();
	nop
	lw   ra, 4(sp)
	addi sp, sp, 8
	jr  ra
	nop
align_size:
	addiu a1, a1, 15                 ; size += 15;
	sra a1, a1, $4                  ; size /= 16;
	sll a1, a1, $10                 ; size <<= 16;
	ori a1, a1, $10                 ; size |= 16;
	sw  a1, VS_SPU_DMA_BCR_ADDR(t0)  ; *(unsigned long*)VS_SPU_DMA_BCR_ADDR = size;
	sw  t2, VS_SPU_DMA_CHCR_ADDR(t0) ; *(unsigned long*)VS_SPU_DMA_CHCR_ADDR  = $01000201;
	jal VS_WaitForSpuDMATransfer       ; VS_WaitForSpuDMATransfer();
	nop
	jal VS_SetDMAOff                   ; VS_SetDMAOff();
	nop
	lw   ra, 4(sp)
	addi sp, sp, 8
	jr  ra
	nop
	
# Function: VS_ManuallyWriteADPCM
# a0: adpcm, a1: size 
VS_ManuallyWriteADPCM:
	li t0, VS_IO 
	lhu t1, VS_SPU_CTRL_ADDR(t0)    		 ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	sra a1, a1, $1                 		 ; size /= 2;
	andi t1, t1, $ffcf             		 ; ctrl &= $ffcf;
	sh t1, VS_SPU_CTRL_ADDR(t0)     		 ; *(unsigned shor*)VS_SPU_CTRL_ADDR = ctrl;
	li t1, VS_SPU_STATUS_TIMEOUT     		 ; spu_status_timeout = VS_SPU_STATUS_TIMEOUT;
WaitManualSPUDMA:
	beqz t1, FinishInitManualSpuDMA  		 ; if(spu_status_timeout == 0) { goto FinishInitSPUDMA; }
	lhu  t2, VS_SPU_STATUS_ADDR(t0) 		 ; spu_stat = *(unsigned short*)VS_SPU_STATUS_ADDR;
	subi  t1, t1, $1       	      		 ; spu_status_timeout--; (delay slot)
	andi t2, t2, $0030              		 ; cond = spu_stat & $0030;
	bnez t2, WaitManualSPUDMA               ; if(!cond) { goto WaitManualSPUDMA; }
	nop 
FinishInitManualSpuDMA:
	lhu t1, VS_SPU_DATA_TRANSFER_ADDR(t0)  ; addr = *(unsigned short*)VS_SPU_DATA_TRANSFER_ADDR;
	nop
ManualDMALoop:
	li t2, 32 
	blt t2, a1, vs_min_a                   ; if(32 < size) { goto vs_min_a; }
	nop 
	move v0, a1   					     ; min = size;
	sub a1, a1, v0                        ; size -= min;
	b vs_min_b 
	nop
vs_min_a:
	move v0, t2                            ; min = 32;
	sub a1, a1, v0                        ; size -= min;
vs_min_b:
	sh t1, VS_SPU_DATA_TRANSFER_ADDR(t0)   ; *(unsigned short*)VS_SPU_DATA_TRANSFER_ADDR = addr;
	sra t2, v0, $2                        ; incr = min >>= 2;
	addu t1, t1, t2                       ; addr += incr;
WriteDataLoop:
	lhu t2, 0(a0)                          ; half = *adpcm;
	addi a0, a0, $2                       ; adpcm += 2;
	sh t2, $1da8(t0)                      ; *(unsigned short*)VS_SPU_DATA_ADDR = half;
	subi v0, v0, $1                       ; min--;
	bnez v0, WriteDataLoop                  ; if(min != 0) { goto WriteDataLoop; }
	nop
	lhu t2, VS_SPU_CTRL_ADDR(t0)    		 ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	nop
	ori t2, t2, $0010             		 ; ctrl |= $0010;
	sh t2, VS_SPU_CTRL_ADDR(t0)     		 ; *(unsigned shor*)VS_SPU_CTRL_ADDR = ctrl;
	li t3, VS_SPU_STATUS_TIMEOUT
WaitDMABusy:
	beqz t3, FinishStatusReg  		         ; if(spu_status_timeout == 0) { goto FinishStatusReg; }
	lhu  t2, VS_SPU_STATUS_ADDR(t0) 		 ; spu_stat = *(unsigned short*)VS_SPU_STATUS_ADDR;
	subi  t3, t3, $1       	      		 ; spu_status_timeout--; (delay slot)
	andi t2, t2, $0400              		 ; cond = spu_stat & $0400;
	bnez t2, WaitDMABusy                    ; if(!cond) { goto WaitDMABusy; }
	nop 
FinishStatusReg:
	li t2, $1000 
Delay:
	subi t2, t2, $1 
	bnez t2, Delay
	nop	
FinalCheck:
	bnez a1, ManualDMALoop
	nop 
	lhu  t1, VS_SPU_CTRL_ADDR(t0)  ; ctrl = *(unsigned short*)VS_SPU_CTRL_ADDR;
	nop
	andi t1, t1, $ffcf            ; ctrl &= disable_current_dma_req;
	sh   t1, VS_SPU_CTRL_ADDR(t0)  ; *(unsigned short*)VS_SPU_CTRL_ADDR = ctrl;
	jr ra 
	nop

# a0: mask, a1: value
WaitStatus:	
	li   t0, VS_IO
	li   t3, VS_SPU_STATUS_TIMEOUT              ; spu_status_timeout = VS_SPU_STATUS_TIMEOUT;
WaitStatusLoop:
	beqz t3, FinishWaitStatus                   ; if(spu_status_timeout == 0) { goto FinishWaitStatus; }
	lhu  t2, VS_SPU_STATUS_ADDR(t0)            ; spu_stat = *(unsigned short*)VS_SPU_STATUS_ADDR;
	subi t3, t3, $1       	                 ; spu_status_timeout--; (delay slot)
	and  t2, t2, a0                           ; cond = spu_stat & mask;
	bne t2, a1, WaitStatusLoop                 ; if(cond != value) { goto WaitStatusLoop; }
	nop 
FinishWaitStatus:
	jr ra 
	nop
	
# Function: VS_ResetReverbChannels
# Purpose: Sets reflection, comb, and APF reverb channel volumes to original values
VS_ResetReverbChannels:
	li t0, $1F801DC4
	li t1, $7E00
	sh t1, 0(t0)
	li t0, $1F801DCE
	li t1, $B000
	sh t1, 0(t0)
	li t0, $1F801DC6
	li t1, $5000
	sh t1, 0(t0)
	li t0, $1F801DC8
	li t1, $B400
	sh t1, 0(t0)
	li t0, $1F801DCA
	li t1, $B000
	sh t1, 0(t0)
	li t0, $1F801DCC
	li t1, $4C00
	sh t1, 0(t0)
	li t0, $1F801DD0
	li t1, $6000
	sh t1, 0(t0)
	li t0, $1F801DD2
	li t1, $5400
	sh t1, 0(t0)
	jr ra
	nop 
	
# Function: VSClearReverbChannels
# Purpose: Sets reflection, comb, and APF reverb channel volumes to zero
VS_ClearReverbChannels:
	li t0, VS_IO
	sh zero, $1DC0(t0)
	sh zero, $1DC2(t0)
	sh zero, $1DC4(t0)
	sh zero, $1DC6(t0)
	sh zero, $1DC8(t0)
	sh zero, $1DCA(t0)
	sh zero, $1DCC(t0)
	sh zero, $1DCE(t0)
	sh zero, $1DD0(t0)
	sh zero, $1DD2(t0)
	sh zero, $1DD4(t0)
	sh zero, $1DD6(t0)
	sh zero, $1DD8(t0)
	sh zero, $1DDA(t0)
	sh zero, $1DDC(t0)
	sh zero, $1DDE(t0)
	sh zero, $1DE0(t0)
	sh zero, $1DE2(t0)
	sh zero, $1DE4(t0)
	sh zero, $1DE6(t0)
	sh zero, $1DE8(t0)
	sh zero, $1DEA(t0)
	sh zero, $1DEC(t0)
	sh zero, $1DEE(t0)
	sh zero, $1DF0(t0)
	sh zero, $1DF2(t0)
	sh zero, $1DF4(t0)
	sh zero, $1DF6(t0)
	sh zero, $1DF8(t0)
	sh zero, $1DFA(t0)
	sh zero, $1DFC(t0)
	sh zero, $1DFE(t0)
	jr ra
	nop