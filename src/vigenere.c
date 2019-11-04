#include <stdio.h>
#include "vigenere.h"

int main()
{
    char in[] = "menekuljetek";
    char key[] = "EZAKULCSSZOE";
    char out[255] = {0};

    vigenere_encrypt(in, key, out);

    printf("%s\n", out);
}
