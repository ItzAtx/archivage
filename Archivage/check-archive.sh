#!/bin/bash

if [ -d .sh-toolbox ]; then
        echo "Le dossier .sh-toolbox existe"
else
        echo "Erreur : Le dossier .sh-toolbox n'existe pas"
        exit 1
fi

if [ -f .sh-toolbox/archives ]; then
        echo "Le fichier archives existe dans .sh-toolbox"
else
        echo "Erreur : Le fichier archives n'existe pas dans .sh-toolbox"
        exit 2
fi


echo
t=0
echo "Entrez le nom de l'archive que vous voulez checker : "
read rep
echo

#On décompresse l'archive choisie
for i in $(ls .sh-toolbox); do
        if [ "$i" = "archives" ]; then
                continue
        fi

        if [ -d ".sh-toolbox/$i" ]; then
                continue
        fi

        if [ "$rep" = "$i" ]; then
                t=1
        fi
done

if [ $t -eq 0 ]; then
        echo "Erreur : le nom saisi ne correspond à aucune archive existante"
        exit 32
fi

if [ -d "stock_decomp" ]; then
	rm -R "stock_decomp"
fi

mkdir stock_decomp

echo "Décompression en cours"

if ! tar -xzf ".sh-toolbox/$rep" -C "stock_decomp"; then
        echo "Erreur : La décompression n'as pas reussie"
        exit 3
fi


if [ ! -f  stock_decomp/var/log/auth.log ]; then
    echo "Erreur : Le fichier auth.log n'existe pas"
        exit 4
fi


echo
echo "La dernière connexion de admin fut : "

#On sélectionne la ligne de dernière connexion

mois=$(grep -E "(Accepted.*for admin.*|session opened for user admin.*)" stock_decomp/var/log/auth.log | tail -n 1 | cut -d' ' -f1)
jour=$(grep -E "(Accepted.*for admin.*|session opened for user admin.*)" stock_decomp/var/log/auth.log | tail -n 1 | cut -d' ' -f2)
heure=$(grep -E "(Accepted.*for admin.*|session opened for user admin.*)" stock_decomp/var/log/auth.log | tail -n 1 | cut -d' ' -f3)

#Comme le fichier des données de test ne contient pas l'année, on complète avec année acutelle en supposant que tout a lieu la même année
annee=$(date +%Y)
derniere="$mois $jour $annee $heure"
echo $derniere

#Comme stat donne le nombre de secondes écoulées depuis le 1 er janvier 1970, on dois donc convertir la dernière connexion de admin en secondes
sec=$(date -d "$derniere" +%s )

#On affiche seulement ceux modifiés après cette connexion.
> modif_list
if [ ! -d "stock_decomp/data" ]; then
    echo "Erreur : Le dossier de données n'existe pas"
    exit 30
fi

if [ -z "$(ls -A stock_decomp/data)" ]; then
    echo "Erreur : Le dossier de données est vide"
    exit 5
fi



for f in $(find stock_decomp/data -type f); do
    ts=$(stat -c %Y "$f")
    if [ "$ts" -ge "$sec" ]; then
        echo "$f" >> modif_list
    fi
done

echo

echo "Modifiés après la dernière connexion admin : "
cat modif_list

echo

echo "Copies non modifiées correspondant aux fichiers affectés :"
while read affecte; do

    #On prend le nom du fichier
    nom=$(basename "$affecte")

    #On récupère la taille du fichier modifié
    taille=$(stat -c %s "$affecte")

    #On parcourt tous les fichiers de data
    for f in $(find stock_decomp/data -type f); do

                #On ignore le fichier modifié lui-même
                [ "$f" = "$affecte" ] && continue

                #Timestamp de derniere modification en secondes (option Y de stat)
                ts_f=$(stat -c %Y "$f")

                #On regarde si le timestamp de la dernière modification est inférieur à celui de la dernière connexion de admin
                if [ "$ts_f" -lt "$sec" ]; then

                        le_nom=$(basename "$f")
                        la_taille=$(stat -c %s "$f")

                        #Test si ils ont le même nom et la même taille que le fichier modifié
                        if [ "$le_nom" = "$nom" ] && [ "$la_taille" -eq "$taille" ]; then
                                echo "On a trouvé le fichier $affecte avant qu'il ne soit chiffré, il s'agit de : $f"
                        fi
                fi

    done

done < modif_list
rm  "modif_list"
exit 0