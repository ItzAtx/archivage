Ce dossier est censé contenir les fichiers suivants : 
-chiffrement.c
-chiffrement.h
-decipher.c
-findkey.c
-Makefile

COMPILATION : 

make all : compile tous les outils
make clean_o : supprime les .o
make clean_all : supprime tout (executables + .o)

OUTILS DISPONIBLES :

decipher/findkey : 

UTILISATION DE DECIPHER :

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