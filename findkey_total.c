#include "chiffrement.h"

int main(int argc, char *argv[]) {
    if (argc == 5) {
        if (strcmp(argv[3], "-o") == 0){
            string plain_file = argv[1];
            string ciphered_file = argv[2];
            string path = argv[4];
            findkey_total(plain_file, ciphered_file, path, 1);
        } else {
            printf("Usage : %s <fichier propre> <fichier chiffré> (facultatif : -o <chemin>)\n", argv[0]);
            exit(EXIT_FAILURE);
        }
    } else if (argc == 3){
        string plain_file = argv[1];
        string ciphered_file = argv[2];
        findkey_total(plain_file, ciphered_file, "", 0);
    } else {
        printf("Usage : %s <fichier propre> <fichier chiffré> (faculatatif : -o <chemin>)\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    
    base64_cleanup();
}