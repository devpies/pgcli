# pgcli

[pgcli](http://pgcli.com/) container for postgres with password urlencoding

## Getting Started

Run a container with the [postgres connection string](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING-URIS).

```bash
docker run --rm -it --network some-network devpies/pgcli postgres://user:pass@host:port/database
```

### Examples

#### Connecting from the same network

```bash
# Create network
docker network create some-network
# Run postgres
docker run --name pg-db --detach --network some-network -e POSTGRES_PASSWORD=secret -p 5432:5432 postgres:18-alpine
# Run devpies/pgcli
docker run --rm --network some-network -it devpies/pgcli postgres://postgres:secret@pg-db:5432/postgres  
```
#### Using host network 

```bash
# Run postgres
docker run --network host -d -e POSTGRES_PASSWORD=secret postgres:18-alpine
# Run devpies/pgcli
docker run --rm -it --network host devpies/pgcli postgres://postgres:secret@localhost:5432/postgres

# Or use Docker Desktop's "host.docker.internal"

# Run postgres
docker run -d -e POSTGRES_PASSWORD=secret -p 5432:5432 postgres:18-alpine
# Run devpies/pgcli
docker run --rm -it devpies/pgcli postgres://postgres:secret@host.docker.internal:5432/postgres
```


## URL Encoding Passwords If Neccessary 

`devpies/pgcli` can handle passwords in both encoded and unencoded forms, reducing the risk of connection errors due to improper encoding.

### Approach
1. The image first tries to connect using the password as provided, assuming it doesn’t need encoding. This avoids unnecessary encoding when it’s not needed. 

2. If the initial connection fails, the image then URL-encodes the password and retries the connection, ensuring that special characters in the password are correctly handled.

## Using Docker Compose

Add a service to your project's compose file and place it on the same network as the postgres container. Provide the postgres connection string as an environment variable: `CONN`.

```yaml
services:
  pgcli:
    image: devpies/pgcli
    environment:
      CONN: $CONN
    networks:
      - dbaccess
```
Then run:
```
docker compose run --rm pgcli
```

>_**Note**: You might notice with docker compose up, pgcli starts alongside your other services but exits immediately. This is normal. Containers exit when they don't have a running process to keep it alive._


## License
This project is licensed under the MIT License. See the [LICENSE file](./LICENSE) for details.
