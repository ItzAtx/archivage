Ce dossier est censé contenir les fichiers suivants :
-Un dossier "src"
-check-archive.sh
-import-archives.sh
-init-toolbox.sh
-ls-toolbox.sh
-restore-archive.sh
-restore-toolbox.sh

ROLES ET UTILISATIONS DES SCRIPTS :

-----------------
init-toolbox.sh :
Initialise l'environnement de travail et compile les outils nécessaires

Utilisation : ./init-toolbox.sh
-----------------

-----------------
import-archives.sh :
Importe une ou plusieurs archives .tar.gz dans .sh-toolbox/

Utilisation : ./import-archives.sh <archive1.tar.gz> <archive2.tar.gz> ...
-----------------

-----------------
ls-toolbox.sh :
Liste toutes les archives présentes dans .sh-toolbox/ avec leur statut

Utilisation : ./ls-toolbox.sh
-----------------

-----------------
restore-toolbox.sh :
Répare les incohérences entre le fichier archives et le contenu de .sh-toolbox/

Utilisation : restore-toolbox.sh
-----------------

-----------------
check-archive.sh :
Analyse une archive pour identifier les fichiers modifiés après la dernière connexion admin et trouve leurs versions claires

Utilisation : ./check-archive.sh
-----------------

-----------------
restore-archive.sh :
Restaure les fichiers chiffrés d'une archive en récupérant automatiquement la clé de déchiffrement (utilise celle en base64 mais l'affiche en clair)

Utilisation : ./restore-archive.sh <dossier_destination>
-----------------

