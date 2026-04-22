# Platform Dev Setup

Local development environment running PostgreSQL, Keycloak, and Kafka as a single Docker Compose project.

## Prerequisites

- Docker with the Compose plugin

## Usage

### Starting services

```bash
./up.sh
```

On first run, `components.template` is copied to `components`. Edit `components` to control which services are started — one service name per line.

### Stopping services

```bash
./down.sh
```

### Available services

| Service    | Default port | Description              |
|------------|-------------|--------------------------|
| `postgres` | 5432        | PostgreSQL 18            |
| `keycloak` | 2305        | Keycloak 26 (HTTP)       |
| `kafka`    | 9092        | Kafka 4 (KRaft, no ZK)   |

To start only a subset, edit `components`:

```
postgres
keycloak
```

## PostgreSQL

Credentials: `dockers / dockers`, default database: `dockers`.

Connect via psql:

```bash
docker exec -it postgres psql -U dockers -d dockers
```

The `keycloak` database is created automatically on first initialization.

> If the volume already exists without the `keycloak` database, create it manually:
> ```bash
> docker exec postgres psql -U dockers -c "CREATE DATABASE keycloak;"
> ```

### Resetting the PostgreSQL volume

```bash
docker compose down
docker volume rm platform-dev-setup_db-data
./up.sh
```

## Keycloak

Admin console: http://localhost:2305 (credentials: `admin / admin`)

Keycloak requires PostgreSQL — include `postgres` in `components` whenever `keycloak` is active.

### Automated configuration

Run `start.sh` after `up.sh` to apply the Ansible-based configuration:

```bash
./up.sh
./start.sh
```

`start.sh` waits for Keycloak to be ready, then runs the playbook inside an `alpine/ansible` container on `shared_net`. The playbook is idempotent — safe to re-run.

**What it configures:**

- Creates the `platform` realm
- Enables user self-registration
- Activates the `platform` login theme

Playbook: `ansible/playbooks/configure-keycloak.yml`

### Custom theme

A custom login theme is mounted from `src/keycloak-theme/` into the `platform` theme slot. The background image is at `src/keycloak-theme/login/resources/img/background.png`.

## Kafka

Single-node KRaft cluster (no ZooKeeper).

| Listener    | Address         | Reachable from              |
|-------------|----------------|-----------------------------|
| `HOST`      | `localhost:9092` | Host machine               |
| `PLAINTEXT` | `kafka:9092`    | Other containers on `shared_net` |

## Networking

All containers share the `shared_net` bridge network (`172.30.200.0/24`), allowing inter-container communication by service name.
