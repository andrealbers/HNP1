/*	Hardwarenahe Programmierung	
	Aufgabe 5
	Assembler+C
	Claas-Focke Schmidt & Andre Albers
	Letzte Änderung: 27.05.19 12:30 Uhr
*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

extern int _stat(int, int, char, int *a);

int addsub(int op1, int op2, char what, int* flags)
{
	int binary[12];

	/*          CALC              */
	int ergebnis = _stat((short)op1, (short)op2, what, flags);
	
	/*          OUT FLAG          */	
	printf("\nFlag-Register Wert: %d\n\n", *flags);
	printf("Flags:\nO D I T S Z x A x P x C\n");

	for (int i = 11; i >= 0; i--)
	{
		binary[i] = *flags % 2;
		*flags = *flags / 2;
	}
	for (int j = 0; j <= 11; j++)
	{
		printf("%d ", binary[j]);
	}
	
	/*          FLAGS PRUEFEN     */
	bool overflowflag = binary[0];
	bool carryflag = binary[11];


	/*          OUT SIGNED        */
	printf("\n\nErgebnis und Operanden Signed:");
	printf("\n%i %c %i = %i (Das Ergebnis ist: ", (short)op1, what, (short)op2, (short)ergebnis);
	if(overflowflag == true) printf("falsch.)\n");
	else printf("richtig.)\n");

	/*          OUT UNSIGNED      */
	printf("\n\nErgebnis und Operanden Unsigned:");
	printf("\n%d %c %d = %d (Das Ergebnis ist: ", (unsigned short)op1, what, (unsigned short)op2, (unsigned short)ergebnis);
	if(carryflag == true) printf("falsch.)\n");
	else printf("richtig.)\n");
	
	return 1;
}

void fehlermeldungen(int fehlerid)
{
	switch (fehlerid)
	{
	case -1:
		printf("Es wurden nicht 3 Parameter übergeben!\n");
		break;
	}
}

int main(int argc, char** argv)
{	
	int anzarg = argc, pointerflag, zahl1 = atoi(argv[1]), zahl2 = atoi(argv[3]);
	char operation = *argv[2];
	
	if (anzarg != 4)
	{
		fehlermeldungen(-1);
		return -1;
	}
	
	addsub(zahl1, zahl2, operation, &pointerflag);

	printf("\n\n");
	return 0;
}


/*
	int temp = *flags;
	
	printf("\n");
	for(int i = 0; i<12;i++)
	{
		printf("%c ", (temp & 0x800) ? '1' : '0');
		temp = temp <<1;
	}


	printf("\n");
 	temp = *flags;
	for(int i = 0; i<12;i++)
	{
		if(temp & 0x800)
		{
			printf("1 ");
		}
		else printf("0 ");
		temp = temp <<1;
	}
*/

