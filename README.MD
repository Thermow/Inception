*This project has been created as part of the 42 curriculum by tchevall.*

# Inception

## Description
The **Inception** project is an introduction to system administration using Docker. The goal is to build a robust, multi-container infrastructure to host a LEMP stack (Linux, Nginx, MariaDB, PHP-FPM) and a static website, all orchestrated via **Docker Compose**.

This project emphasizes the containerization of services, ensuring that each component runs in its own isolated environment while communicating securely across a private network.

### Design Choices & Concepts
This project relies on Docker to encapsulate services into images. Below is a comparison of key concepts implemented:

* **Virtual Machines vs Docker**: VMs virtualize the hardware and require a full Guest OS (heavy), whereas Docker virtualizes the OS, sharing the host kernel (lightweight and faster start time).
* **Secrets vs Environment Variables**: Environment variables can be leaked (e.g., via process logs or command history). Docker Secrets provide a secure way to inject sensitive data (like database passwords) directly into container memory.
* **Docker Network vs Host Network**: Docker networks provide isolated bridge networks for internal communication. Host networking removes this isolation by sharing the host’s network stack, which is less secure but potentially faster.
* **Docker Volumes vs Bind Mounts**: Volumes are managed by Docker and stored in a specific location on the host, making them the standard for persistent data. Bind mounts map any path on the host to the container, which is useful for development but less portable.

---

## Instructions

### Prerequisites
* Docker
* Docker Compose

### Execution
1.  **Clone the repository:**
    ```bash
    git clone <repository_url> inception
    cd inception
    ```

2.  **Configuration:**
    Ensure your `.env` file is configured with the necessary credentials (DB_NAME, DB_USER, etc.) and that your local `/etc/hosts` file maps the required domain name to `127.0.0.1`.

3.  **Run the project:**
    ```bash
    docker-compose up --build
    ```

4.  **Access:**
    The services will be available on the ports defined in your configuration.

---

## Resources

### Documentation
* [Docker Documentation](https://docs.docker.com/)
* [NGINX Official Docs](https://nginx.org/en/docs/)
* [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

### AI Usage
AI tools were used during this project for:
* **Debugging:** Identifying configuration conflicts between PHP-FPM and Nginx.
* **Documentation:** Drafting technical comparisons between Docker networking modes and storage types.
* **Syntax Optimization:** Refining `Dockerfile` commands to minimize image layer size and improve security.

## Project Structure
The project is organized to separate concerns for each service:

.
├── Makefile
├── README.MD
└── srcs
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── 50-server.cnf
        │   ├── Dockerfile
        │   └── entrypoint.sh
        ├── nginx
        │   ├── Dockerfile
        │   └── nginx.conf
        └── wordpress
            ├── Dockerfile
            ├── entrypoint.sh
            └── www.conf