#ifndef __TYPE_H__
#define __TYPE_H__
#include<stdio.h>

typedef unsigned char		u8;
typedef unsigned short      u16;
typedef unsigned int		u32;
typedef unsigned long long	u64;

typedef unsigned char		BOOL;
#define FALSE				0
#define TRUE				1

void SHA1(u8 *plaintext,u32 bytelen, u32 *ciphertext);
#endif

