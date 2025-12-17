#!/bin/bash

if [ ! -d .sh-toolbox ]; then
    echo "Erreur : Le dossier .sh-toolbox n'existe pas"
    exit 1

elif [ ! -f .sh-toolbox/archives ]; then
    echo "Erreur, : Le fichier archives manque"
    exit 2
fi

> .liste_affichee

while read -r ligne; do

    #On ignore la ligne du compteur
    premiere=$(echo "$ligne"|sed -nE '/^[0-9]+$/p')

    if [ -n "$premiere" ]; then
        continue
    fi

    archive=$(echo "$ligne" | cut -d ':' -f 1)   
    date=$(echo "$ligne"   | cut -d ':' -f 2)
    cle=$(echo "$ligne"    | cut -d ':' -f 3)

	#Si la clé est vide
    if [ -n "$cle" ]; then
        cle="Clé connue"
    elif [ -z "$cle" ]; then
        cle="Clé inconnue"
    fi

    cle_vide=$(echo "$(echo "$ligne" | cut -d ':' -f 3)" | sed -n '/^[ \t]*$/p')

    if [ -n "$cle_vide" ]; then
    	cle="cle inconnue"
    fi

    occurrence=""

    #On parcourt les fichiers du dossier  essayant de matcher une  ligne
    for lig in .sh-toolbox/*; do
	    lig=$(basename "$lig")
        [ "$lig" = "archives" ] && continue #ignorer archives

        #Si l'archive mentionnée dans archives = le fichier dans .sh-toolbox
        if [ "$archive" = "$lig" ]; then
            occurrence="oui"
        fi

    done


    #Si l'archive dans archives n'est pas présente dans .sh-toolbox
    if [ "$occurrence" != "oui" ]; then
      	echo "Erreur : La ligne de '$archive' est dans le fichier archives, mais n’est pas dans le dossier .sh-toolbox"
        exit 3
    fi

    echo "$archive, $date, $cle"
    echo "$archive" >> .liste_affichee

done < .sh-toolbox/archives


for f in .sh-toolbox/*; do
	f=$(basename "$f")

    #On ignore le fichier archives car ce n'est pas une archive
    [ "$f" = "archives" ] && continue
	[ -d .sh-toolbox/$f ] && continue

    occurrence=""
    while read -r li; do

        if [ "$li" = "$f" ]; then
            occurrence="oui"
        fi

    done < .liste_affichee

    if [ "$occurrence" != "oui" ]; then
        echo "Erreur : '$f' existe dans le dossier .sh-toolbox, mais il n'y a pas sa ligne dans le fichier archives"
        exit 3
    fi
done

rm -f .liste_affichee
exit 0
