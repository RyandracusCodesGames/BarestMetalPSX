#-----------------------------------------------------------
# BarestMetalPSX
# (C) 2025 Ryandracus Chapman
#-----------------------------------------------------------
# math.asm - A simple math library for common general-purpose 
# math routines, and an interface over the PlayStation's
# Geometry Transformation Engine(GTE)
#-----------------------------------------------------------
	.syntax asmpsx
	.arch ps1
	.text
	
VS_FIXED_ONE equ 4096
	
# Function: VS_InitGTE
# Purpose: Initializes the math co-processor of the PlayStation, the Geometry Transformation Engine(GTE)
VS_InitGTE:
	li a0, $40000000
	mfc0 a0, r12
	jr ra
	nop
	
# Function: VS_Abs
# Purpose: Returns the absolute value of an integer
# a0: int 
VS_Abs:
	bltz a0, compute_abs ; if(int < 0) { goto compute_abs; }
	nop 
	move v0, a0          ; return int;
	jr ra
	nop 
	
compute_abs:
	sub v0, zero, a0    ; return 0 - int;
	jr ra 
	nop
	
# Function: VS_Min
# Purpose: Returns the minimum value between two integers 
# a0: a, a1: b 
VS_Min:
	blt a0, a1, return_a ; if(a < b) { goto return_a; }
	nop 
	move v0, a1          ; return b;
	jr ra 
	nop 
return_a:
	move v0, a0          ; return a;
	jr ra 
	nop
	
# Function: VS_Max
# Purpose: Returns the maximum value between two integers 
# a0: a, a1: b 
VS_Max:
	bge a1, a0, return_b ; if(b > a) { goto return_b; }
	nop 
	move v0, a0          ; return a;
	jr ra 
	nop 
return_b:
	move v0, a1          ; return b;
	jr ra 
	nop
	
# Function: VS_Clamp 
# Purpose: Clamps a target value between the range of min to max
# a0: min, a1: target, a2: max 
VS_Clamp:
	bge a1, a2, vs_clamp_max ; if(target >= max) { goto vs_clamp_max; }
	nop 
	ble a1, a0, vs_clamp_min ; if(target <= min) { goto vs_clamp_min; }
	nop 
	move v0, a1              ; return target;
	jr ra 
	nop 
	
vs_clamp_max:
	move v0, a2             ; return max;
	jr ra 
	nop
	
vs_clamp_min:
	move v0, a0             ; return min;
	jr ra 
	nop
	
# Function: VS_Int2Fixed
# Purpose: Converts an integer into the PlayStation's 20.12 Fixed-Point format
# a0: int
VS_Int2Fixed:
	sll v0, a0, 12 ; return int << 12;
	jr ra 
	nop
	
# Function: VS_Fixed2Int
# Purpose: Converts 20.12 Fixed-Point number into an integer
# a0: fixed
VS_Fixed2Int:
	sra v0, a0, 12 ; return fixed >> 12;
	jr ra 
	nop
	
# Function: VS_FixedMul
# Purpose: Multiplies a fixed-point number by an integer
# a0: fixed, a1: multiplier
VS_FixedMul:
	mult a0, a1  ; fixed *= multiplier;
	mflo v0       
	sra v0, 12   ; fixed >>= 12;
	jr ra        ; return fixed;
	nop
	
# Function: VS_FixedDiv
# Purpose: Divides a number by an integer and converts it into fixed-point format
# a0: int, a1: divider
VS_FixedDiv:
	sll a0, 12  ; int <<= 12;
	div a0, a1  ; int /= divider;
	mflo v0       
	jr ra       ; return int;
	nop
	
# Function: VS_Sin
# Purpose: Compute the fixed-point sin of a number
# a0: num 
# Shoutout: Lameguy and SpiceJpeg in PSn00bSDK(https://github.com/Lameguy64/PSn00bSDK/blob/master/libpsn00b/psxgte/isin.c)
# https://www.coranac.com/2009/07/sines
VS_Sin:
	sll t0, a0, 20 ; c = num << 20;
	subi a0, 1024  ; x -= 1024;
	sll a0, a0, 21 ; x <<= 21;
	sra a0, a0, 21 ; x >>= 21;
	mult a0, a0    ; x *= x;
	mflo a0
	sra a0, a0, $6 ; x >>= 6;
	li t1, 3516    ; C = 3516;
	mult a0, t1    ; y = x * C;
	mflo t1       
	sra t1, t1, 14 ; y >>= 14;
	li  t2, 19900  ; B = 19900
	sub t1, t2, t1 ; y = B - y;
	mult a0, t1    ; y = x * y;
	mflo t1
	sra t1, t1, 16 ; y >>= 16;
	li  t2, 4096    ; fix_one = 4096;
	sub t1, t2, t1   ; y = 4096 - y;
	bgez t0, positive ; if(c >= 0) { goto positive; }
	nop
	sub v0, zero, t1  ; return -y;
	jr  ra
	nop
positive:
	addi v0, t1, 0x0 ; return y;
	jr ra
	nop
	
# Function: VS_Cos
# Purpose: Compute the fixed-point cos of a number
# a0: num 
# Shoutout: Lameguy and SpiceJpeg PSn00bSDK(https://github.com/Lameguy64/PSn00bSDK/blob/master/libpsn00b/psxgte/isin.c)
# https://www.coranac.com/2009/07/sines
VS_Cos:
	addi a0, a0, 1024
	sll t0, a0, 20 ; c = num << 20;
	subi a0, 1024  ; x -= 1024;
	sll a0, a0, 21 ; x <<= 21;
	sra a0, a0, 21 ; x >>= 21;
	mult a0, a0    ; x *= x;
	mflo a0
	sra a0, a0, $6 ; x >>= 6;
	li t1, 3516    ; C = 3516;
	mult a0, t1    ; y = x * C;
	mflo t1       
	sra t1, t1, 14 ; y >>= 14;
	li  t2, 19900  ; B = 19900
	sub t1, t2, t1 ; y = B - y;
	mult a0, t1    ; y = x * y;
	mflo t1
	sra t1, t1, 16 ; y >>= 16;
	li  t2, 4096    ; fix_one = 4096;
	sub t1, t2, t1   ; y = 4096 - y;
	bgez t0, positive_cos ; if(c >= 0) { goto positive; }
	nop
	sub v0, zero, t1  ; return -y;
	jr  ra
	nop
positive_cos:
	addi v0, t1, 0x0 ; return y;
	jr ra
	nop
	
# Function: VS_ISQRT
# Purpose: Returns the integer square root of an unsigned integer
# a0: integer 
VS_ISQRT:
	li v0, 0                  ; g = 0;
	li t0, $8000              ; b = 0x8000;
	li t1, $F                 ; bshift = 15; 
isqrt_loop:
	sll  t2, v0, 1            ; temp = g << 1;
	addu t2, t0               ; temp += b;
	sll  t2, t1               ; temp <<= bshift;
	subi t1, 1                ; bshift--;
	sltu t3, a0, t2          
	bnez t3, adjust_isqrt     ; if(val < temp) { goto adjust_isqrt; }
	nop
	addu v0, t0               ; g += b;
	subu a0, a0, t2           ; val -= temp;	
adjust_isqrt:
	sra  t0, t0, 1            ; b >>= 1;
	bnez t0, isqrt_loop       ; if(!b) { goto isqrt_loop; }
	nop 
	jr ra 
	nop
	
# Function: VS_SetPlaneProjectionDistance
# Purpose: Sets the distance of the projection plane of the GTE
# a0: dist 
VS_SetPlaneProjectionDistance:
	andi a0, $FFFF  ; dist &= 0xFFFF;
	ctc2 a0, r26    ; *cop2r58 = dist;
	jr ra
	nop
	
# Function: VS_SetScreenOffsetX
# Purpose: Sets the x screen offset (a 16.16 fixed-point number) of the GTE
# a0: x 
VS_SetScreenOffsetX:
	sll a0, 16    ; x <<= 16;
	ctc2 a0, r24  ; *cop2r56 = x;
	jr ra
	nop
	
# Function: VS_SetScreenOffsetY
# Purpose: Sets the y screen offset (a 16.16 fixed-point number) of the GTE
# a0: y 
VS_SetScreenOffsetY:
	sll a0, 16    ; y <<= 16;
	ctc2 a0, r25  ; *cop2r57 = y;
	jr ra
	nop

# Function: VS_SetXTranslationGTE
# Purpose: Moves a signed 32-bit integer into the X-coordinate translation vector register of the GTE 
# a0: x
VS_SetXTranslationGTE:
	ctc2 a0, r5 ; *cop2r37 = x;
	jr ra 
	nop
	
# Function: VS_SetYTranslationGTE
# Purpose: Moves a signed 32-bit integer into the Y-coordinate translation vector register of the GTE 
# a0: y
VS_SetYTranslationGTE:
	ctc2 a0, r6 ; *cop2r38 = y;
	jr ra 
	nop
	
# Function: VS_SetZTranslationGTE
# Purpose: Moves a signed 32-bit integer into the Z-coordinate translation vector register of the GTE 
# a0: z
VS_SetZTranslationGTE:
	ctc2 a0, r7 ; *cop2r39 = z;
	jr ra 
	nop
	
# Function: VS_SetTranslationVectorGTE
# Purpose: Moves three signed 32-bit integers into the (X,Y,Z) translation coordinate vector register of the GTE 
# a0: x, a1: y, a2: z
VS_SetTranslationVectorGTE:
	ctc2 a0, r5 ; *cop2r37 = x;
	ctc2 a1, r6 ; *cop2r38 = y;
	ctc2 a2, r7 ; *cop2r39 = z;
	jr ra 
	nop
	
# Function: VS_ClearTranslationVectorGTE
# Purpose: Zeros out the (X,Y,Z) translation coordinate vector register of the GTE 
VS_ClearTranslationVectorGTE:
	ctc2 zero, r5 ; *cop2r37 = 0;
	ctc2 zero, r6 ; *cop2r38 = 0;
	ctc2 zero, r7 ; *cop2r39 = 0;
	jr ra 
	nop

# Function: VS_IntToVector3D
# Purpose: Converts three integers values into 20.12 Fixed-Point numbers and stores the result into a vector 
# a0: vec, a1: x, a2: y, a3: z 
VS_IntToVector3D:
	sll a1, 12      ; x <<= 12;
	sw a1, 0(a0)    ; vec->x = x;
	sll a2, 12      ; y <<= 12;
	sw a2, 4(a0)    ; vec->y = y;
	sll a3, 12      ; z <<= 12;
	sw a3, 8(a0)    ; vec->z = z;
	jr ra 
	nop
	
# Function: VS_SetVector3D
# Purpose: Stores a 20.12 Fixed-Point triplet into a vector
# a0: vec, a1: x, a2: y, a3: z 
VS_SetVector3D:
	sw a1, 0(a0)    ; vec->x = x;
	sw a2, 4(a0)    ; vec->y = y;
	sw a3, 8(a0)    ; vec->z = z;
	jr ra 
	nop
	
# Function: VS_CopyVector3D
# Purpose: Copies the contents of a source vector into a destination vector
# a0: dest, a1: src
VS_CopyVector3D:
	lw t0, 0(a1)  ; x = src->x;
	lw t1, 4(a1)  ; y = src->y;
	sw t0, 0(a0)  ; dest->x = x;
	lw t0, 8(a1)  ; z = src->z;
	sw t1, 4(a0)  ; dest->y = y;
	sw t0, 8(a0)  ; dest->z = z;
	jr ra 
	nop

# Function: VS_AddVector3D
# Purpose: Adds two 3-D vectors together and stores the result in vector 1
# a0: vec1, a1: vec2, a2: out 
VS_AddVector3D:
	lw t0, 0(a0) ; x1 = vec1->x;
	lw t1, 0(a1) ; x2 = vec2->x;
	nop 
	add t0, t1   ; x1 += x2;
	sw t0, 0(a2) ; out->x = x;
	lw t0, 4(a0) ; y1 = vec1->y;
	lw t1, 4(a1) ; y2 = vec2->y;
	nop 
	add t0, t1   ; y1 += y2;
	sw t0, 4(a2) ; out->y = y;
	lw t0, 8(a0) ; z1 = vec1->z;
	lw t1, 8(a1) ; z2 = vec2->z;
	nop 
	add t0, t1   ; z1 += z2;
	sw t0, 8(a2) ; out->z =z;
	jr ra 
	nop
	
# Function: VS_SubVector3D
# Purpose: Subtracts two 3-D vectors together and stores the result in vector 1
# a0: vec1, a1: vec2, a2: out 
VS_SubVector3D:
	lw t0, 0(a0) ; x1 = vec1->x;
	lw t1, 0(a1) ; x2 = vec2->x;
	nop 
	sub t0, t1   ; x1 -= x2;
	sw t0, 0(a2) ; out->x = x;
	lw t0, 4(a0) ; y1 = vec1->y;
	lw t1, 4(a1) ; y2 = vec2->y;
	nop 
	sub t0, t1   ; y1 -= y2;
	sw t0, 4(a2) ; out->y = y;
	lw t0, 8(a0) ; z1 = vec1->z;
	lw t1, 8(a1) ; z2 = vec2->z;
	nop 
	sub t0, t1   ; z1 -= z2;
	sw t0, 8(a2) ; out->z =z;
	jr ra 
	nop
	
# Function: VS_MultiplyVector3DByScalar
# Purpose: Multiplies the (X,Y,Z) coordinate triplet by a scalar value 
# a0: vec, a1: scalar, a2: out 
VS_MultiplyVector3DByScalar:
	lw t0, 0(a0)  ; x = vec->x
	lw t1, 4(a0)  ; y = vec->y;
	mult t0, a1 
	mflo t0       ; x *= scalar;
	sw t0, 0(a2)  ; out->x = x;
	mult t1, a1 
	mflo t1       ; y *= scalar;
	lw t0, 8(a0)  ; z = vec->z;
	sw t1, 4(a2)  ; out->y = y;
	mult t0, a1 
	mflo t0       ; z *= scalar;
	sw t0, 8(a2)  ; out->z = scalar;
	jr ra 
	nop
	
# Function: VS_DivideVector3DByScalar
# Purpose: Divides the (X,Y,Z) coordinate triplet by a scalar value 
# a0: vec, a1: scalar, a2: out
VS_DivideVector3DByScalar:
	lw t0, 0(a0)  ; x = vec->x
	lw t1, 4(a0)  ; y = vec->y;
	div t0, a1 
	mflo t0       ; x /= scalar;
	sw t0, 0(a2)  ; out->x = x;
	div t1, a1 
	mflo t1       ; y /*= scalar;
	lw t0, 8(a0)  ; z = vec->z;
	sw t1, 4(a2)  ; out->y = y;
	div t0, a1 
	mflo t0       ; z /= scalar;
	sw t0, 8(a2)  ; out->z = scalar;
	jr ra 
	nop
	
# Function: VS_SquareVector3D
# Purpose: Computes the square of a 3-D vector 
# a0: vec, a1: out
VS_SquareVector3D:
	lwc2 r9, 0(a0)
	lwc2 r10, 4(a0)
	lwc2 r11, 8(a0)
	cop2 $0A00428 + $80000
	swc2 r9, 0(a1)
	swc2 r10, 4(a1)
	swc2 r11, 8(a1)
	jr ra 
	nop
	
# Function: VS_DotProduct
# Purpose: Computes the dot product between two 3-D vectors
# a0: vec1, a1: vec2 
VS_DotProduct:
	lw t0, 0(a0)  ; x1 = vec1->x;
	lw t1, 0(a1)  ; x2 = vec2->x;
	move v0, zero ; result = 0;
	mult t0, t1  
	mflo t2       ; x1 *= x2;
	lw t0, 4(a0)  ; y1 = vec1->y;
	lw t1, 4(a1)  ; y2 = vec2->y;
	addu v0, t2   ; result += x1; 
	mult t0, t1  
	mflo t2       ; y1 *= y2;
	lw t0, 8(a0)  ; z1 = vec1->z;
	lw t1, 8(a1)  ; z2 = vec2->z;
	addu v0, t2   ; result += y1; 
	mult t0, t1  
	mflo t2       ; z1 *= z2;
	addu v0, t2   ; result += z1;
	sra v0, 12    ; result >>= 12;
	jr ra 
	nop
	
# Function: VS_CrossProduct
# Purpose: Computes the cross product between two 3-D vectors and stores the result in vector 1 
# a0: vec1, a1: vec2, a2: out
# out->x = ((vec1.y * vec2.z) - (vec1.z * vec2.y)) >> 12
# out->y = ((vec1.z * vec2.x) - (vec1.x * vec2.z)) >> 12
# out->z = ((vec1.x * vec2.y) - (vec1.y * vec2.x)) >> 12
VS_CrossProduct:
	lw t0, 4(a0)   ; vy1 = vec1->y;
	lw t3, 8(a1)   ; vz2 = vec2->y;
	lw t1, 4(a1)   ; vy2 = vec2->y;
	mult t0, t3    ; result1 = vy1 * vz2;
	lw t2, 8(a0)   ; vz1 = vec1->y;
	mflo a3      
	mult t2, t1    ; result2 = vz1 * vy2;
	mflo t4 
	sub a3, a3, t4 ; x = result1 - result2;
	sra a3, 12     ; x >>= 12;
	lw t5, 0(a1)   ; vx2 = vec2->x;
	sw a3, 0(a2)   ; out->x = x;
	mult t2, t5    ; result1 = vz1 * vx2;
	lw t2, 0(a0)   ; vx1 = vec1->x;
	mflo a3
	mult t2, t3    ; result2 = vx1 * vz2;
	mflo t3 
	sub a3, a3, t3 ; y = result1 - result2;
	sra a3, 12     ; y >>= 12;
	sw a3, 4(a2)   ; out->y = y;
	mult t2, t1    ; result1 = vx1 * vy2;
	mflo a3 
	mult t0, t5    ; result2 = vy1 * vx2;
	mflo t0
	sub t0, a3, t0 ; z = result1 - result2;
	sra t0, 12     ; z >>= 12;
	sw t0, 8(a2)   ; out->z = z;
	jr ra 
	nop
	
# Function: VS_MakeMatrixIdentity
# Purpose: Initializes the cells of a matrix into that of an identity matrix 
# a0: mat 
VS_MakeMatrixIdentity:
	li a1, VS_FIXED_ONE ; fix_one = 4096;
	sh a1, 0(a0)        ; mat->m00 = fix_one;
	sh zero, 2(a0)      ; mat->m01 = 0;
	sh zero, 4(a0)      ; mat->m02 = 0;
	sh zero, 6(a0)      ; mat->m10 = 0;
	sh a1, 8(a0)        ; mat->m11 = fix_one;
	sh zero, 10(a0)     ; mat->m12 = 0;
	sh zero, 12(a0)     ; mat->m20 = 0;
	sh zero, 14(a0)     ; mat->m21 = 0;
	sh a1, 16(a0)       ; mat->m22 = fix_one;
	jr ra 
	nop
	
# Function: VS_MakeMatrixTranslation
# Purpose: Initializes the translation vector of a matrix 
# a0: mat, a1: x, a2: y, a3: z
VS_MakeMatrixTranslation:
	sw a1, 20(a0)       ; mat->tx = x;
	sw a2, 24(a0)       ; mat->ty = y;
	sw a3, 28(a0)       ; mat->tz = z;
	jr ra
	nop
	
# Function: VS_MakeMatrixScale
# Purpose: Initializes the cells of a matrix into that of a scale matrix 
# a0: mat, a1: sx, a2: sy, a3: sz
VS_MakeMatrixScale:
	sh a1, 0(a0)        ; mat->m00 = sx;
	sh zero, 2(a0)      ; mat->m01 = 0;
	sh zero, 4(a0)      ; mat->m02 = 0;
	sh zero, 6(a0)      ; mat->m10 = 0;
	sh a2, 8(a0)        ; mat->m11 = sy;
	sh zero, 10(a0)     ; mat->m12 = 0;
	sh zero, 12(a0)     ; mat->m20 = 0;
	sh zero, 14(a0)     ; mat->m21 = 0;
	sh a3, 16(a0)       ; mat->m22 = sz;
	jr ra 
	nop
	
# Function: VS_MakeMatrixRotationX
# Purpose: Initializes the cells of a matrix into that of a rotation matrix around the x-axis
# a0: mat, a1: angle 
VS_MakeMatrixRotationX:
	addi sp, -16 
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	move s0, a0       ; temp_mat = mat;
	move s1, a1       ; temp_angle = angle;
	move a0, s1 
	jal VS_Sin        ; result = VS_Sin(angle);
	nop 
	move s2, v0       ; sin = result;
	move a0, s1 
	jal VS_Cos        ; cos = VS_Cos(angle);
	nop 
	li t0, 4096
	sh t0, 0(s0)      ; temp_mat->m00 = VS_FIXED_ONE;
	sh zero, 2(s0)    ; temp_mat->m01 = 0;
	sh zero, 4(s0)    ; temp_mat->m02 = 0;
	sh zero, 6(s0)    ; temp_mat->m10 = 0;
	sh v0, 8(s0)      ; temp_mat->m11 = cos;
	sub t0, zero, s2  ; neg_sin = 0 - sin;
	sh t0, 10(s0)     ; temp_mat->m12 = neg_sin;
	sh zero, 12(s0)   ; temp_mat->m20 = 0;
	sh s2, 14(s0)     ; temp_mat->m21 = sin;
	sh v0, 16(s0)     ; temp_mat->m22 = cos;
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	addi sp, 16 
	jr ra 
	nop
	
# Function: VS_MakeMatrixRotationY
# Purpose: Initializes the cells of a matrix into that of a rotation matrix around the y-axis
# a0: mat, a1: angle 
VS_MakeMatrixRotationY:
	addi sp, -16 
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	move s0, a0       ; temp_mat = mat;
	move s1, a1       ; temp_angle = angle;
	move a0, s1 
	jal VS_Sin        ; result = VS_Sin(angle);
	nop 
	move s2, v0       ; sin = result;
	move a0, s1 
	jal VS_Cos        ; cos = VS_Cos(angle);
	nop 
	li t0, 4096
	sh v0, 0(s0)      ; temp_mat->m00 = cos;
	sh zero, 2(s0)    ; temp_mat->m01 = 0;
	sh s2, 4(s0)      ; temp_mat->m02 = sin;
	sh zero, 6(s0)    ; temp_mat->m10 = 0;
	sh t0, 8(s0)      ; temp_mat->m11 = VS_FIXED_ONE;
	sub t0, zero, s2  ; neg_sin = 0 - sin;
	sh zero, 10(s0)   ; temp_mat->m12 = 0;
	sh t0, 12(s0)     ; temp_mat->m20 = -sin;
	sh zero, 14(s0)   ; temp_mat->m21 = 0;
	sh v0, 16(s0)     ; temp_mat->m22 = cos;
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	addi sp, 16 
	jr ra 
	nop
	
# Function: VS_MakeMatrixRotationZ
# Purpose: Initializes the cells of a matrix into that of a rotation matrix around the z-axis
# a0: mat, a1: angle 
VS_MakeMatrixRotationZ:
	addi sp, -16 
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	move s0, a0       ; temp_mat = mat;
	move s1, a1       ; temp_angle = angle;
	move a0, s1 
	jal VS_Sin        ; result = VS_Sin(angle);
	nop 
	move s2, v0       ; sin = result;
	move a0, s1 
	jal VS_Cos        ; cos = VS_Cos(angle);
	nop 
	sub t0, zero, s2  ; neg_sin = 0 - sin;
	sh v0, 0(s0)      ; temp_mat->m00 = cos;
	sh t0, 2(s0)      ; temp_mat->m01 = -sin;
	sh zero, 4(s0)    ; temp_mat->m02 = 0;
	sh s2, 6(s0)      ; temp_mat->m10 = sin;
	sh v0, 8(s0)      ; temp_mat->m11 = cos;
	li t0, 4096
	sh zero, 10(s0)   ; temp_mat->m12 = 0;
	sh zero, 12(s0)   ; temp_mat->m20 = 0;
	sh zero, 14(s0)   ; temp_mat->m21 = 0;
	sh t0, 16(s0)     ; temp_mat->m22 = VS_FIXED_ONE;
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	addi sp, 16 
	jr ra 
	nop
	
# Function: VS_PushMatrixToGTE
# Purpose: Uploads the matrix to the GTE rotation matrix registers and its translation vector to the translation registers
# a0: mat
VS_PushMatrixToGTE:
	lw t0, 0(a0)  ; word1 = mat->m01 << 16 | mat->m00;
	lw t1, 4(a0)  ; word2 = mat->m10 << 16 | mat->m02;
	ctc2 t0, r0	  ; *cop2r32 = word1;
	lw t2, 8(a0)  ; word3 = mat->m11 << 16 | mat->m12;
	ctc2 t1, r1   ; *cop2r33 = word2;
	ctc2 t2, r2   ; *cop2r34 = word3;
	lw t0, 12(a0) ; word1 = mat->m21 << 16 | mat->m20;
	lh t1, 16(a0) ; word2 = mat->m22;
	ctc2 t0, r3	  ; *cop2r35 = word1;
	ctc2 t1, r4   ; *cop2r36 = word2;
	lw t0, 20(a0) ; x = mat->tx;
	lw t1, 24(a0) ; y = mat->ty;
	lw t2, 28(a0) ; z = mat->tz;
	ctc2 t0, r5   ; *cop2r37 = x;
	ctc2 t1, r6   ; *cop2r38 = y;
	ctc2 t2, r7   ; *cop2r39 = z;
	jr ra
	nop
	
# Function: VS_ClearMatrixGTE
# Purpose: Zeros out the rotation matrix registers of the GTE 
VS_ClearMatrixGTE:
	ctc2 zero, r0	; *cop2r32 = 0;
	ctc2 zero, r1   ; *cop2r33 = 0;
	ctc2 zero, r2   ; *cop2r34 = 0;
	ctc2 zero, r3	; *cop2r35 = 0;
	ctc2 zero, r4   ; *cop2r36 = 0;
	jr ra 
	nop
	
# Function: VS_LoadThreeVectorsToGTE
# Purpose: Loads three vectors, 16-bit x, y, z, pad format, to the GTE data registers C2_VXY0, C2_VZ0, C2_VXY1, C2_VZ1, C2_VXY2 and C2_VZ2
# a0: vec1, a1: vec2, a2: vec3
VS_LoadThreeVectorsToGTE:
	lwc2 r0, 0(a0)
	lwc2 r1, 4(a0)
	lwc2 r2, 0(a1)
	lwc2 r3, 4(a1)
	lwc2 r4, 0(a2)
	lwc2 r5, 4(a2)
	jr ra 
	nop
	
# Function: VS_LoadOneVectorToGTE
# Purpose: Loads one vector, 16-bit x, y, z, pad format, to the GTE data registers C2_VXY0 and C2_VZ0
# a0: vec1
VS_LoadOneVectorToGTE:
	lwc2 r0, 0(a0)
	lwc2 r1, 4(a0)
	jr ra 
	nop

# Function: VS_CopyMatrix
# Purpose: Copies the cells of an input matrix into an output matrix 
# a0: dest, a1: src 
VS_CopyMatrix:
	lh t0, 0(a1)  ; m00 = src->m00;
	lh t1, 2(a1)  ; m01 = src->m01;
	sh t0, 0(a0)  ; dest->m00 = m00; 
	lh t0, 4(a1)  ; m02 = src->m02;
	sh t1, 2(a0)  ; dest->m01 = m01;
	lh t1, 6(a1)  ; m10 = src->m10;
	sh t0, 4(a0)  ; dest->m02 = m02; 
	lh t0, 8(a1)  ; m11 = src->m21;
	sh t1, 6(a0)  ; dest->m10 = m10;
	lh t1, 10(a1) ; m12 = src->m22;
	sh t0, 8(a0)  ; dest->m11 = m11; 
	lh t0, 12(a1) ; m20 = src->m20;
	sh t1, 10(a0) ; dest->m12 = m12;
	lh t1, 14(a1) ; m21 = src->m21;
	sh t0, 12(a0) ; dest->m20 = m20; 
	lh t0, 16(a1) ; m22 = src->m22;
	sh t1, 14(a0) ; dest->m21 = m21;
	sh t0, 16(a0) ; dest->m22 = m22;
	lw t0, 20(a1) ; tx = src->tx;
	lw t1, 24(a1) ; ty = src->ty;
	lw t2, 28(a1) ; tz = src->tz;
	sw t0, 20(a0) ; dest->tx = tx;
	sw t1, 24(a0) ; dest->ty = ty;
	sw t2, 28(a0) ; dest->tz = tz;
	jr ra 
	nop
	
# Function: VS_MultiplyMatrixByVector
# Purpose: Performs matrix by vector multiplication and stores the result in an output vector 
# a0: vec, a1: mat, a2: out 
# out->x = (vec->x * mat->m00 + vec->y * mat->m10 + vec->z * mat->m20) >> 12
# out->y = (vec->x * mat->m01 + vec->y * mat->m11 + vec->z * mat->m21) >> 12
# out->z = (vec->x * mat->m02 + vec->y * mat->m12 + vec->z * mat->m22) >> 12
VS_MultiplyMatrixByVector:
	lw t0, 0(a0)  ; x = vec->x;
	lw t1, 4(a0)  ; y = vec->y;
	lh t3, 0(a1)  ; m00 = mat->m00;
	lw t2, 8(a0)  ; z = vec->z;
	mult t0, t3   ; result_x = x * m00;
	lh t3, 6(a1)  ; m10 = mat->m10;
	mflo a3      
	mult t1, t3   ; result = y * m10;
	mflo t3
	lh t4, 12(a1) ; m20 = mat->m20;
	addu a3, t3   ; result_x += result;
	mult t2, t4   ; result = z * m20;
	mflo t4       
	addu a3, t4   ; result_x += result;
	lh t3, 2(a1)  ; m01 = mat->m01;
	sra a3, 12    ; result_x >>= 12;
	sw a3, 0(a2)  ; out->x = result_x;
	lh t4, 8(a1)  ; m11 = mat->m11;
	mult t0, t3   ; result_y = x * m01;
	mflo a3
	lh t3, 14(a1) ; m21 = mat->m21;
	mult t1, t4   ; result = y * m11;
	mflo t5 
	addu a3, t5   ; result_y += result;
	mult t2, t3   ; result = z * m21;
	mflo t5 
	lh t3, 4(a1)  ; m02 = mat->m02;
	addu a3, t5   ; result_y += result;
	lh t4, 10(a1) ; m12 = mat->m12;
	sra a3, 12    ; result_y >>= 12;
	sw a3, 4(a2)  ; out->y = result_y;
	mult t0, t3   ; result_z = x * m02;
	mflo a3  
	mult t1, t4   ; result = y * m12;
	mflo t5 
	lh t3, 16(a1) ; m22 = mat->m22;
	addu a3, t5   ; result_z += result;
	mult t2, t3   ; result = z * m22;
	mflo t5 
	addu a3, t5   ; result_z += result;
	sra a3, 12    ; result_z >>= 12;
	sw a3, 8(a2)  ; out->z = result_z;
	jr ra 
	nop
	
# Function: VS_MultiplyMatrixByMatrix
# Purpose: Performs matrix by matrix multiplication and stores the result in an output matrix 
# a0: mat1, a1: mat2, a2: out 
VS_MultiplyMatrixByMatrix:
	lh t0, 0(a0)      ; a = mat1->m00;
	lh t1, 2(a0)      ; b = mat1->m01;
	lh t2, 4(a0)      ; c = mat1->m02;
	lh t3, 0(a1)      ; j = mat2->m00;
	lh t4, 6(a1)      ; m = mat2->m10;
	lh t5, 12(a1)     ; p = mat2->m20;
	mult t0, t3       ; result1 = a * j;
	mflo t6 
	mult t1, t4       ; result2 = b * m;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = c * p;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 0(a2)      ; out->m00 = result;
	
	lh t3, 2(a1)      ; k = mat2->m01;
	lh t4, 8(a1)      ; n = mat2->m11;
	lh t5, 14(a1)     ; q = mat2->m21;
	mult t0, t3       ; result1 = a * k;
	mflo t6 
	mult t1, t4       ; result2 = b * n;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = c * q;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 2(a2)      ; out->m01 = result;
	
	lh t3, 4(a1)      ; l = mat2->m02;
	lh t4, 10(a1)     ; o = mat2->m12;
	lh t5, 16(a1)     ; r = mat2->m22;
	mult t0, t3       ; result1 = a * l;
	mflo t6 
	mult t1, t4       ; result2 = b * o;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = c * r;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 4(a2)      ; out->m02 = result;
	
	
	
	
	
	lh t0, 6(a0)      ; d = mat1->m10;
	lh t1, 8(a0)      ; e = mat1->m11;
	lh t2, 10(a0)     ; f = mat1->m12;
	lh t3, 0(a1)      ; j = mat2->m00;
	lh t4, 6(a1)      ; m = mat2->m10;
	lh t5, 12(a1)     ; p = mat2->m20;
	mult t0, t3       ; result1 = d * j;
	mflo t6 
	mult t1, t4       ; result2 = e * m;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = f * p;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 6(a2)      ; out->m10 = result;
	
	lh t3, 2(a1)      ; k = mat2->m01;
	lh t4, 8(a1)      ; n = mat2->m11;
	lh t5, 14(a1)     ; q = mat2->m21;
	mult t0, t3       ; result1 = d * k;
	mflo t6 
	mult t1, t4       ; result2 = e * n;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = f * q;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 8(a2)      ; out->m11 = result;
	
	lh t3, 4(a1)      ; l = mat2->m02;
	lh t4, 10(a1)     ; o = mat2->m12;
	lh t5, 16(a1)     ; r = mat2->m22;
	mult t0, t3       ; result1 = d * l;
	mflo t6 
	mult t1, t4       ; result2 = e * o;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = f * r;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 10(a2)     ; out->m12 = result;
	
	
	
	
	lh t0, 12(a0)     ; g = mat1->m20;
	lh t1, 14(a0)     ; h = mat1->m21;
	lh t2, 16(a0)     ; i = mat1->m22;
	lh t3, 0(a1)      ; j = mat2->m00;
	lh t4, 6(a1)      ; m = mat2->m10;
	lh t5, 12(a1)     ; p = mat2->m20;
	mult t0, t3       ; result1 = g * j;
	mflo t6 
	mult t1, t4       ; result2 = h * m;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = i * p;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 12(a2)     ; out->m20 = result;
	
	lh t3, 2(a1)      ; k = mat2->m01;
	lh t4, 8(a1)      ; n = mat2->m11;
	lh t5, 14(a1)     ; q = mat2->m21;
	mult t0, t3       ; result1 = g * k;
	mflo t6 
	mult t1, t4       ; result2 = h * n;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = i * q;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 14(a2)     ; out->m21 = result;
	
	lh t3, 4(a1)      ; l = mat2->m02;
	lh t4, 10(a1)     ; o = mat2->m12;
	lh t5, 16(a1)     ; r = mat2->m22;
	mult t0, t3       ; result1 = g * l;
	mflo t6 
	mult t1, t4       ; result2 = h * o;
	mflo t7
	add t6, t7        ; result1 += result2;
	mult t2, t5       ; result2 = i * r;
	mflo t7
	add t6, t7        ; result1 += result2;
	sra t6, 12        ; result1 >>= 12;
	sh t6, 16(a2)     ; out->m22 = result;
	
	jr ra 
	nop
	
# Function: VS_RotTransPer3
# Purpose: Performs rotation, translation, and perspective projection transformations onto the 
# three verticies currently in the GTE r0-r5 data registers 
VS_RotTransPer3:
	nop
	nop
	cop2 $0280030    ; gte_cmd = RTPT;
	jr ra
	nop
	
# Function: VS_RotTransPer
# Purpose: Performs rotation, translation, and perspective projection transformations onto the 
# one vertex currently in the GTE r0-r5 data registers 
VS_RotTransPer:
	nop
	nop
	cop2 $0180001   ; gte_cmd = RTPS;
	jr ra
	nop
	
# Function: VS_StoreThreeVectorsFromGTE
# Purpose: Stores the results of the transformed vertices in the MAC1-MAC3 GTE data registers in main memory
# a0: vec4
VS_StoreThreeVectorsFromGTE:
	swc2 r12, 0(a0)  ; vec4->xy1 = gte_xy1;
	swc2 r13, 4(a0)  ; vec4->xy2 = gte_xy2;
	swc2 r14, 8(a0)  ; vec4->xy3 = gte_xy3;
	jr ra 
	nop
	
# Function: VS_StoreOneVectorFromGTE
# Purpose: Stores the results of the transformed vertices in the MAC1 GTE data register in main memory
# a0: vec4
VS_StoreOneVectorFromGTE:
	swc2 r14, 0(a0)  ; vec4->xy1 = gte_xy1;
	jr ra 
	nop
# Function: VS_NClip
# Purpose: Performs back-face culling
VS_NClip:
	nop
	nop
	cop2 $1400006
	jr ra 
	nop
	
# Function: VS_StoreDepth
# Purpose: Get Z depth value 
# a0: depth
VS_StoreDepth:
	swc2 r24, 0(a0)
	jr ra 
	nop