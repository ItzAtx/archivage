if [ $# -ne 1 ]; then
        echo "Usage : $0 <dossier dest>"
        exit 5
fi

if [ ! -d $1 ]; then
	mkdir -p $1
fi

if [ ! -d $1 ]; then
        echo "Erreur : création du dossier de destination impossible"
        exit 2
fi

if [ ! -d .sh-toolbox ]; then
        echo "Erreur : .sh-toolbox n'existe pas"
        exit 1
fi

echo "Archives disponibles :"
./ls-toolbox.sh
read -p "Choisissez une archive : " choix

if [ ! -f ".sh-toolbox/$choix" ]; then
        echo "Erreur : l'archive demandée n'existe pas"
        exit 5
fi

BIN_DIR="./src"
FINDKEY="$BIN_DIR/findkey"
DECIPHER="$BIN_DIR/decipher"

#Vérification que le fichier est chiffré

tmp="restore_tmp"
mkdir -p "$tmp"
tar -xzf ".sh-toolbox/$choix" -C "$tmp"

login_line=$(grep -E "(Accepted|session opened).*admin" "$tmp/var/log/auth.log" | tail -n 1)

mois=$(echo "$login_line" | cut -d' ' -f1)
jour=$(echo "$login_line" | cut -d' ' -f2)
heure=$(echo "$login_line" | cut -d' ' -f3)
annee=$(date +%Y)
timestamp_admin=$(date -d "$mois $jour $annee $heure" +%s)

> encrypted_files

if [ ! -d "$tmp/data" ]; then
        echo "Erreur : Aucun dossier data trouvé dans l'archive"
        exit 5
fi

for f in $(find "$tmp/data" -type f); do
    ts=$(stat -c %Y "$f")

    if [ $ts -ge $timestamp_admin ]; then
        echo "$f" >> encrypted_files   #on stocke le fichier chiffré
    fi
done


#On retrouve la clé de déchiffrement pour chaque fichier

for chiff in $(cat encrypted_files); do
        nom=$(basename $chiff)
        clair=""

        for f in $(find "$tmp/data" -type f); do
                nom2=$(basename "$f")
                ts2=$(stat -c %Y "$f")

                if [ "$nom2" = "$nom" ] && [ "$ts2" -lt "$timestamp_admin" ]; then
                        clair="$f"
                        read -p "Voulez vous rediriger la clé dans un fichier ? (o/n) " rep_redi
                        base64 -w0 $clair > tmp_d
                        base64 -w0 $chiff > tmp_c
                        if [ "$rep_redi" = n ]; then
                                cle=$("$FINDKEY" tmp_d tmp_c 2>sortie_erreur.txt)
                        else
                                redi_path="${choix%%.*}"
                                mkdir -p .sh-toolbox/$redi_path
                                touch .sh-toolbox/$redi_path/KEY
                                "$FINDKEY" tmp_d tmp_c -o .sh-toolbox/$redi_path/KEY 2> sortie_erreur.txt
                                cle=$(cat .sh-toolbox/$redi_path/KEY)
                        fi
                        break
                fi
        done

        if [ -n "$cle" ]; then
                break
        fi
done

if [ -z "$cle" ]; then
        echo "Erreur : Impossible de retrouver la clé"
        exit 6
fi

#On met la clé dans archives

date_import=$(grep "^$choix:" .sh-toolbox/archives | cut -d':' -f2)
if [ "$rep_redi" = n ]; then
        sed -i "s/^$choix:.*/$choix:$date_import:$cle:s/" .sh-toolbox/archives
else
        sed -i "s/^$choix:.*/$choix:$date_import::f/" .sh-toolbox/archives
fi

#On récupère le contenu des fichiers

for chiff in $(cat encrypted_files); do
        path=${chiff#"$tmp/data/"}
        dest="$1/$path"
        dir_dest=$(dirname $dest)
        mkdir -p $dir_dest

        if [ -f "$dest" ]; then
                read -p "$dest existe déjà. Écraser ? (o/n) : " rep
                if [ $rep = n ]; then
                        continue
                fi
        fi

        cle_b64=$(echo -n $cle | base64)
        base64 -w0 $chiff > tmp
        "$DECIPHER" $cle_b64 tmp
        base64 -d tmp > $dest
done

rm tmp
rm tmp_d
rm tmp_c
rm encrypted_files
rm -rf $tmp
exit 0
