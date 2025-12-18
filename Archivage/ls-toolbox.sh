#!/bin/bash

#Vérifie l'existence du dossier .sh-toolbox
if [ ! -d .sh-toolbox ]; then
    echo "Erreur : Le dossier .sh-toolbox n'existe pas"
    exit 1
fi

#Vérifie l'existence du fichier archives
if [ ! -f .sh-toolbox/archives ]; then
    echo "Erreur : Le fichier archives manque"
    exit 2
fi

> .liste_affichee

while read -r ligne; do

    #On ignore la ligne du compteur
    premiere=$(echo "$ligne"|sed -nE '/^[0-9]+$/p')

    if [ -n "$premiere" ]; then
        continue
    fi

    #On extrait les informations
    archive=$(echo "$ligne" | cut -d ':' -f 1)   
    date=$(echo "$ligne"   | cut -d ':' -f 2)
    cle=$(echo "$ligne"    | cut -d ':' -f 3)

	#On regarde si la clé est connue ou non
    if [ -n "$cle" ]; then
        cle="Clé connue"
    elif [ -z "$cle" ]; then
        cle="Clé inconnue"
    fi

    #Si la clé est du texte vide
    cle_vide=$(echo "$(echo "$ligne" | cut -d ':' -f 3)" | sed -n '/^[ \t]*$/p')

    if [ -n "$cle_vide" ]; then
    	cle="cle inconnue"
    fi

    occurrence=""

    #On vérifie pour chaque lignes dans archives que l'archive correspondante existe bien dans le dossier
    for lig in .sh-toolbox/*; do
	    lig=$(basename "$lig")
        [ "$lig" = "archives" ] && continue #On ignore le fichier archives

        #Si l'archive mentionnée dans archives = le fichier dans .sh-toolbox, alors existe
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

#Pour toutes les archives, on regarde si elle est dans le fichier archives
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
