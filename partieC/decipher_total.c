#include "chiffrement.h"

int main(int argc, char *argv[]) {
    if (argc < 3) {
        printf("Usage : %s <cle> <fichier>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    string key = argv[1];
    string file = argv[2];

    decipher_total(file, key);
    base64_cleanup();
}