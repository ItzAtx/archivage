if [ ! -d ".sh-toolbox" ]; then
	echo "Erreur : Le dossier .sh-toolbox n'existe pas."
	exit 1
fi

if [ ! -f ".sh-toolbox/archives" ]; then
	echo "Erreur : Le fichier archives est manquant dans .sh-toolbox."
	exit 7
fi


if [ "$1" = "-f" ]; then
	if [ $# -lt 2 ]; then
		echo "Erreur : Il faut au moins une archive"
		exit 6
	fi
	shift
	for i in $@; do
			nom_arch=$(basename "$i")
			date_import=$(date +%Y%m%d-%H%M%S)
			if [ ! -f "$i" ]; then
				echo "Le chemin $nom_arch n'est pas valable"
				echo "Le programme n'importe les archives suivantes que s'il n'a pas rencontre de problèmes avec les précédentes"
				exit 2
			fi
			if [[ "$nom_arch" != *.tar.gz ]]; then
				echo "Erreur : L'extension de votre $nom_arch n'est pas .tar.gz"
				exit 2
				fi

				present=""
				for l in .sh-toolbox/*; do
					l_n=$(basename $l)
					if [ "$l_n" = "archives" ]; then
						continue
					fi
					if [ "$l_n" = "$nom_arch" ]; then
						present="oui"
						if ! cp $i .sh-toolbox; then
							echo "Erreur : La copie de  $nom_arch n'a pas reussi"
							echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
							exit 3
						fi

						echo "Importation forcee de $nom_arch"
						if ! sed -i "/^${nom_arch}:/s/:[^:]*:/:$date_import:/" ".sh-toolbox/archives"; then
							echo "Erreur : Problème lors de la mise à jour de archives"
							echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
							exit 4
						fi
					fi
				done
				if [ "$present" != "oui" ]; then
					if [ ! cp $i .sh-toolbox ]; then
                                        	        echo "Erreur : La copie de $nom_arch n'a pas réussie"
                                                	echo "Le programme n'importe les archives suivantes que si il n'as pas rencontré de problèmes avec les précédentes"
                                                	exit 3
					fi
					echo "Importation forcée de $nom_arch"

	                        	compteur=$(head -n1 ".sh-toolbox/archives")
        	                	if ! sed -i "1s|.*|$((compteur+1))|" ".sh-toolbox/archives"; then
							echo "Erreur : problème lors de la mise à jour de archives"
                                                	echo "Le programme n'importe les archives suivantes que si il n'as pas rencontré de problèmes avec les précédentes"
                                                	exit 4
					fi
                        		#On rajoute la ligne de la nouvelle archive importee
                        		echo "${nom_arch}:${date_import}:" >> ".sh-toolbox/archives"
				fi
	done

fi
exit 0
