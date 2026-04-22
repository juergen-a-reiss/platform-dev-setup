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

**First-time setup:**

1. Replace the temporary admin user (master realm, role `admin`)
2. Create a realm `platform`
3. Create a user and set the token TTL to 1000 minutes in realm settings

Keycloak requires PostgreSQL — include `postgres` in `components` whenever `keycloak` is active.

### Custom theme

A custom login theme is mounted from `src/keycloak-theme/` and applied to the `platform` theme slot. To activate it, set the theme to `platform` in the Keycloak admin console under **Realm settings → Themes → Login theme**.

The background image is at `src/keycloak-theme/login/resources/img/background.png`.

## Kafka

Single-node KRaft cluster (no ZooKeeper).

| Listener    | Address         | Reachable from              |
|-------------|----------------|-----------------------------|
| `HOST`      | `localhost:9092` | Host machine               |
| `PLAINTEXT` | `kafka:9092`    | Other containers on `shared_net` |

## Networking

All containers share the `shared_net` bridge network (`172.30.200.0/24`), allowing inter-container communication by service name.
