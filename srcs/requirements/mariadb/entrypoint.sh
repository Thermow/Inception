#!/bin/sh
set -e

DATADIR="/var/lib/mysql"

# Support both MYSQL_* and DB_* env variable names
: "${MYSQL_ROOT_PASSWORD:=${DB_ROOT_PASSWORD}}"
: "${MYSQL_DATABASE:=${DB_NAME}}"
: "${MYSQL_USER:=${DB_USER}}"
: "${MYSQL_PASSWORD:=${DB_PASSWORD}}"

if [ ! -d "$DATADIR/mysql" ]; then
    echo "[INIT] Initialisation de la base de données..."
    mysql_install_db --user=mysql --datadir=$DATADIR

    echo "[INIT] Démarrage temporaire de MariaDB..."
    mariadbd --user=mysql --datadir="$DATADIR" &
    PID=$!

    echo "[INIT] Attente du serveur..."
    until mariadb-admin ping -h 127.0.0.1 --silent; do
        sleep 1
    done

    echo "[INIT] Configuration des utilisateurs et privilèges..."
    mariadb -u root -h 127.0.0.1 << EOF
        -- Sécurisation du root (Optionnel mais recommandé)
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD:-secret}';
        
        -- Création de la DB et de l'utilisateur
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOF

    echo "[INIT] Arrêt du serveur temporaire..."
    kill -s TERM "$PID"
    wait "$PID"
    echo "[INIT] Initialisation terminée avec succès !"
fi

echo "[START] Démarrage normal de MariaDB..."
exec mariadbd --user=mysql --datadir=$DATADIR