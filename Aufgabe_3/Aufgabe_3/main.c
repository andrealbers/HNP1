#define _CRT_SECURE_NO_WARNINGS 1
#include <stdlib.h>
#include <stdio.h>

void memdump(unsigned char *string, int zeilen) {
	printf("\n%X", &string[0]);
	printf("\n%X", &string[1]);
	printf("\n%X", &string[2]);
}

int main(int argc, char **argv) {    //argc = Anzahl Paramter || argv = Einzelne Parameter || ÜBERGABE DURCH CMD
	
	memdump(argv, argc);

	printf("\n\n");
	system("PAUSE");
}



