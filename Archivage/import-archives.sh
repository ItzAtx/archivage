#On vérifie que le dossier existe
if [ ! -d ".sh-toolbox" ]; then
        echo "Erreur : le dossier .sh-toolbox n'existe pas."
        exit 1
fi

#On vérifie que le fichier existe
if [ ! -f ".sh-toolbox/archives" ]; then
        echo "Erreur : le fichier archives est manquant dans .sh-toolbox."
        exit 7
fi

#Condition pour choisir le mode d'importation
if [ "$1" = "-f" ]; then

	if [ $# -lt 2 ]; then
		echo "Erreur : Il faut au moins une archive"
		exit 6
	fi

	shift

	for i in $@; do #On parcourt les arguments passés un à un
		nom_arch=$(basename "$i")
		date_import=$(date +%Y%m%d-%H%M%S)

		if [ ! -f "$i" ] ; then
			echo "Erreur : Le chemin $nom_arch est invalide"
			echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
			exit 2
		fi

		if [[ "$nom_arch" != *.tar.gz ]]; then #Vérifie l'extentsion
            echo "Erreur : l'extension de votre $nom_arch n'est pas .tar.gz"
            exit 2
        fi

		present="" #Vérifie si l'archive à importer est déja présente dans .sh-toolbox

		for l in .sh-toolbox/*; do
			l_n=$(basename $l)

			if [ "$l_n" = "archives" ]; then #ignore le fichier archives quand il le croise
				continue
			fi

			if [ "$l_n" = "$nom_arch" ]; then
				present="o"

				if ! cp $i .sh-toolbox; then
					echo "Erreur : La copie de  $nom_arch n'as pas réussie"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 3
				fi  # met a jour la date seulement sans toucher au compteur 

				echo "importation forcee de $nom_arch"

				if ! sed -i "/^${nom_arch}:/s/:[^:]*:/:$date_import:/" ".sh-toolbox/archives"; then
					echo "Erreur : Problème lors de la mise à jour d'archives"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 4
				fi

			fi

		done #Si archives n'existe pas dans le dossier, alors on ajoute une nouvelle ligne et on incrémente le compteur

		if [ "$present" != "o" ]; then

			if ! cp $i .sh-toolbox; then
                echo "Erreur : La copie de $nom_arch n'as pas réussie"
                echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
				exit 3
			fi

			echo "Importation forcée de $nom_arch"
	        compteur=$(head -n1 ".sh-toolbox/archives")

        	if ! sed -i "1s|.*|$((compteur+1))|" ".sh-toolbox/archives"; then
				echo "Erreur : Problème lors de la mise à jour d'archives"
                echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
                exit 4
			fi
            #On rajoute la ligne de la nouvelle archive importee
            echo "${nom_arch}:${date_import}:" >> ".sh-toolbox/archives"
		fi
	done

else

	#Si le choix n'est pas l'importation forcée, alors on regarde si il y a au moins un argument
	if [ $# -lt 1 ]; then
		echo "Erreur : Il faut au moins une archive"
		exit 6
	fi

	for i in $@; do 
		nom_arch=$(basename "$i")
		date_import=$(date +%Y%m%d-%H%M%S) #Prépare la date d'importation

		if [ ! -f "$i" ]; then #Vérifie si cet argument est une archive
				echo "Erreur : Le chemin vers $nom_arch votre archive n'est pas valable"
				echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
				exit 2
		fi

		if [[ "$nom_arch" != *.tar.gz ]]; then
			echo "Erreur : l'extension de votre archive n'est pas .tar.gz"
			exit 2
		fi

		present=""
		for l in .sh-toolbox/*; do
			l_n=$(basename $l)
			if [ "$l_n" = "archives" ]; then
				continue
			fi

			if [ "$l_n" = "$nom_arch" ]; then
				present="o"
			fi
		done

		if [ "$present" = "o" ]; then #Si l'archive est déja présente dans le dossier .sh-toolbox

			read -p "Le fichier $nom_arch est déja présent, voulez vous l'écraser ? (o/n) " rep

			if [ "$rep" = "o" ]; then

				if ! cp $i .sh-toolbox; then
					echo "Erreur : La copie de $nom_arch n'as pas réussie"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 3
				fi

				if ! sed -i "/^${nom_arch}:/s/:[^:]*:/:$date_import:/" ".sh-toolbox/archives"; then #Écrase après avoir reçu un oui
					echo "Erreur : Problème lors de la mise à jour d'archives"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 4
				fi

			elif [ "$rep" = "n" ]; then
				echo "Écrasement de $nom_arch annulé"
				exit 0 #Sinon ne fait rien
				
			else
				echo "Erreur : Votre réponse n'est pas sous le format attendu"
				echo "Annulation de l'écrasement de $nom_arch par défaut"
				exit 0
			fi

		else
			echo "Importation normale de $nom_arch"
			if ! cp $i .sh-toolbox; then
				echo "Erreur : La copie de $nom_arch n'as pas réussie"
				echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
				exit 3
			fi

			compteur=$(head -n1 ".sh-toolbox/archives")
			if ! sed -i "1s|.*|$((compteur+1))|" ".sh-toolbox/archives"; then
				echo "probleme lors de la mise a jour de archives"
				echo "Le programme importe les archives suivantes que si il n'a pas rencontre de probleme avec les precedentes"
				exit 4
			fi

			#On rajoute la ligne de la nouvelle archive importee
			echo "${nom_arch}:${date_import}:" >> ".sh-toolbox/archives"

		fi
	done
fi
exit 0
