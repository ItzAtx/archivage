COMPILATION : 

make all : compile tous les outils + la bibliothèque statique
make lib : compile la bibliothèque statique
make clean_o : supprime les .o
make clean_all : supprime tout (executables + .o)

OUTILS DISPONIBLES :

cipher/decipher : 
Ces outils nécessitent un encodage/décodage base64 externe via bash.

UTILISATION DE CIPHER/DECIPHER :

Chiffrement avec cipher :
base64 -w 0 <fichier> > tmp
./cipher <clé_en_b64> tmp
base64 -d tmp > <fichier>

Déchiffrement avec decipher :
base64 -w 0 <fichier> > tmp
./decipher <clé_en_b64> tmp
base64 -d tmp > <fichier>

Note : La clé doit être encodée en base64 avant utilisation. Un fichier tmp est nécéssaire.

cipher_total/decipher_total :
Ces outils gèrent l'encodage/décodage base64 automatiquement en C.

UTILISATION DE CIPHER_TOTAL/DECIPHER_TOTAL :

Chiffrement avec cipher_total : 
./cipher_total <clé> <fichier>

Déchiffrement avec decipher_total :
./decipher_total <clé> <fichier>

findkey : 
Permet de retrouver la clé de chiffrement à partir d'un fichier en clair et de sa version chiffrée

UTILISATION DE FINDKEY :

findkey :

./findkey <fichier_clair> <fichier_chiffré>
