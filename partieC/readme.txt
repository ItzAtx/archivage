Cette archive zip est censée contenir les fichiers suivants : 
-chiffrement.c
-chiffrement.h
-cipher.c
-cipher_total.c
-decipher.c
-decipher_total.c
-findkey.c
-findkey_total.c
-Makefile

COMPILATION : 

make all : compile tous les outils + la bibliothèque statique
make lib : compile la bibliothèque statique
make clean_o : supprime les .o
make clean_all : supprime tout (executables + .o)

OUTILS DISPONIBLES :

cipher/decipher/findkey : 
Ces outils nécessitent un encodage/décodage base64 externe via bash.

UTILISATION DE CIPHER/DECIPHER :

Chiffrement avec cipher :
base64 -w0 <fichier> > tmp
echo -n <clé> | base64 -w0
./cipher <clé_en_b64> tmp
base64 -d tmp > <fichier>
rm tmp

Déchiffrement avec decipher :
base64 -w0 <fichier> > tmp
echo -n <clé> | base64 -w0
./decipher <clé_en_b64> tmp
base64 -d tmp > <fichier>
rm tmp

Note : Un fichier tmp est nécessaire.

UTILISATION DE FINDKEY :

Récupération de la clé avec findkey :
base64 -w0 <fichier clair> > tmp_d
base64 -w0 <fichier chiffré> > tmp_c
./findkey tmp_d tmp_c
rm tmp_d tmp_c

Note : Deux fichiers tmp sont nécessaire.

cipher_total/decipher_total/findkey_total :
Ces outils gèrent l'encodage/décodage base64 automatiquement en C (donc on entre directement fichier clair/entièrement chiffré et clé en clair dedans).

UTILISATION DE CIPHER_TOTAL/DECIPHER_TOTAL :

Chiffrement avec cipher_total : 
./cipher_total <clé> <fichier>

Déchiffrement avec decipher_total :
./decipher_total <clé> <fichier>

UTILISATION DE FINDKEY_TOTAL :

Récupération de la clé avec findkey :
./findkey <fichier_clair> <fichier_chiffré>