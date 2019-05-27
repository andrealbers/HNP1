#define _CRT_SECURE_NO_WARNINGS 1
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//extern int _stat(int);
		extern int _stat(int, int,char, int *a);
double op1, op2;


int addsub(double op1, double op2, char what, unsigned int* flags)
{
	printf("Flags:\nO D I T S Z x A x P x C");

}
void fehlermeldungen(int fehlerid)
{
	switch (fehlerid)
	{
	case -1:
		printf("Es wurden nicht 3 Parameter übergeben!");
		break;
	default:
		printf("Unbekannter Fehler!");
		break;
	}
}

int main(int argc, char** argv)
{
	int anzarg = argc;
	int zahl1 = atoi(argv[1]);
	char operation = *argv[2];
	int zahl2 = atoi(argv[3]);

	int a = 4096, b=1111111111111110, c=0; 

	printf("\n %d", zahl1); 
	printf("\n %c", '+');
	printf("\n %x", b); 

	a= _stat(a, b,'+', &c);

	printf("\n\n %x", a); 
	printf("\n %d \n", c);
	
	int binary[32];
	
	for(int i = 0; i <= 32; i++)
	{
	 binary[31-i] = c % 2;	
	 c = c / 2;
	printf("%d", binary[31-i]);
	}
			

	
	if (anzarg != 4)
	{
		fehlermeldungen(-1);
		return -1;
	}

	//extern _addsub(zahl1, zahl2, operation, 3);

	printf("\n\n");
*/
	printf("\n\n");
	return 0;
}






