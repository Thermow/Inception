#!/bin/sh
set -e

DB_HOST=${DB_HOST:-mariadb}

echo "=== Démarrage init WordPress ==="
echo "Attente de MariaDB..."

# mariadb-admin (et non mysqladmin) : commande canonique sur MariaDB 10.11.
# -h force une connexion réseau vers le conteneur mariadb.
while ! mariadb-admin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --silent; do
    echo "MariaDB pas prêt, retry..."
    sleep 1
done
echo "MariaDB prêt !"

cd /var/www/html

if [ ! -f wp-load.php ]; then
    echo "[1/3] Téléchargement de WordPress..."
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    echo "[2/3] Configuration de WordPress..."
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root

    echo "[3/3] Installation de WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=editor \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root

    echo "WordPress installé !"
else
    echo "WordPress déjà installé, skip."
fi

# Droits sur les fichiers pour que PHP-FPM (www-data) puisse écrire.
chown -R www-data:www-data /var/www/html

echo "Lancement PHP-FPM..."
if command -v php-fpm8.2 > /dev/null 2>&1; then
    exec php-fpm8.2 -F
else
    exec php-fpm -F
fi
