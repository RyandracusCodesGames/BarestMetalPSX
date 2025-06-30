#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*-----------------------------------------------------------
/ BarestMetalPSX
/ (C) 2025 Ryandracus Chapman
/-----------------------------------------------------------*/

const char* usage = "Copyright (c) 2025 Ryandracus Chapman\n"
"compressor - Compresses an input file stream into an LZSS or RLE compressed destination output file stream\n"
"usage: compressor [input] [compression] [output]\n"
"compression = LZSS or RLE\n";

void VS_WriteByte(FILE* file, unsigned char byte){
	fwrite(&byte,1,1,file);
}

void VS_WriteNBytes(FILE* file,const unsigned char* buffer, unsigned long size){
	fwrite(buffer,1,size,file);
}

void VS_WriteShort(FILE* file, unsigned short hword){
	fwrite(&hword,2,1,file);
}

int VS_Clamp(int min, int val, int max){
	if(val < min){
		return min;
	}
	else if(val > max){
		return max;
	}
	else return val;
}

/*
==================
LZSS
==================
*/
#define	BACK_WINDOW		4095
#define	BACK_BITS		12
#define	FRONT_WINDOW	15
#define	FRONT_BITS		4

unsigned long VS_LZSS(FILE* file, unsigned char* src, unsigned long uncompresssed_size)
{
	int i;
	int val;
	int j, start, max;
	int bestlength, beststart, offset;
	int outbits = 0;
	int pos = uncompresssed_size;
	unsigned char* data = src;
	unsigned char flag, flag_num;
	unsigned long flag_pos, file_pos;
	
	flag = 0;
	flag_num = 0;
	flag_pos = 0;

	for (i=0 ; i<pos ; )
	{
		val = data[i];

		max = FRONT_WINDOW;
		if (i + max > pos)
			max = pos - i;

		start = i - BACK_WINDOW;
		if (start < 0)
			start = 0;
		bestlength = 0;
		beststart = 0;
		for ( ; start < i ; start++)
		{
			if (data[start] != val)
				continue;
			// count match length
			for (j=0 ; j<max ; j++)
				if (data[start+j] != data[i+j])
					break;
			if (j > bestlength)
			{
				bestlength = j;
				beststart = start;
			}
		}
		
		beststart = BACK_WINDOW - (i-beststart);
		
		if(flag_num == 8){
			flag_num = 0;
			file_pos = ftell(file);
			fseek(file,flag_pos,SEEK_SET);
			VS_WriteByte(file,flag);
			fseek(file,file_pos,SEEK_SET);
			flag = 0;
		}
		
		if(flag_num == 0){
			flag_pos = ftell(file);
			VS_WriteByte(file,0);
			outbits += 8;
		}
		
		if (bestlength < 3)
		{	/* output a single char */
			bestlength = 1;

			VS_WriteByte(file,val);
			
			flag |= 1 << (7 - flag_num);
			flag_num++;
			outbits += 8;
		}
		else
		{
			offset = VS_Clamp(0,BACK_WINDOW-beststart,4095);
			VS_WriteShort(file,offset<<4|bestlength);
			
			flag |= 0 << (7 - flag_num);
			flag_num++;
			outbits += 16;
		}

		i += bestlength;
	}
	
	if(flag_num != 0){
		file_pos = ftell(file);
		fseek(file,flag_pos,SEEK_SET);
		VS_WriteByte(file,flag);
		fseek(file,file_pos,SEEK_SET);
	}
	
	return outbits / 8.0f;
}

unsigned long VS_RLE(FILE* file, const unsigned char* src, unsigned long uncompressed_size){
	unsigned long i, j, out_size = 0, run_len, non_rept;
	for(i = 0; i < uncompressed_size; i++){
		unsigned char byte = src[i];
		run_len = 1;
		
		for(j = i + 1; j < uncompressed_size && run_len < 127; j++){
			if(byte != src[j]){
				break;
			}
			
			run_len++;
		}
		
		if(run_len >= 3){
			i += run_len - 1;
			
			VS_WriteByte(file,run_len|0x80);
			VS_WriteByte(file,byte);
			
			out_size += 2;
		}
		else{
			non_rept = 1;

			for(j = i + run_len; (j+1) < uncompressed_size && non_rept < 127; j++){
				if((src[j-1] == src[j]) && (src[j] == src[j+1])){
					break;
				}
				
				non_rept++;
			}
			
			VS_WriteByte(file,non_rept);
			VS_WriteNBytes(file,src+i,non_rept);
			
			out_size += 1 + non_rept;
			i += non_rept - 1;
		}
	}
	
	return out_size;
}

int main(int argc, char** argv){
	FILE* in, *out;
	unsigned long size, outsize;
	
	if(argc != 4){
		printf("%s\n",usage);
		return -1;
	}
	
	in = fopen(argv[1],"rb");
	
	if(in == NULL){
		printf("Input file not found - %s!\n",argv[1]);
		return -1;
	}
	
	fseek(in,0,SEEK_END);
	size = ftell(in);
	fseek(in,0,SEEK_SET);
	
	unsigned char* src = malloc(size);

	fread(src,1,size,in);

	out = fopen(argv[3],"wb");
	
	if(!strcmp(argv[2],"RLE")){
		outsize = VS_RLE(out,src,size);
	}
	else{
		outsize = VS_LZSS(out,src,size);
	}
	
	printf("Uncompressed size = %ld\n",size);
	printf("Compressed size = %ld\n",outsize);
	
	free(src);
	fclose(in);
	fclose(out);
	
	return 0;
}