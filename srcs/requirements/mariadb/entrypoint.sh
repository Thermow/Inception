#!/bin/sh
set -e

DATADIR="/var/lib/mysql"

# On initialise uniquement si la base n'existe pas encore.
# Tester /var/lib/mysql/mysql (la base système) est plus fiable
# que tester le dossier lui-même, qui peut exister mais être vide.
if [ ! -d "$DATADIR/mysql" ]; then

    echo "[INIT] Initialisation du répertoire de données..."
    mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db > /dev/null

    echo "[INIT] Application du SQL via bootstrap..."
    mariadbd --user=mysql --datadir="$DATADIR" --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "[INIT] Initialisation terminée avec succès !"
else
    echo "[INIT] Base déjà initialisée, skip."
fi

echo "[START] Démarrage de MariaDB..."
exec mariadbd --user=mysql --datadir="$DATADIR"
