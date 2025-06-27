#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# bios.asm - A collection of BIOS functions that I use 
#-----------------------------------------------------------

# Function: VS_OpenEvent
# Purpose: Adds an event to the PSX's event table
# a0: class, a1: spec, a2: mode, a3: func 
VS_OpenEvent:
	li t1, 8     ; bios_func = 8;
	li t2, $B0   ; bios_func_type = 0xB0
	jr t2        ; goto bios_func;
	nop
	
# Function: VS_CloseEvent
# Purpose: Releases an event from the PSX's event table
# a0: event
VS_CloseEvent:
	li t1, 8     ; bios_func = 9;
	li t2, $B0   ; bios_func_type = 0xB0
	jr t2        ; goto bios_func;
	nop
	
# Function: VS_EnableEvent
# Purpose: Enables an event in the PSX's event table
# a0: event
VS_EnableEvent:
	li t1, 12    ; bios_func = 12;
	li t2, $B0   ; bios_func_type = 0xB0
	jr t2        ; goto bios_func;
	nop
	
# Function: VS_DisableEvent
# Purpose: Disables an event in the PSX's event table
# a0: event
VS_DisableEvent:
	li t1, 13    ; bios_func = 13;
	li t2, $B0   ; bios_func_type = 0xB0
	jr t2        ; goto bios_func;
	nop
	
# Function: VS_WaitEvent
# Purpose: Waits on an event from the event table
# a0: event
VS_WaitEvent:
	li t1, $0A        ; bios_func = 0x0A;
	li t2, $B0        ; bios_func_type = 0xB0;
	jr t2             ; goto bios_func;
	nop
	
# Function: VS_TestEvent
# Purpose: Test on an event from the event table
# a0: event
VS_TestEvent:
	li t1, $0B        ; bios_func = 0x0B;
	li t2, $B0        ; bios_func_type = 0xB0;
	jr t2             ; goto bios_func;
	nop
	
# Function: VS_EnterCritialSection
# Purpose: Kernel enters into critical section for mutual exclusivity
VS_EnterCritialSection:
	li a0, 1
	syscall
	jr ra 
	nop
	
# Function: VS_ExitCritialSection
# Purpose: Kernel exits the critical section
VS_ExitCritialSection:
	li a0, 2
	syscall
	jr ra 
	nop