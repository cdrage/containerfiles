# Game server status

A small SvelteKit dashboard for a Steam-query-compatible game server or a
Palworld dedicated server.

## Status providers

### Steam A2S (default)

The default provider sends `A2S_INFO` and `A2S_PLAYER` requests to the standard
Steam query port. A failed player query does not mark a server offline when its
info query succeeds.

| Variable | Default | Description |
| --- | --- | --- |
| `STATUS_PROVIDER` | `steam` | Set to `steam` |
| `QUERY_HOST` | Public IP | Host queried by the dashboard |
| `QUERY_PORT` | `27015` | UDP Steam query port |
| `DISPLAY_PORT` | `27015` | Game port shown in the join address |
| `PUBLIC_HOST` | Auto-detected | Public host shown in the join address |

### Palworld

Current Palworld servers can bind the Steam query port without answering A2S
status requests. Use Palworld's authenticated REST API for reliable server and
player status:

| Variable | Default | Description |
| --- | --- | --- |
| `STATUS_PROVIDER` | Auto-selected | Set to `palworld` |
| `PALWORLD_API_URL` | Derived | API base URL, such as `http://palworld:8212/v1/api` |
| `PALWORLD_API_USERNAME` | `admin` | REST API Basic Auth username |
| `PALWORLD_API_PASSWORD` | None | REST API password (Palworld admin password) |
| `PALWORLD_API_PORT` | `8212` | Used when deriving the URL from `QUERY_HOST` |
| `DISPLAY_PORT` | `27015` | Set to the Palworld game port, normally `8211` |
| `QUERY_PORT` | `27015` | Steam query port shown by the dashboard |

`PALWORLD_API_PASSWORD` stays server-side. The dashboard returns player names,
levels, and pings, but never returns player IDs, IP addresses, or API
credentials to the browser.

Palworld must have `REST_API_ENABLED=true`, and TCP port `8212` must be reachable
from this container. Keep that API internal; do not expose it through an ingress
or public load balancer.

## Run

```sh
podman run -d \
  --name gameserver \
  -p 3000:3000 \
  -e STATUS_PROVIDER=steam \
  -e QUERY_HOST=192.168.1.100 \
  -e QUERY_PORT=27015 \
  -e DISPLAY_PORT=7777 \
  ghcr.io/cdrage/gameserver
```

For Palworld:

```sh
podman run -d \
  --name gameserver \
  -p 3000:3000 \
  -e STATUS_PROVIDER=palworld \
  -e PALWORLD_API_URL=http://palworld:8212/v1/api \
  -e PALWORLD_API_PASSWORD=change-me \
  -e DISPLAY_PORT=8211 \
  -e QUERY_PORT=27015 \
  ghcr.io/cdrage/gameserver
```
