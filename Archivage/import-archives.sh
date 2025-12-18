#!/bin/bash

#-------VÉRIFICATIONS-------

#Existence de .sh-toolbox
if [ ! -d ".sh-toolbox" ]; then
        echo "Erreur : le dossier .sh-toolbox n'existe pas."
        exit 1
fi

#Existence de .sh-toolbox/archives
if [ ! -f ".sh-toolbox/archives" ]; then
        echo "Erreur : le fichier archives est manquant dans .sh-toolbox."
        exit 7
fi


if [ "$1" = "-f" ]; then
	#-------AVEC OPTION -f-------
	if [ $# -lt 2 ]; then
		echo "Erreur : Il faut au moins une archive"
		exit 6
	fi

	shift #On enlève -f

	for i in $@; do #On parcourt les arguments passés un à un
		nom_arch=$(basename "$i")
		date_import=$(date +%Y%m%d-%H%M%S)

		if [ ! -f "$i" ] ; then  #Vérifie si l'archive existe
			echo "Erreur : Le chemin $nom_arch est invalide"
			echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
			exit 2
		fi

		if [[ "$nom_arch" != *.tar.gz ]]; then #Vérifie l'extension
            echo "Erreur : l'extension de votre $nom_arch n'est pas .tar.gz"
            exit 2
        fi

		present="" #Vérifie si l'archive à importer est déja présente dans .sh-toolbox

		for l in .sh-toolbox/*; do
			l_n=$(basename $l)

			if [ "$l_n" = "archives" ]; then #Ignore le fichier archives quand il le croise
				continue
			fi

			#-------CAS DEJA PRESENT-------
			if [ "$l_n" = "$nom_arch" ]; then
				present="o"

				if ! cp $i .sh-toolbox; then
					echo "Erreur : La copie de  $nom_arch n'as pas réussie"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 3
				fi

				echo "importation forcee de $nom_arch"

				#Met à jour la date seulement sans toucher au compteur 
				if ! sed -i "/^${nom_arch}:/s/:[^:]*:/:$date_import:/" ".sh-toolbox/archives"; then
					echo "Erreur : Problème lors de la mise à jour d'archives"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 4
				fi

			fi

		done
		#-------CAS PAS PRESENT-------
		if [ "$present" != "o" ]; then

			if ! cp $i .sh-toolbox; then
                echo "Erreur : La copie de $nom_arch n'as pas réussie"
                echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
				exit 3
			fi

			echo "Importation forcée de $nom_arch"

			#On ajoute une nouvelle ligne et on incrémente le compteur
	        compteur=$(head -n1 ".sh-toolbox/archives")

        	if ! sed -i "1s|.*|$((compteur+1))|" ".sh-toolbox/archives"; then
				echo "Erreur : Problème lors de la mise à jour d'archives"
                echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
                exit 4
			fi
            #On rajoute la ligne de la nouvelle archive importée
            echo "${nom_arch}:${date_import}:" >> ".sh-toolbox/archives"
		fi
	done

else

	#-------SANS OPTION -f-------
	if [ $# -lt 1 ]; then
		echo "Erreur : Il faut au moins une archive"
		exit 6
	fi

	for i in $@; do 
		nom_arch=$(basename "$i")
		date_import=$(date +%Y%m%d-%H%M%S)

		if [ ! -f "$i" ]; then #Vérifie si l'archive existe
				echo "Erreur : Le chemin vers $nom_arch votre archive n'est pas valable"
				echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
				exit 2
		fi

		if [[ "$nom_arch" != *.tar.gz ]]; then #Vérifie l'extension
			echo "Erreur : l'extension de votre archive n'est pas .tar.gz"
			exit 2
		fi

		present=""
		for l in .sh-toolbox/*; do
			l_n=$(basename $l)
			if [ "$l_n" = "archives" ]; then #Ignore le fichier archives
				continue
			fi

			if [ "$l_n" = "$nom_arch" ]; then
				present="o"
			fi
		done

		#-------CAS DEJA PRESENT-------
		if [ "$present" = "o" ]; then

			read -p "Le fichier $nom_arch est déja présent, voulez vous l'écraser ? (o/n) " rep #Choix pour l'utilisateur

			if [ "$rep" = "o" ]; then

				if ! cp $i .sh-toolbox; then
					echo "Erreur : La copie de $nom_arch n'as pas réussie"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 3
				fi

				#Mise à jour de la date d'import
				if ! sed -i "/^${nom_arch}:/s/:[^:]*:/:$date_import:/" ".sh-toolbox/archives"; then
					echo "Erreur : Problème lors de la mise à jour d'archives"
					echo "Le programme n'importe les archives suivantes que s'il n'as pas rencontré de problèmes avec les précédentes"
					exit 4
				fi
			
			#Si refuse, exit
			elif [ "$rep" = "n" ]; then
				echo "Écrasement de $nom_arch annulé"
				exit 0

			#Si réponse non conforme	
			else
				echo "Erreur : Votre réponse n'est pas sous le format attendu"
				echo "Annulation de l'écrasement de $nom_arch par défaut"
				exit 0
			fi

		else
			#-------CAS PAS PRESENT-------
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

			echo "${nom_arch}:${date_import}:" >> ".sh-toolbox/archives"

		fi
	done
fi
exit 0
