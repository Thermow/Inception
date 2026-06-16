# USER_DOC — Inception

## What is this project?

This stack runs a WordPress website served over HTTPS, backed by a MariaDB database, and exposed through an Nginx reverse proxy.

| Service   | Role                                      |
|-----------|-------------------------------------------|
| Nginx     | HTTPS entry point (TLS 1.2/1.3)           |
| WordPress | PHP application + admin panel (PHP-FPM)   |
| MariaDB   | Relational database                       |

---

## Starting and stopping the project

**Start:**
```bash
make
```

**Stop (keep data):**
```bash
make down
```

**Stop and wipe all data (volumes included):**
```bash
make fclean
```

**Restart containers without rebuilding:**
```bash
make restart
```

---

## Accessing the website

Open your browser and go to:

```
https://tchevall.42.fr:8443
```

> The site uses a self-signed TLS certificate. Your browser will show a security warning — click "Advanced" then "Accept the risk and continue" to proceed.

### WordPress administration panel

```
https://tchevall.42.fr:8443/wp-admin
```

Log in with the admin credentials defined in the `.env` file (see below).

---

## Credentials

All credentials are stored in the `.env` file located in `srcs/`.

| Variable            | Description                          |
|---------------------|--------------------------------------|
| `DB_NAME`           | WordPress database name              |
| `DB_USER`           | Database user for WordPress          |
| `DB_PASSWORD`       | Password for the database user       |
| `MYSQL_ROOT_PASSWORD` | MariaDB root password              |
| `WP_ADMIN_USER`     | WordPress administrator username     |
| `WP_ADMIN_PASSWORD` | WordPress administrator password     |
| `WP_ADMIN_EMAIL`    | WordPress administrator email        |
| `WP_USER`           | Additional WordPress editor username |
| `WP_USER_PASSWORD`  | Password for the editor account      |

> Never commit the `.env` file to a public repository.

---

## Checking that services are running

**List running containers:**
```bash
make ps
# or
docker ps
```

All three containers (`mariadb`, `wordpress`, `nginx`) should show status `Up`.

**Check logs for a specific service:**
```bash
make logs SERVICE=nginx
make logs SERVICE=wordpress
make logs SERVICE=mariadb
```

**Quick health check:**
```bash
curl -k https://localhost:8443
```

You should receive an HTML response from WordPress (or Nginx).
