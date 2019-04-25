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
	printf("ADDR\t\t00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\t\t0123456789ABCDEF\n");

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
	/*
	long long int adressvalue = *argv;
	char* adress = adressvalue;
	int i;
	printf("\n%x\n", *argv);
	printf("\n%p\n", *argv);
	//Adresse 1 über Modulo
	do
	{
		adressvalue--;
		printf("\n%x", adressvalue);
	} while (adressvalue % 16 != 0);

	*/
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

	/*WEITERE ADRESSEN TEILBAR DURCH 16*/
	int zeilen[15];
	zeilen[0] = adressenull;

	for (int i = 1; i < zeilenanzahl; i++, adressenull = adressenull + 16)
	{
		zeilen[i] = adressenull + 16;
	}

	/*********************************************/

	for (int i = 0; i < zeilenanzahl; i++)
	{
		printf("\n0x%X", zeilen[i]);   //ADRESSE SCHREIBEN
		printf("\t");

		int startadresse = zeilen[i];
		unsigned char* wertadresse = startadresse;
		for (int k = 0; k < 16; k++)
		{
			unsigned char* wertadresse = startadresse;
			printf("%02X ", *wertadresse);
			startadresse++;
		}

		printf("\t");
		startadresse = zeilen[i];
		for (int j = 0; j < 16; j++)
		{
			unsigned char* wertadresse = startadresse;
			if (*wertadresse == '\0')
			{
				printf(".");
			}
			else
			{
				printf("%c", *wertadresse);
			}
			startadresse++;

		}

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



