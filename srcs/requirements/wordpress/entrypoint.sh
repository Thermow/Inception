#!/bin/sh


echo "=== Démarrage init WordPress ==="

# Ensure DB_HOST has a default
DB_HOST=${DB_HOST:-mariadb}

echo "Attente de MariaDB..."
while ! mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --silent; do
    echo "MariaDB pas prêt, retry..."
    sleep 1
done
echo "MariaDB prêt !"

cd /var/www/html
echo "Dossier courant : $(pwd)"
echo "Contenu : $(ls)"
if [ ! -f wp-load.php ]; then
    echo "[3/5] Downloading WordPress"
    chown -R www-data:www-data /var/www/html || true
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    echo "[4/5] Configuring WordPress"

    wp config create \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=$DB_HOST \
        --allow-root
    echo "Config créée !"

   wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --allow-root
    echo "WordPress installé !"

    wp user create $WP_USER $WP_USER_EMAIL \
        --role=editor \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
    echo "Utilisateur créé !"

else
    echo "WordPress déjà installé, skip."
fi

echo "Lancement PHP-FPM..."
if command -v php-fpm8.2 >/dev/null 2>&1; then
    exec php-fpm8.2 -F
else
    exec php-fpm -F
fi