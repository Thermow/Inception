# DEV_DOC — Inception

## Prerequisites

| Tool              | Version tested | Notes                                      |
|-------------------|----------------|--------------------------------------------|
| Podman            | 4.x+           | Used instead of Docker on 42 machines      |
| podman-compose    | 1.x            | Wrapper used by the Makefile               |
| GNU Make          | any            |                                            |
| openssl           | any            | Used at build time for the TLS certificate |

> On 42 machines, `docker` is aliased to `podman`. The Makefile uses `podman compose` directly to avoid the freeze bug in `podman-compose -d`.

---

## Project structure

```
Inception/
├── Makefile
└── srcs/
    ├── .env                        # Secrets and configuration (not committed)
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── entrypoint.sh       # Init script: creates DB and user on first boot
        │   └── 50-server.cnf       # MariaDB config (bind-address = 0.0.0.0)
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── entrypoint.sh       # Init script: downloads and installs WordPress
        │   └── www.conf            # PHP-FPM pool config
        └── nginx/
            ├── Dockerfile          # Generates self-signed TLS cert at build time
            └── nginx.conf          # HTTPS server block, FastCGI to wordpress:9000
```

---

## Environment configuration

Copy and fill in the `.env` file in `srcs/`:

```dotenv
DB_NAME=wordpress
DB_USER=wp
DB_PASSWORD=wp_pass
DB_HOST=mariadb
MYSQL_DATABASE=wordpress
MYSQL_USER=wp
MYSQL_PASSWORD=wp_pass
MYSQL_ROOT_PASSWORD=root

WP_URL=https://tchevall.42.fr:8443
WP_TITLE=Inception
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=adminpass
WP_ADMIN_EMAIL=admin@tchevall.42.fr
WP_USER=editor
WP_USER_EMAIL=editor@tchevall.42.fr
WP_USER_PASSWORD=editorpass
```

---

## Build and launch

```bash
# First run — builds images and starts containers
make

# Rebuild images from scratch (no cache)
make rebuild

# Stop and remove containers (volumes preserved)
make down

# Full clean — removes containers, volumes, and local images
make fclean
```

### What `make` does internally

1. Creates host data directories: `/home/tchevall/data/mariadb` and `/home/tchevall/data/wordpress`
2. Runs `podman compose up -d --build`

---

## Container management

```bash
# View running containers
make ps

# Stream logs for a service
make logs SERVICE=mariadb
make logs SERVICE=wordpress
make logs SERVICE=nginx

# Open a shell inside a container
podman exec -it mariadb bash
podman exec -it wordpress bash

# Check MariaDB users
podman exec -it mariadb mariadb -u root -e "SELECT user, host FROM mysql.user;"

# Test HTTPS response
curl -k https://localhost:8443
```

---

## How data persists

Data is stored in named Docker/Podman volumes:

| Volume               | Mounted at (container)  | Purpose                        |
|----------------------|-------------------------|--------------------------------|
| `srcs_mariadb_data`  | `/var/lib/mysql`        | MariaDB database files         |
| `srcs_wordpress_data`| `/var/www/html`         | WordPress files (shared with nginx) |

Volumes survive `make down` but are deleted by `make fclean`.

On the host, Podman stores volume data under:
```
~/.local/share/containers/storage/volumes/
```

---

## First boot behavior

**MariaDB** (`entrypoint.sh`):
- If `/var/lib/mysql/mysql` does not exist, runs `mysql_install_db`, creates the `wordpress` database and the `wp` user, then shuts down the temporary instance.
- Starts the final instance with `exec mariadbd` (PID 1).

**WordPress** (`entrypoint.sh`):
- Waits for MariaDB to accept connections.
- If `wp-load.php` is absent, downloads WordPress core with `wp-cli`.
- If `wp-config.php` is absent, creates it and runs `wp core install`.
- Starts PHP-FPM with `exec php-fpm8.2 -F` (PID 1).

**Nginx**:
- TLS certificate generated at build time via `openssl req -x509` in the Dockerfile.
- Starts immediately, proxies PHP requests to `wordpress:9000` via FastCGI.

---

## Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `mariadb` stays `unhealthy` | Healthcheck args wrong order | Ensure `-h 127.0.0.1` comes after `ping` |
| WordPress loops "Waiting for MariaDB" | `wp` user not created | `make fclean && make` to wipe volumes |
| `podman compose` hangs on `mariadb` | podman-compose `-d` bug | Ctrl+C — containers are running, check with `podman ps` |
| 403 on `https://localhost:8443` | `/var/www/html` empty | Check `podman logs wordpress` for install errors |
| LSN identical across rebuilds | Datadir baked into image | Ensure Dockerfile has `rm -rf /var/lib/mysql/*` |
