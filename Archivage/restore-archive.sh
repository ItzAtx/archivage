#!/bin/bash

#Vérifie l'argument
if [ $# -ne 1 ]; then
        echo "Usage : $0 <dossier dest>"
        exit 5
fi

#Vérifie l'existence du dossier .sh-toolbox
if [ ! -d .sh-toolbox ]; then
        echo "Erreur : .sh-toolbox n'existe pas"
        exit 1
fi

#Si le dossier en argument n'existe pas, on le crée
if [ ! -d $1 ]; then
	mkdir -p $1
fi

#Vérifie que le dossier a bien été créé
if [ ! -d $1 ]; then
        echo "Erreur : création du dossier de destination impossible"
        exit 2
fi

#Affiche les archives disponibles qui peuvent êtres réstaurées
echo "Archives disponibles :"
./ls-toolbox.sh
read -p "Choisissez une archive : " choix

if [ ! -f ".sh-toolbox/$choix" ]; then #Vérifie que l'archive choisie existe
        echo "Erreur : l'archive demandée n'existe pas"
        exit 5
fi

if [ -d stock_decomp ]; then
        rm -R stock_decomp
fi

tmp="stock_decomp"
mkdir -p "$tmp"
tar -xzf ".sh-toolbox/$choix" -C "$tmp" #Décompresse l'archive

BIN_DIR="./src"
FINDKEY="$BIN_DIR/findkey"
DECIPHER="$BIN_DIR/decipher"

echo
echo "Analyse de l'archive en cours..."
echo "$choix" | ./check-archive.sh > check_output #On se sert de check-archive pour détecter les paires de fichiers clairs/chiffrés

#Vérifie que check-archive a fonctionné
check_exit=$?
if [ $check_exit -ne 0 ]; then
        echo "Erreur : l'analyse de l'archive à échouée"
        cat check_output
        rm -f check_output
        exit 5
fi

> encrypted_files

grep "^$tmp/data" check_output > encrypted_files #On fait une liste de tous les fichiers chiffrés

if [ ! -s encrypted_files ]; then #Vérifie qu'on a trouvé au moins un fichier chiffré
        echo "Erreur : Aucun fichier chiffré détecté"
        rm -f check_output encrypted_files
        exit 5
fi

cle_b64=""
clear=""
chiff=""

while read line; do #On va essayer de trouver la clé grace un fichier dans sa version claire/chiffrée
        if echo "$line" | grep -q "On a trouvé le fichier"; then
                chiff=$(echo "$line" | sed 's/On a trouvé le fichier \(.*\) avant .*/\1/')
                clear=$(echo "$line" | sed 's/.*il s.agit de : \(.*\)/\1/')
                base64 -w0 "$chiff" > tmp_c
                base64 -w0 "$clear" > tmp_d
                redi_path="${choix%%.*}"
                mkdir -p .sh-toolbox/"$redi_path"
                touch .sh-toolbox/"$redi_path"/KEY
                "$FINDKEY" tmp_d tmp_c -o .sh-toolbox/"$redi_path"/KEY 2> sortie_erreur.txt
                cle_b64=$(cat .sh-toolbox/"$redi_path"/KEY)
                cle=$(echo -n "$cle_b64" | base64 -d)
                echo -n "$cle" > .sh-toolbox/"$redi_path"/KEY
                break
        fi
done < check_output

if [ -z "$cle_b64" ]; then #Vérifie qu'on a bien trouvé une cle
        echo "Erreur : Impossible de retrouver la clé"
        rm -R ".sh-toolbox/$redi_path"
        exit 5
fi

date_import=$(grep "^$choix:" .sh-toolbox/archives | cut -d':' -f2)
if [ -f .sh-toolbox/$redi_path/KEY ]; then
        sed -i "s/^$choix:.*/$choix:$date_import::f/" .sh-toolbox/archives #On met à jour le fichier archives
fi

for line in $(cat .sh-toolbox/archives); do #On met à jour le fichier archives pour les archives qui ont une clé mais pas de 4e colonne
        if echo "$line" | grep -qE '^[^:]+:[^:]+:[^:]+$'; then
                echo "$line:s" >> .sh-toolbox/archives_tmp
        else
                echo "$line" >> .sh-toolbox/archives_tmp
        fi
done
mv .sh-toolbox/archives_tmp .sh-toolbox/archives

#On récupère le contenu des fichiers
for chiff in $(cat encrypted_files); do
        path=${chiff#"$tmp/data/"}
        dest="$1/$path"
        dir_dest=$(dirname $dest)
        mkdir -p $dir_dest

        if [ -f "$dest" ]; then #On demande à l'utilisateur s'il veut écraser un fichier déjà déchiffré
                read -p "$dest existe déjà. Écraser ? (o/n) : " rep
                if [ $rep = n ]; then
                        continue
                fi
        fi

        base64 -w0 $chiff > tmp
        "$DECIPHER" $cle_b64 tmp
        base64 -d tmp > $dest
        if [ ! -f $dest ]; then
                echo "Erreur : Impossible de restaurer $chiff"
                exit 4
        fi
done

rm tmp
rm tmp_d
rm tmp_c
rm encrypted_files
rm -rf $tmp
rm check_output
exit 0
