#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define string char *

static char encoding_table[] = {
    'A','B','C','D','E','F','G','H',
    'I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X',
    'Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n',
    'o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3',
    '4','5','6','7','8','9','+','/'
};

static string decoding_table = NULL; //On initialise la table de decodage
static int mod_table[] = {0, 2, 1}; //Stock les valeurs de padding à ajouter

void build_decoding_table();
void base64_cleanup();
long size_of_file(FILE *f);
void delete_padding(char *s);
string base64_encode(const unsigned string data, size_t input_length, size_t *output_length);
unsigned string base64_decode(const string data, size_t input_length, size_t *output_length);
string VigenereCipher(string text, string key, int mode);
void cipher_total(string filename, string key);
void decipher_total(string filename, string key);
void findkey_total(string plainname, string cipheredname, string path, int mode);
void cipher(string filename, string key);
void decipher(string filename, string key);
void findkey(string plainname, string cipheredname, string path, int mode);