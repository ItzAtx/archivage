#!/bin/bash

gcc --version >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Erreur : Vous n'avez pas GCC d'installé"
	exit 11
else
	echo "GCC est installé"
fi

#Vérifie l'existence dossier .sh-toolbox
if [ -d ".sh-toolbox" ]; then
	echo "Le dossier .sh-toolbox existe"
else
	echo "Création du dossier .sh-toolbox"
	mkdir ".sh-toolbox"
	if [ $? -ne 0 ]; then
		echo "Erreur : création du dossier impossible"
		exit 1

	fi
fi

#Vérifie l'existence fichier archives
if [ -f ".sh-toolbox/archives" ]; then
	echo "Le fichier archives existe dans .sh-toolbox"
else
	touch ".sh-toolbox/archives"
	if [ $? -ne 0 ]; then
		echo "Erreur : Le fichier archives n'a pas pu être créé"
		exit 1
	else
		echo "Création du fichier archives dans .sh-toolbox"
		echo 0 > ".sh-toolbox/archives"
	fi
fi

#Vérifie l'existence des fichiers sources
if [ -f "src/chiffrement.c" ] && [ -f "src/chiffrement.h" ]; then
	echo "Les fichiers sources existent"
else
	echo "Erreur : Fichiers sources manquants"
	exit 10
fi

#Vérifie l'existence du binaire decipher
if [ -f "src/decipher" ]; then
	echo "decipher existe"
else
	echo "Création de decipher"
	cd src
	make decipher
	cd ..
fi

if [ ! -f "src/decipher" ]; then
	echo "Erreur : Impossible de compiler decipher"
	exit 12
fi

#Vérifie l'existence du binaire findkey
if [ -f "src/findkey" ]; then
	echo "findkey existe"
else
	echo "Création de findkey"
	cd src
	make findkey
	cd ..
fi

if [ ! -f "src/findkey" ]; then
	echo "Erreur : Impossible de compiler findkey"
	exit 12
fi

#Vérifie que le dossier .sh-toolbox ne contient aucun autre fichier ou dossier hormis le fichier archives
if [ $(ls -A .sh-toolbox | grep -v '^archives$' | wc -l ) -ne 0 ]; then
	echo "Erreur : Un autre fichier ou dossier que le fichier archives existe dans .sh-toolbox"
	exit 2
fi

exit 0
