#!/bin/bash

#On vérifie l'existence du dossier .sh-toolbox
if [ ! -d ".sh-toolbox" ]; then
    echo "Le dossier .sh-toolbox n'existe pas"
    read -p "Voulez-vous qu'il soit créé ? (o/n) : " rep
    if [ "$rep" = "o" ]; then
        mkdir .sh-toolbox
    else
        echo "Erreur : vous avez choisit de ne pas créer le dossier, fin du programme"
	    exit 9
    fi
fi

#On vérifie l'existence du fichier archives
if [ ! -f ".sh-toolbox/archives" ]; then
    echo "Le fichier archives n'existe pas dans .sh-toolbox"
    read -p "Voulez-vous qu'il soit créé ? (o/n) : " rep
    if [ "$rep" = "o" ]; then
	    echo 0 > .sh-toolbox/archives
    else
        echo "Erreur : vous avez choisit de ne pas créer le fichier archives, fin du programme"
		exit 9
    fi
fi

> liste_correcte
compteur=$(head -n 1 .sh-toolbox/archives)
courant=2 #Pour sauter la ligne du compteur
total=$(wc -l < .sh-toolbox/archives)

#Vérifie que toutes les archives dans .sh-toolbox sont mentionnées dans le fichier archives
while [ "$courant" -le "$total" ]; do
    ligne=$(sed -n "${courant}p" .sh-toolbox/archives) 
    archive=$(echo "$ligne" | cut -d ':' -f 1)

    occurrence=""
    for lig in .sh-toolbox/*; do
        lig=$(basename "$lig")
        [ "$lig" = "archives" ] && continue #On ignore archives

        if [ "$archive" = "$lig" ]; then
            occurrence="oui"
        fi
    done

    #Si l'archive est trouvée, l'ajouter à la liste valide
    if [ "$occurrence" = "oui" ]; then
        echo "$archive" >> liste_correcte
        courant=$((courant + 1))
    else
        #Sinon, erreur
        echo "ERREUR : '$archive' est mentionnée dans archives mais absente dans .sh-toolbox."
        read -p "Supprimer cette ligne ? (o/n) : " rep

        if [ "$rep" = "o" ]; then
            sed -i "/^$archive:/d" .sh-toolbox/archives
            echo "Ligne supprimée."

	    total=$(wc -l < .sh-toolbox/archives)
	     compteur=$((total-1))
            if ! sed -i "1s|.*|$compteur|" ".sh-toolbox/archives"; then
                echo "Erreur : Problème lors de la mise à jour du fichier archives"
                exit 4
            fi

        else
            echo "Ligne conservée (incohérence)."
            courant=$((courant + 1))
        fi
    fi
done

#Vérifie que toutes les archives dans le fichier archives existent dans le dossier .sh-toolbox
for f in .sh-toolbox/*; do
    f=$(basename "$f")
    #On ignore le fichier archives
    [ "$f" = "archives" ] && continue

    occurrence=""
    #On parcourt la liste des archives valides
    while read -r li; do
        if [ "$li" = "$f" ]; then
            occurrence="oui"
        fi
    done < liste_correcte
    
    if [ "$occurrence" != "oui" ]; then
        echo "Erreur : '$f' existe dans le dossier .sh-toolbox mais il n'y a pas sa ligne dans archives"
        read -p "Vous voulez ajouter la ligne ? (o/n) : " rep

        if [ "$rep" = "o" ]; then
		    compteur=$(head -n 1 .sh-toolbox/archives)
		    comp=$((compteur+1))
            if ! sed -i "1s|.*|$comp|" ".sh-toolbox/archives"; then
                echo "Erreur : Problème lors de la mise à jour du fichier archives"
                exit 4
            fi

            #On rajoute la ligne
            echo "$f:$(date +%Y%m%d-%H%M%S):" >> ".sh-toolbox/archives"
        fi
    fi
done

rm -f liste_correcte
exit 0
