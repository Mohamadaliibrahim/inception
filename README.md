# Inception

> **42 cursus – System Administration & Docker Project**

---

## About the Project

`Inception` is a DevOps‑oriented project whose goal is to deploy a complete WordPress stack entirely with **Docker Compose**. You will build every image yourself (Alpine only), orchestrate the containers, and secure the web service with HTTPS. By the end, you will have a reproducible, single‑command deployment that respects the *12‑factor* methodology.

---

## Objectives

1. **Containerisation** – Package each service (Nginx, WordPress + PHP‑FPM, MariaDB …) inside its own Docker image built from an Alpine base.
2. **Orchestration** – Define and manage the multi‑container application with Docker Compose (v3.8).
3. **Data Persistence** – Mount named volumes on the host so that database contents and WordPress files survive container recreation.
4. **Security** – Serve the website over **HTTPS** using a self‑signed TLS certificate generated at build time.
5. **Least‑Privilege** – Run services as non‑root users and expose only the required ports (443 / 3306).
6. **Infrastructure as Code** – Provide a single `docker compose up --build -d` that spins up the entire stack.

Bonus goals include adding extras such as Redis caching, phpMyAdmin, static site hosting, FTP, etc.

---

## Architecture

```
┌──────────────┐        443/tcp         ┌─────────────────┐
│    Client    │ ─────────────────────►│     Nginx       │
└──────────────┘                        │  (reverse‑proxy)│
                                        │      │         │
                                        ▼      │ fastCGI
                               ┌─────────────────┐
                               │  WordPress +    │
                               │   PHP‑FPM       │
                               └────────┬────────┘
                                        │ 3306/tcp
                                        ▼
                               ┌─────────────────┐
                               │    MariaDB      │
                               └─────────────────┘
```

All containers share an internal **bridge network** called `inception_net`. Persistent data are written into two named volumes under `/home/$USER/data/` on the host:

* `wp_data` → WordPress uploads & plugins
* `db_data` → MariaDB databases

---

## Prerequisites

| Requirement            | Minimum Version                                  |
| ---------------------- | ------------------------------------------------ |
| **Operating System**   | Ubuntu 22.04 LTS (or any Linux with Docker ≥ 24) |
| **Docker Engine**      | 24.0                                             |
| **Docker Compose CLI** | v2.27                                            |

> **42 VM** – On the 42 evaluation VM, Docker and Docker Compose are already installed.

---

## Getting Started

### 1. Clone the repository

```bash
$ git clone https://github.com/<your‑login>/inception.git
$ cd inception
```

### 2. Create the `.env` file

Duplicate the example and fill in your own values:

```bash
$ cp .env.example .env
```

| Variable        | Description                                         |
| --------------- | --------------------------------------------------- |
| `DOMAIN_NAME`   | FQDN that points to your VM (e.g. *mibrahim.42.fr*) |
| `WP_TITLE`      | WordPress site title                                |
| `WP_ADMIN_USER` | Wordpress admin username                            |
| `WP_ADMIN_PASS` | WordPress admin password                            |
| `WP_ADMIN_MAIL` | Admin e‑mail address                                |
| `DB_ROOT_PASS`  | MariaDB root password                               |
| `DB_USER`       | WordPress DB user                                   |
| `DB_USER_PASS`  | Password for the above                              |
| `DB_NAME`       | WordPress database name                             |

> Never commit your real `.env` file – it is listed in `.gitignore` by default.

### 3. Build & Run

```bash
$ docker compose up --build -d   # first time or after dockerfile changes
$ docker compose ps              # view running containers
```

Navigate to `https://localhost/` (or `https://$DOMAIN_NAME`) and complete the WordPress installation wizard.

---

## Project Structure

```
.
├── docker-compose.yml
├── .env.example
├── requirements
│   ├── nginx
│   │   ├── Dockerfile
│   │   └── conf
│   │       └── default.conf
│   ├── wordpress
│   │   ├── Dockerfile
│   │   └── tools
│   │       └── setup.sh
│   └── mariadb
│       └── Dockerfile
└── README.md
```

Each service has its own folder inside `requirements/` containing a minimal Alpine‑based `Dockerfile` and any configuration or entrypoint scripts it needs.

---

## Services

| Service       | Image Built From         | Port(s)         | Purpose                         |
| ------------- | ------------------------ | --------------- | ------------------------------- |
| **nginx**     | `requirements/nginx`     | 443             | TLS termination & reverse proxy |
| **wordpress** | `requirements/wordpress` | – (via fastCGI) | PHP‑FPM application             |
| **mariadb**   | `requirements/mariadb`   | 3306            | Relational database             |

`restart: unless-stopped` is set for every container to ensure resiliency.

---

## Volumes

| Volume    | Host Path                    | Container Mount Point |
| --------- | ---------------------------- | --------------------- |
| `db_data` | `/home/$USER/data/mariadb`   | `/var/lib/mysql`      |
| `wp_data` | `/home/$USER/data/wordpress` | `/var/www/html`       |

Running `docker volume ls` should display both named volumes.

---

## Networks

A single custom bridge network keeps inter‑service traffic isolated:

```yaml
docker‑compose.yml:
  networks:
    inception_net:
      driver: bridge
```

Only Nginx’s 443 port is exposed to the host.

---

## Usage

| Action            | Command                             |
| ----------------- | ----------------------------------- |
| View logs         | `docker compose logs -f`            |
| Enter a container | `docker compose exec wordpress sh`  |
| Stop the stack    | `docker compose down`               |
| Prune everything  | `docker system prune -af --volumes` |

---

## Administration

Once WordPress is configured you can:

* Install/update plugins & themes (persist in `wp_data`).
* Access the database with `mysql -u$DB_USER -p$DB_USER_PASS -h mariadb` from inside the `wordpress` container.

*For production you would swap the self‑signed cert with Let’s Encrypt.*

---

## Back‑ups & Restore

```bash
# back‑up database
$ docker compose exec mariadb mysqldump -u root -p$DB_ROOT_PASS $DB_NAME > backup.sql

# restore database
$ docker compose exec -T mariadb mysql -u root -p$DB_ROOT_PASS $DB_NAME < backup.sql
```

Volumes can also be archived directly from `/home/$USER/data/`.

---

## Troubleshooting

| Symptom                    | Possible Cause                                              |
| -------------------------- | ----------------------------------------------------------- |
| *502 Bad Gateway*          | WordPress container not ready / incorrect fastCGI pass      |
| *ERR\_CONNECTION\_REFUSED* | Nginx not listening on 443 or firewall blocking             |
| Database connection error  | Wrong credentials in `wp-config.php` or MariaDB not running |

Run `docker compose ps` and inspect individual logs to isolate issues.

---

## Evaluation Checklist

* [x] **No root processes** inside containers
* [x] **Only Alpine** images used
* [x] **Dockerfile** for each service
* [x] **Volumes** mounted on host
* [x] **TLS** enabled (self‑signed)
* [x] **Subject assets** are stored in `/home/$USER/data/`
* [x] `docker compose up --build -d` works without manual steps

