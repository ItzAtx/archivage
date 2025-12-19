#include "chiffrement.h"

//Cette fonction crée une table de correspondance inverse à encoding_table
void build_decoding_table() {
    decoding_table = malloc(256);
    for (int i = 0; i < 64; i++)
        decoding_table[(unsigned char)encoding_table[i]] = i; //On place la valeur numérique i (valeur Base64) à l’indice correspondant au code ASCII du caractère encoding_table[i].
        //Exemple : si encoding_table[0] == 'A' (ASCII 65), alors decoding_table[65] = 0
}

//Supprime la table de décodage
void base64_cleanup() {
    free(decoding_table);
}

//Retourne le nombre de caractères/octets contenus dans le fichier
long size_of_file(FILE *f) {
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);
    return size;
}

//Enlève les paddings de la clé
void delete_padding(string s) {
    int w = 0;
    for (int i = 0; s[i] != '\0'; i++) {
        if (s[i] != '=') {
            s[w++] = s[i];
        }
    }
    s[w] = '\0';
}

/*
Paramètres :
data : pointeur vers les données à encoder
input_length : taille des données d'entrée en octets
output_length : pointeur vers une variable où sera stockée la taille du texteb64 produit

Renvoie un pointeur vers la chaîne encodé ou NULL si l'allocation a échouée

Cette fonction lit un tableau d'octets et le convertit en une chaîne Base64
*/
string base64_encode(const unsigned string data, size_t input_length, size_t *output_length) {
    //3 octets d’entrée -> 4 symboles Base64 en sortie (4 octets)
    //+2 pour arrondir vers le haut et gérer les blocs incomplets (reste 1 ou 2 octets)
    *output_length = 4 * ((input_length + 2) / 3);

    //(+1 pour le caractère nul de fin)
    string encoded_data = malloc(*output_length + 1);
    if (encoded_data == NULL) return NULL;

    // --------- BOUCLE PRINCIPALE ---------
    for (size_t i = 0, j = 0; i < input_length;) {
        //On lit jusqu’à 3 octets dans data, si on est à la fin, les manquants sont mis à 0.
        uint32_t octet_a = 0;
        uint32_t octet_b = 0;
        uint32_t octet_c = 0;

        if (i < input_length) octet_a = (unsigned char)data[i++];
        if (i < input_length) octet_b = (unsigned char)data[i++];
        if (i < input_length) octet_c = (unsigned char)data[i++];

        //On assemble les 3 octets en un bloc 24 bits
        uint32_t triple = (octet_a << 16) + (octet_b << 8) + octet_c;

        //On extrait les 4 groupes de 6 bits (On décale les sixtets un par un puis on applique un masque pour ne récupérer que les 6 derniers bits)
        encoded_data[j++] = encoding_table[(triple >> 18) & 0x3F];
        encoded_data[j++] = encoding_table[(triple >> 12) & 0x3F];
        encoded_data[j++] = encoding_table[(triple >> 6)  & 0x3F];
        encoded_data[j++] = encoding_table[(triple >> 0)  & 0x3F];
    }

    //On ajoute du padding '=' si la taille d’entrée n’était pas multiple de 3 :
    for (int i = 0; i < mod_table[input_length % 3]; i++)
        encoded_data[*output_length - 1 - i] = '=';

    encoded_data[*output_length] = '\0';

    return encoded_data;
}

/*
Paramètres :
data : pointeur vers la chaîne Base64 à décoder
input_length : taille des données d'entrée en octets
output_length : pointeur vers une variable où sera stockée la taille des données décodées

Renvoie un pointeur vers les données décodées ou NULL si les données sont invalides ou que l'allocation mémoire échoue

Cette fonction décode des données encodées en Base64
*/
unsigned string base64_decode(const string data, size_t input_length, size_t *output_length) {
    if (decoding_table == NULL) build_decoding_table();
    if (input_length % 4 != 0) return NULL; //On vérifie que la longueur d'entrée est bien un multiple de 4 (sinon ce n'est pas du b64 valide et donc on arrête)

    *output_length = input_length / 4 * 3; //4 symboles b64 = 3 caractères (octets) décodés

    //On retire 1 ou 2 octets de la taille finale selon s'il y a du padding
    if (data[input_length - 1] == '=') (*output_length)--;
    if (data[input_length - 2] == '=') (*output_length)--;

    unsigned string decoded_data = malloc(*output_length + 1);
    if (decoded_data == NULL) return NULL;

    // --------- BOUCLE PRINCIPALE ---------
    for (size_t i = 0, j = 0; i < input_length;) {
        //On lit les 4 symboles Base64, si un caractère vaut '=', on lui laisse la valeur 0 (car il ne représente aucun bit utile), sinon, on lit son index dans encode_table

        uint32_t sextet_a = 0;
        uint32_t sextet_b = 0;
        uint32_t sextet_c = 0;
        uint32_t sextet_d = 0;

        if (data[i] != '=') {
            sextet_a = decoding_table[(unsigned char)data[i]];
        }
        i++;

        if (data[i] != '=') {
            sextet_b = decoding_table[(unsigned char)data[i]];
        }
        i++;

        if (data[i] != '=') {
            sextet_c = decoding_table[(unsigned char)data[i]];
        }
        i++;

        if (data[i] != '=') {
            sextet_d = decoding_table[(unsigned char)data[i]];
        }
        i++;

        uint32_t triple = (sextet_a << 18) + (sextet_b << 12) + (sextet_c << 6) + sextet_d; //On aligne tous les sixtets en les décalants

        //On extrait les 3 groupes de 8 bits (On décale les octets un par un puis on applique un masque pour ne récupérer que les 8 derniers bits)
        if (j < *output_length) decoded_data[j++] = (triple >> 16) & 0xFF;
        if (j < *output_length) decoded_data[j++] = (triple >> 8) & 0xFF;
        if (j < *output_length) decoded_data[j++] = triple & 0xFF;
    }

    decoded_data[*output_length] = '\0';
    return decoded_data;
}

/*
Paramètres :
text : texte (en b64) à chiffrer ou déchiffrer
key : la clé qui permet de chiffrer (en b64 et sans les paddings) 
mode : 0 pour chiffrer, 1 pour déchiffrer

Renvoie un pointeur vers le texte transformé ou NULL si l'allocation échoue

Cette fonction applique le chiffrement de Vigenère sur l’alphabet Base64
*/
string VigenereCipher(string text, string key, int mode) {
    int n = strlen(text);
    int key_len = strlen(key);
    string res = malloc(n + 1);
    if (!res) return NULL;

    //i parcourt les caractères du texte, j ceux de la clé (et recommence une fois terminé)
    for (int i = 0, j = 0; i < n; i++) {
        char c = text[i];
        char k = key[j % key_len]; //j % key_len permet à la clé de boucler

        if (c == '=') { res[i] = c; continue; } //On laisse les paddings tel quel

        int posC = strchr(encoding_table, c) - encoding_table; //On calcule l'indice du caractère c dans la table (on calcule la position en soustrayant les adresses mémoires)
        int posK = strchr(encoding_table, k) - encoding_table; //Idem
        if (posC < 0 || posK < 0) { res[i] = c; continue; } //Si c n'appartient pas à l'alphabet b64 alors on le recopie tel quel

        if (mode)
            //déchiffrement : on soustrait la clé (avec +64 pour éviter un indice négatif au cas où si le caractère du texte est avant le caractère de la clé)
            res[i] = encoding_table[(posC - posK + 64) % 64];
        else
            //chiffrement : on additionne les indices (mod 64 pour boucler)
            res[i] = encoding_table[(posC + posK) % 64];
        j++;
    }

    res[n] = '\0';
    return res;
}

/* ----- Cipher_total : Encode base64 -> Vigenere -> Decode base64 ----- */
void cipher_total(string filename, string key) {
    FILE *f = fopen(filename, "rb");
    if (!f) { perror("fopen"); exit(EXIT_FAILURE); }

    long file_size = size_of_file(f);   

    //Lire tout le fichier en mémoire
    unsigned string data = malloc(file_size);
    fread(data, 1, file_size, f);
    fclose(f);

    // Encodage Base64 de tout le fichier
    size_t b64_len;
    string b64 = base64_encode(data, file_size, &b64_len);
    free(data);

    // Clé en Base64
    size_t key_b64_len;
    string encoded_key = base64_encode(key, strlen(key), &key_b64_len);
    delete_padding(encoded_key);

    // Vigenère sur le Base64 complet
    string vigenere = VigenereCipher(b64, encoded_key, 0);
    free(b64);
    free(encoded_key);

    // Décodage Base64
    size_t out_len;
    unsigned string decoded = base64_decode(vigenere, strlen(vigenere), &out_len);
    free(vigenere);

    // Écriture du fichier chiffré
    FILE *out = fopen(filename, "wb");
    fwrite(decoded, 1, out_len, out);
    fclose(out);
    free(decoded);
}

/* ----- Decipher_total : Encode base64 -> Vigenere inverse -> Decode base64 ----- */
void decipher_total(string filename, string key) {
    FILE *f = fopen(filename, "rb");
    if (!f) { perror("fopen"); exit(EXIT_FAILURE); }

    long file_size = size_of_file(f); 
    
    unsigned string data = malloc(file_size);
    fread(data, 1, file_size, f);
    fclose(f);

    // Encodage Base64
    size_t encoded_len;
    string encoded = base64_encode(data, file_size, &encoded_len);
    free(data);

    // Clé en Base64
    size_t key_b64_len;
    string encoded_key = base64_encode(key, strlen(key), &key_b64_len);
    delete_padding(encoded_key);
    

    // Dé-Vigenère
    string unvigenere = VigenereCipher(encoded, encoded_key, 1);
    free(encoded);
    free(encoded_key);

    // Décodage Base64
    size_t out_len;
    unsigned string decoded = base64_decode(unvigenere, strlen(unvigenere), &out_len);
    free(unvigenere);

    // Écriture du fichier déchiffré
    FILE *out = fopen(filename, "wb");
    fwrite(decoded, 1, out_len, out);
    fclose(out);
    free(decoded);
}

/* ----- Cipher : fichier en base64 -> Vigenere  ----- */
void cipher(string filename, string key) {
    FILE *f = fopen(filename, "rb");
    if (!f) { perror("fopen"); exit(EXIT_FAILURE); }

    string key_copy = malloc(strlen(key)+1);
    strcpy(key_copy, key);
    delete_padding(key_copy);

    long file_size = size_of_file(f);

    //Lire tout le fichier en mémoire
    unsigned string data = malloc(file_size);
    fread(data, 1, file_size, f);
    fclose(f);

    //Vigenère sur le Base64 complet
    string vigenere = VigenereCipher(data, key_copy, 0);
    size_t out_len = file_size;

    //Écriture du fichier chiffré
    FILE *out = fopen(filename, "wb");
    fwrite(vigenere, 1, out_len, out);
    fclose(out);

    free(vigenere);
    free(data);
    free(key_copy);
}

/* ----- Cipher : fichier décodé en base64 -> Vigenere  ----- */
void decipher(string filename, string key) {
    FILE *f = fopen(filename, "rb");
    if (!f) { perror("fopen"); exit(EXIT_FAILURE); }

    string key_copy = malloc(strlen(key)+1);
    strcpy(key_copy, key);
    delete_padding(key_copy);

    long file_size = size_of_file(f);   

    //Lire tout le fichier en mémoire
    unsigned string data = malloc(file_size);
    fread(data, 1, file_size, f);
    fclose(f);


    //Vigenère sur le Base64 complet
    string vigenere = VigenereCipher(data, key_copy, 1);
    size_t out_len = file_size;

    //Écriture du fichier chiffré
    FILE *out = fopen(filename, "wb");
    fwrite(vigenere, 1, out_len, out);
    fclose(out);

    free(vigenere);
    free(data);
    free(key_copy);
}

/*
Paramètres :
plain_name : chemin vers le fichier en clair (en b64; après l'avoir encodé)
ciphered_name : chemin vers le fichier chiffré (en b64; après l'avoir encodé)

Renvoie la clé de chiffrement utilisée sur stdout et sa taille sur stderr

Cette fonction détermine la clé qui a été utilisée pour transformer plain_name en ciphered_name
*/
void findkey(string plain_name, string ciphered_name, string path, int mode){
    FILE *plain = fopen(plain_name, "rb");
    FILE *ciphered = fopen(ciphered_name, "rb");

    //Calcul de la taille des fichier
    long plain_size = size_of_file(plain); 
    long ciphered_size = size_of_file(ciphered); 

    //Allocation et lecture des données
    unsigned string plain_data = malloc(plain_size);
    fread(plain_data, 1, plain_size, plain);
    fclose(plain);

    unsigned string ciphered_data = malloc(ciphered_size);
    fread(ciphered_data, 1, ciphered_size, ciphered);
    fclose(ciphered);

    //Si ils ne font pas la même tailles, cela signifie que ce ne sont pas les mêmes fichiers
    if (plain_size != ciphered_size){
        printf("ERREUR : Les deux fichiers ne sont pas de la même taille, ils ne correspondent pas\n");
        exit(EXIT_FAILURE);
    }

    //Allocation de l'espace pour la clé répétée
    string repeted_key = malloc(plain_size + 1);
    repeted_key[plain_size] = '\0';


    for (int i = 0; i < plain_size; i++){
        //Pour chaque caractère des données, on cherche sa position dans la table d'encodage
        int pos_plain = strchr(encoding_table, plain_data[i]) - encoding_table;
        int pos_ciphered = strchr(encoding_table, ciphered_data[i]) - encoding_table;
        //On recalcule le décalage de Vigenère (la clé)
        int k = (pos_ciphered - pos_plain + 64) % 64; //(contraire de celui fait dans Vigenère)
        repeted_key[i] = encoding_table[k];
    }

    //On essaye de trouver une répétition
    int key_len = 0;
    for (int L = 1; L <= plain_size; L++){ //Tant qu'on a pas trouvé une longueur, on test avec une plus grande
        int ok = 1;

        for (int i = 0; i < plain_size - 4; i++){ //-4 pour éviter les 4 derniers caractères qui peuvent être affectés par le padding
            if (repeted_key[i] != repeted_key[i % L]){    //Si pour tout i : repeted_key[i] == repeted_key[i % L], alors la séquence se répète tous les L caractères (Donc la clé = les L premiers caractères)
                ok = 0;
                break;
            }
        }

        if (ok){
            key_len = L;
            break;
        }
    }

    //On stock la clé
    string key_b64 = malloc(key_len + 1);
    for (int i = 0; i < key_len; i++){
        key_b64[i] = repeted_key[i];
    }
    key_b64[key_len] = '\0';

    //On rajoute des paddings si besoin pour que la taille de la clé soit un multiple de 4
    int padded_len = key_len;
    while (padded_len % 4 != 0) padded_len++;

    string key_b64_padded = malloc(padded_len + 1);
    strcpy(key_b64_padded, key_b64);

    for (int i = key_len; i < padded_len; i++){
        key_b64_padded[i] = '=';
    }
    key_b64_padded[padded_len] = '\0';

    if (!mode){
        printf("%s\n", key_b64_padded);
    } else {
        FILE *f = fopen(path, "w");
        fprintf(f, "%s\n", key_b64_padded);
    }
    fprintf(stderr, "%d\n", key_len);

    free(plain_data);
    free(ciphered_data);
    free(repeted_key);
    free(key_b64);
    free(key_b64_padded);
}

/*
Paramètres :
plain_name : chemin vers le fichier en clair
ciphered_name : chemin vers le fichier chiffré

Renvoie la clé de chiffrement utilisée sur stdout et sa taille sur stderr

Cette fonction détermine la clé qui a été utilisée pour transformer plain_name en ciphered_name
*/
void findkey_total(string plain_name, string ciphered_name, string path, int mode){
    FILE *plain = fopen(plain_name, "rb");
    FILE *ciphered = fopen(ciphered_name, "rb");

    size_t plain_output_size;
    size_t ciphered_output_size;

    //Calcul de la taille des fichier
    long plain_size = size_of_file(plain); 
    long ciphered_size = size_of_file(ciphered); 

    //Allocation et lecture des données
    unsigned string plain_data = malloc(plain_size);
    fread(plain_data, 1, plain_size, plain);
    fclose(plain);

    unsigned string ciphered_data = malloc(ciphered_size);
    fread(ciphered_data, 1, ciphered_size, ciphered);
    fclose(ciphered);

    //Encodage des données pour que les deux soient en b64
    string plain_encoded_b64 = base64_encode(plain_data, plain_size, &plain_output_size);
    string ciphered_encoded_b64 = base64_encode(ciphered_data, ciphered_size, &ciphered_output_size);

    //Si ils ne font pas la même tailles, cela signifie que ce ne sont pas les mêmes fichiers
    if (plain_output_size != ciphered_output_size){
        printf("ERREUR : Les deux fichiers ne sont pas de la même taille, ils ne correspondent pas\n");
        exit(EXIT_FAILURE);
    }

    //Allocation de l'espace pour la clé répétée
    string repeted_key = malloc(plain_output_size + 1);
    repeted_key[plain_output_size] = '\0';


    for (int i = 0; i < plain_output_size; i++){
        //Pour chaque caractère des données, on cherche sa position dans la table d'encodage
        int pos_plain = strchr(encoding_table, plain_encoded_b64[i]) - encoding_table;
        int pos_ciphered = strchr(encoding_table, ciphered_encoded_b64[i]) - encoding_table;
        //On recalcule le décalage de Vigenère (la clé)
        int k = (pos_ciphered - pos_plain + 64) % 64; //(contraire de celui fait dans Vigenère)
        repeted_key[i] = encoding_table[k];
    }

    //On essaye de trouver une répétition
    int key_len = 0;
    for (int L = 1; L <= plain_output_size; L++){ //Tant qu'on a pas trouvé une longueur, on test avec une plus grande
        int ok = 1;

        for (int i = 0; i < plain_output_size - 4; i++){ //-4 pour éviter les 4 derniers caractères qui peuvent être affectés par le padding
            if (repeted_key[i] != repeted_key[i % L]){    //Si pour tout i : repeted_key[i] == repeted_key[i % L], alors la séquence se répète tous les L caractères (Donc la clé = les L premiers caractères)
                ok = 0;
                break;
            }
        }

        if (ok){
            key_len = L;
            break;
        }
    }

    //On stock la clé
    string key_b64 = malloc(key_len + 1);
    for (int i = 0; i < key_len; i++){
        key_b64[i] = repeted_key[i];
    }
    key_b64[key_len] = '\0';

    //On rajoute des paddings si besoin pour que la taille de la clé soit un multiple de 4
    int padded_len = key_len;
    while (padded_len % 4 != 0) padded_len++;

    string key_b64_padded = malloc(padded_len + 1);
    strcpy(key_b64_padded, key_b64);

    for (int i = key_len; i < padded_len; i++){
        key_b64_padded[i] = '=';
    }
    key_b64_padded[padded_len] = '\0';

    //On decode la clé (elle était en b64)
    size_t real_key_size;
    unsigned string real_key = base64_decode(key_b64_padded, padded_len, &real_key_size);

    if (!mode){
        printf("%s\n", real_key);
    } else {
        FILE *f = fopen(path, "w");
        fprintf(f, "%s\n", real_key);
    }
    fprintf(stderr, "%ld\n", real_key_size);

    free(plain_data);
    free(ciphered_data);
    free(plain_encoded_b64);
    free(ciphered_encoded_b64);
    free(repeted_key);
    free(key_b64);
    free(key_b64_padded);
    free(real_key);
}
