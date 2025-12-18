if [ $# -ne 1 ]; then
        echo "Usage : $0 <dossier dest>"
        exit 5
fi

if [ ! -d .sh-toolbox ]; then
        echo "Erreur : .sh-toolbox n'existe pas"
        exit 1
fi

if [ ! -d $1 ]; then
	mkdir -p $1
fi

if [ ! -d $1 ]; then
        echo "Erreur : création du dossier de destination impossible"
        exit 2
fi

echo "Archives disponibles :"
./ls-toolbox.sh
read -p "Choisissez une archive : " choix

if [ ! -f ".sh-toolbox/$choix" ]; then
        echo "Erreur : l'archive demandée n'existe pas"
        exit 5
fi

tmp="stock_decomp"
mkdir -p "$tmp"
tar -xzf ".sh-toolbox/$choix" -C "$tmp"

BIN_DIR="./src"
FINDKEY="$BIN_DIR/findkey"
DECIPHER="$BIN_DIR/decipher"

#Vérification que le fichier est chiffré

echo
echo "Analyse de l'archive en cours..."
echo "$choix" | ./check-archive.sh > check_output.txt

check_exit=$?
if [ $check_exit -ne 0 ]; then
        echo "Erreur : l'analyse de l'archive à échouée"
        cat check_output.txt
        rm -f check_output.txt
        exit 5
fi

> encrypted_files

grep "^$tmp/data" check_output.txt > encrypted_files

if [ ! -s encrypted_files ]; then
        echo "Erreur : Aucun fichier chiffré détecté"
        rm -f check_output.txt encrypted_files
        exit 5
fi

cle=""
clear=""
chiff=""

while read line; do
        if echo "$line" | grep -q "On a trouvé le fichier"; then
                chiff=$(echo "$line" | sed 's/On a trouvé le fichier \(.*\) avant .*/\1/')
                clear=$(echo "$line" | sed 's/.*il s.agit de : \(.*\)/\1/')
                base64 -w0 $chiff > tmp_c
                base64 -w0 $clear > tmp_d
                redi_path="${choix%%.*}"
                mkdir -p .sh-toolbox/$redi_path
                touch .sh-toolbox/$redi_path/KEY
                $FINDKEY tmp_d tmp_c -o .sh-toolbox/$redi_path/KEY 2> sortie_erreur.txt
                cle=$(cat .sh-toolbox/$redi_path/KEY)
                break
        fi
done < check_output.txt

if [ -z "$cle" ]; then
        echo "Erreur : Impossible de retrouver la clé"
        exit 5
fi

#On met la clé dans archives

date_import=$(grep "^$choix:" .sh-toolbox/archives | cut -d':' -f2)
if [ -f .sh-toolbox/$redi_path/KEY ]; then
        sed -i "s/^$choix:.*/$choix:$date_import::f/" .sh-toolbox/archives
else
        sed -i "s/^$choix:.*/$choix:$date_import:$cle:s/" .sh-toolbox/archives
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
        if [ ! $dest ]; then
                echo "Erreur : Impossible de restaurer $chiff"
                exit 4
        fi
done

rm tmp
rm tmp_d
rm tmp_c
rm encrypted_files
rm -rf $tmp
rm check_output.txt
exit 0
