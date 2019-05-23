#define _CRT_SECURE_NO_WARNINGS 1
#include <stdlib.h>
#include <stdio.h>



int addsub(int op1, int op2, char what, unsigned int* flags)
{
	printf("Flags:\nO D I T S Z  A  P  C");


	printf("\n%d", op1);
	printf("\n%c", what);
	printf("\n%d", op2);

}

void fehlermeldungen(int fehlerid)
{
	switch (fehlerid)
	{
	case -1:
		printf("Anzahl uebergebener Parameter ungueltig!");
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
	//int operation = (int)* argv[2];   //43 == Plus; 45 == Minus;
	char operation = *argv[2];
	int zahl2 = atoi(argv[3]);

	if (anzarg > 4)
	{
		fehlermeldungen(-1);
		return -1;
	}

	addsub(zahl1, zahl2, operation, 3);

	printf("\n\n");
	return 0;
}






