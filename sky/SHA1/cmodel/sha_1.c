#include<stdio.h>
#include "./sha-1.h"
//#define ROL(data,len) ((data << len) | (data >> (32-len)))

///*全局变量，存放每组哈希后的值*/
static const u32 A1 = 0x67452301;
static const u32 B1 = 0xEFCDAB89;
static const u32 C1 = 0x98BADCFE;
static const u32 D1 = 0x10325476;
static const u32 E1 = 0xC3D2E1F0;

static const u32 K[4] = {0x5A827999,0x6ED9EBA1,0x8F1BBCDC,0xCA62C1D6};
//全局变量，存放每组哈希后的值
u32 H[5];
 
FILE *w_log, *h_log;
FILE *din_fp, *dout_fp;


static u32 ROL(u32 data,u8 len)
{
	u32 l,r;
	l = data<<len;
	r = data>>(32-len);
	return (l|r);
}

static void word2byte (u32 word,u8 *byte){
	u8 i;
	for ( i = 0; i < 4; i++)
	{
		byte[i] = (u8)(word>>(8*(3-i))) &0xff;
	}
	
}



static void Byte2Word(u8 *data, u32 *word,u8 len){
	u8 i;
	for ( i = 0; i < len; i = i+4)
	{
		*(word+i/4) = ((*(data+i) << 24) | (*(data+i+1)<<16) |(*(data+i+2)<<8) |*(data+i+3)) & 0xffffffff;
	}	
}
static void Gen_W(u8 *data, u32 *W) {
	u8 i;
	u32 temp;
	Byte2Word(data,W,64);
	for ( i = 16; i < 80; i++)
	{
		temp = W[i-3]^W[i-8]^W[i-14]^W[i-16];
		W[i] =  ROL(temp,1);
	}
	//log file
	for (i = 0; i < 80; i++)
	{
		fprintf(w_log, "%08x\n",W[i]);
	}
	
	
}


void Sha1Process(u8 *data) {
	u32 W[80];//存放80个子明文
	u32 A,B,C,D,E;//ABCDE
	u8 i;
	u32 temp;
	A = A1;B = B1;C = C1;D = D1;E = E1;
	Gen_W(data,W);
	fwrite(data, sizeof(char), 64, din_fp);
	/*for(i=0;i<80;i++)	{ 		
		printf("%02x ",W[i]);
		if (i == 79)
		{
			printf("\n");
		}
	}*/
	//printf("A : %02x %02x %02x %02x %02x \n" ,A,B,C,D,E);
	for ( i = 0; i < 80; i++)
	{
		switch (i/20)
		{
		case 0 :
			temp = (B&C)|((~B)&D);
			temp += K[0];
			break;
		case 1 :  
                temp = (B^C^D);
				temp += K[1];
                break;
        case 2: 
                temp = ((B&C)|(B&D)|(C&D));
				temp += K[2];
                break;
        case 3: 
                temp = (B^C^D);
				temp += K[3];
                break;	
		}
		//printf("temp1:%02x \n",temp);
		temp = temp + W[i] + E + ROL(A,5);
		E = D; 
		D = C; 
		C = ROL(B,30); 
		B = A; 
		A = temp;
		fprintf(h_log, "%08x %08x %08x %08x %08x\n", A,B,C,D,E);
		if (i == 79)
		{
			fprintf(h_log, "\n");
		}
		
	//	printf("%d %02x %02x %02x %02x %02x \n" ,i,A,B,C,D,E);
	}

//	A += A;
//	A += B;
//	A += C;
//	A += D;
//	A += E; 

	H[0] = A + A1;
	H[1] = B + B1;
	H[2] = C + C1;
	H[3] = D + D1;
	H[4] = E + E1;
	//printf("%02x %02x %02x %02x %02x \n" ,A,B,C,D,E);
}

void SHA1(u8 *plaintext,u32 bytelen,u32 *hashtext){
	u8 i = 0;
	u8 data[64] = {0};//block 64byte
	u32 bitlen [2] = {0};
	u32 W[16] = {0};
	//fwrite(data, sizeof(char), 64, fp_din);

	while(bytelen >= 64) {
		for ( i = 0; i < 64; i++) {
			data[i] = *plaintext;
			plaintext++;
		}
		bytelen = bytelen - 64;
		if (bitlen == 0xfffffe00) {   //??
			bitlen[1] += 1;
			bitlen[0] = 0;
		}else {
			bitlen[0] += 512;
		}
		Sha1Process(data);
	}

	bitlen[0] = bitlen[0] + 8*bytelen;
	for ( i = 0; i < bytelen; i++) {
		data[i] = *plaintext++;
	}

	data[bytelen++] = 0x80;

	if (bytelen == 56) {
		word2byte(bitlen[1],&data[56]);
		word2byte(bitlen[0],&data[60]);
		Sha1Process(data);
	} else if (bytelen >56) {
		for ( i = bytelen; i < 64; i++) {
			data[i] = 0x00;
		}
		Sha1Process(data);
		for ( i = 0; i < 56; i++) {
			data[i] = 0x00;
		}
		word2byte(bitlen[1],&data[56]);
		word2byte(bitlen[0],&data[60]);
		Sha1Process(data);		
	} else if (bytelen < 56) {
		for ( i = bytelen; i < 56; i++) {
			data[i] = 0x00;
		}
		word2byte(bitlen[1],&data[56]);
		word2byte(bitlen[0],&data[60]);
		Sha1Process(data);
		//for(i=0;i<64;i++)	 		
		//printf("%02x ",data[i]);
		

	}
	/*u8 *hashtext_temp[20];	
	word2byte(H[0],hashtext_temp);
	word2byte(H[1],hashtext_temp+4);
	word2byte(H[2],hashtext_temp+8);
	word2byte(H[3],hashtext_temp+12);
	word2byte(H[4],hashtext_temp+16);
	printf("output hash value : \n");*/
	//printf("%lx%lx%lx%lx%lx\n",H[0],H[1],H[2],H[3],H[4]);
	hashtext[0] = H[0];
	hashtext[1] = H[1];
	hashtext[2] = H[2];
	hashtext[3] = H[3];
	hashtext[4] = H[4];
	printf("\n");
	for(i=0;i<5;i++)	 		
		printf("%02x ",hashtext[i]); 	
	printf("\r\n\r\n");
}

void info_log(FILE *fp_din,FILE *fp_dout, unsigned char *SHA1_plaintext2, unsigned int *res) {
	int i;
	fwrite(SHA1_plaintext2, sizeof(char), 64, fp_din);
	fwrite(res, sizeof(int), 5, fp_dout);
}

int main() {
	//u8 i;
	////u8 SHA1_plaintext[]="absaaaaaaaaaabababbbbbbbabaaaaahshhsssksksllsklkskslslkslkslkslksllspllll";//明文 	
	u8 hashtext[20]={0};
	//printf("%d\n",sizeof(SHA1_plaintext)-1);
	u8 SHA1_plaintext0[]= "abc";
	u8 SHA1_plaintext1[]= "a";
	u8 SHA1_plaintext2[]= "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnop";
	u8 SHA1_plaintext3[]= "01234567012345670123456701234567";

	u8 test[64];
	//u8 *SHA1_plaintext2;
	u32 res1[5],res2[5],res3[5],res4[5];

	u8 *input;
	u8  tmp;

	int i,len,cnt;
	
	dout_fp = fopen("./sha_1/sha_out.bin", "wb");
	din_fp = fopen("./sha_1/sha_in.bin", "wb");

	w_log = fopen("./sha_1/w.log","w");
	h_log = fopen("./sha_1/h.log","w");

	printf("begin SHA-1 calculation:\n");

	//input = SHA1_plaintext0;
    SHA1(SHA1_plaintext0,sizeof(SHA1_plaintext0)-1, res1);
	for(i=0;i<5;i++)	 		
		printf("%02x ",res1[i]); 	
	printf("\r\n\r\n");
    //info_log(din_fp, dout_fp, SHA1_plaintext0, res1);
	fwrite(res1, sizeof(int), 5,dout_fp );
   
    
    SHA1(SHA1_plaintext1,sizeof(SHA1_plaintext1)-1, res2);
	//printf("%d\n",sizeof(SHA1_plaintext1)-1);
	for(i=0;i<5;i++)	 		
		printf("%02x ",res2[i]); 	
	printf("\r\n\r\n");
    //info_log(din_fp, dout_fp, SHA1_plaintext1, res2);
   fwrite(res2, sizeof(int), 5, dout_fp);
    
    SHA1(SHA1_plaintext2,sizeof(SHA1_plaintext2)-1, res3);
	for(i=0;i<5;i++)	 		
		printf("%02x ",res3[i]); 	
	printf("\r\n\r\n");
    //info_log(din_fp, dout_fp, SHA1_plaintext2, res3);
    fwrite(res3, sizeof(int), 5, dout_fp);
    
    SHA1(SHA1_plaintext3,sizeof(SHA1_plaintext3)-1, res4);
	for(i=0;i<5;i++)	 		
		printf("%02x ",res4[i]); 	
	printf("\r\n\r\n");
    //info_log(din_fp, dout_fp, SHA1_plaintext3, res4);
	fwrite(res4, sizeof(int), 5,dout_fp);

/*
	//2: random test
	//u32 res[5];
	int k = 0;
	u32 res[5] = {0};
    for(cnt=0; cnt<1; cnt++) {
		
		k=k+1;
		printf("%d\t",k);
        len = rand() % 56;
        if(len == 0) len = 1;
        
        //initial test with random data
        for(i=0; i<len; i++) {
            tmp = rand() % 256;
            if(tmp == 0)  tmp = 1;

            test[i] = tmp;
        }


        for(i= len; i<64; i++)
            test[i] = 0x00;
		printf("plaintext:"); 	
		for(i=0;i<sizeof(test);i++)	 	
		{ 		
			//if(i%16 == 0) 			
			//	printf("\r\n"); 		
			printf("%02x",test[i]); 		 	
		} 
		//printf("%x\n",test);

        //SHA1_plaintext2 = test;
		//printf("%02x",test)
		
        SHA1(test,sizeof(test)-1, res);
        info_log(din_fp, dout_fp, test, res);
    } 
//*/
	fclose(din_fp);
    fclose(dout_fp);
    fclose(w_log);
    fclose(h_log);

	printf("SHA-1 calculation end:\n");
    //getch();
	//return 0;

	/***************************** SHA1 *************************************/ 	
/*	printf("***************************** SHA1 ********************************\r\n"); 	
	SHA1(SHA1_plaintext0,sizeof(SHA1_plaintext0)-1, res);
	 	
	printf("plaintext:"); 	
	for(i=0;i<sizeof(SHA1_plaintext0)-1;i++)	 	
	{ 		
		if(i%16 == 0) 			
			printf("\r\n"); 		
		printf("%02x ",SHA1_plaintext0[i]); 		 

	} 	
	printf("\r\n"); 	
	printf("ciphertext:\r\n"); 	
	for(i=0;i<5;i++)	 		
		printf("%02x ",res[i]); 	
	printf("\r\n\r\n");*/

	system("pause"); 	
	return 0; 
}
