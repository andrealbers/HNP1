#define _CRT_SECURE_NO_WARNINGS 1
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void memdump(unsigned char* string, int zeilen)   //string = Adresse vom Element z.B. "Hallo" == 0x00c24b86, *string = ASCII-Wert vom Element z.B. 4 == 0x34, &string Adresse vom Element
{
	printf("0x%p", string);
	printf("\t\t\t\t\t\t\t%x\n", *string);





	/*
	printf("\nEs sollen %d Zeilen ausgegeben werden!", zeilen);

	printf("\nDie Startadresse lautet: %p", &string);
	*/
}

int main(int argc, char** argv)                        //argc = Anzahl Zeichenketten (4); argv[1] = 'Hallo'; argv[2] = Ostfriesland!; argv[3] = Anzahl Zeilen
{
	printf("ADDR\t\t00 01 02 03 04 05 06 07 09 0A 0B 0C 0D 0E 0F\t\t0123456789ABCDEF");


	/*ZEILENANZAHL BESTIMMEN AUS PARAMETERÜBERGABE*/
	int zeilenanzahl = 0;

	for (int i = 0; i < argc; i++)
	{
		if (*argv[i] <= '9' && *argv[i] >= '0')
		{
			zeilenanzahl = *argv[i] - 48;
		}
	}
	/*********************************************/


	/*ADRESSE MIT ENDUNG 0 BESTIMMEN*/
	int nullcheck = 0;
	int adressenull;
	char* adresse = argv;

	for (int i = 0; i < 16 && nullcheck == 0; i++)
	{
		adressenull = adresse;
		if ((adressenull & 0xf) != 0)
		{
			adresse++;
		}
		else nullcheck = 1;
	}
	/*********************************************/


	/*WEITERE ADRESSEN TEILBAR DURCH 16 FINDEN*/
	int zeilen[15];
	zeilen[0] = adressenull;

	for (int i = 1; i <= zeilenanzahl; i++)
	{
		zeilen[i] = adressenull + 16;
		adressenull = adressenull + 16;
	}

	/*********************************************/

	for (int i = 0; i <= zeilenanzahl; i++)
	{
		printf("\n0x%X", zeilen[i]);
	}



	/*INHALT ÜBERGABE KOPIEREN UND NUR RELEVANTEN TEXT ÜBERNEHMEN*/
	char* zeichenkette[4];
	/*
	for (int i = 0; i < argc; i++)
	{
		zeichenkette[i] = argv[i + 1];
		if (argv[i + 1] == NULL) break;
		memdump(zeichenkette[i], zeilenanzahl);
	}
	********************************************/








	printf("\n\n");
	system("PAUSE");
}



