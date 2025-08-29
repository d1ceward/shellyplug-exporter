![](.github/images/shelly_plug_s.png)

# shellyplug-exporter (v1.11.3)

![GitHub Workflow Status (main)](https://github.com/d1ceward/shellyplug-exporter/actions/workflows/main.yml/badge.svg?branch=master)
[![Docker Pulls](https://img.shields.io/docker/pulls/d1ceward/shellyplug-exporter.svg?logo=docker)](https://hub.docker.com/r/d1ceward/shellyplug-exporter)
[![GHCR](https://img.shields.io/badge/GHCR-Available-blue?logo=github)](https://github.com/users/d1ceward/packages/container/package/shellyplug-exporter)
[![GitHub issues](https://img.shields.io/github/issues/d1ceward/shellyplug-exporter)](https://github.com/d1ceward/shellyplug-exporter/issues)
[![GitHub license](https://img.shields.io/github/license/d1ceward/shellyplug-exporter)](https://github.com/d1ceward/shellyplug-exporter/blob/master/LICENSE)

**Prometheus exporter for Shelly Plug S, written in Crystal.**
> **Note** Uses the plug’s HTTP API (not MQTT).

:rocket: Feature requests and suggestions are welcome, open an issue!

## Quick Start

### 1. YAML Configuration (Recommended)

Manage multiple plugs easily with a `config.yaml` file.

**Create `config.yaml`:**
```yaml
exporter_port: 5000
plugs:
  - name: plug1
    host: 192.168.33.2
    port: 80
    auth_username: user1
    auth_password: pass1
  - name: plug2
    host: 192.168.33.3
    port: 80
    auth_username: user2
    auth_password: pass2
```

**Run the exporter:**
```shell
shellyplug-exporter run --config config.yaml
```

### 2. Environment Variables (Legacy, Single Plug)

Set variables for a single plug:

- `SHELLYPLUG_HOST` (required)
- `SHELLYPLUG_PORT` (default: 80)
- `SHELLYPLUG_AUTH_USERNAME` / `SHELLYPLUG_AUTH_PASSWORD` (if needed)
- `EXPORTER_PORT` (default: 5000)

**Example:**
```shell
shellyplug-exporter run --port 5000
```

---

### 3. Docker Usage

**With `config.yaml`:**
```shell
docker run -d \
  -p 8080:5000 \
  -v $(pwd)/config.yaml:/config.yaml \
  ghcr.io/d1ceward/shellyplug-exporter:latest \
  shellyplug-exporter run --config /config.yaml
```

**docker-compose:**
```yaml
services:
  plug_exporter:
    image: ghcr.io/d1ceward/shellyplug-exporter:latest
    restart: unless-stopped
    ports:
      - 8080:5000
    volumes:
      - ./config.yaml:/config.yaml
    command: shellyplug-exporter run --config /config.yaml
```

**With environment variables:**
```shell
docker run -d \
  -p 8080:5000 \
  -e SHELLYPLUG_HOST="shelly-plug-hostname-or-ip" \
  -e SHELLYPLUG_PORT="80" \
  -e SHELLYPLUG_AUTH_USERNAME="username" \
  -e SHELLYPLUG_AUTH_PASSWORD="password" \
  -e EXPORTER_PORT=5000 \
  ghcr.io/d1ceward/shellyplug-exporter:latest
```

### 4. Linux Binary

**Download:**
```shell
wget --no-verbose -O shellyplug-exporter https://github.com/d1ceward/shellyplug-exporter/releases/download/v1.11.3/shellyplug-exporter-linux-amd64
chmod +x shellyplug-exporter
```

**Run:**
```shell
shellyplug-exporter run --port 5000
```


## Metrics

**Endpoint:** `/metrics`

| Name                   | Description                          | Type    |
|------------------------|--------------------------------------|---------|
| shellyplug_power       | Current power drawn (watts)          | Gauge   |
| shellyplug_overpower   | Overpower drawn (watts)              | Gauge   |
| shellyplug_total       | Total power consumed (watt-minutes)  | Counter |
| shellyplug_temperature | Plug temperature (°C)                | Gauge   |
| shellyplug_uptime      | Plug uptime (seconds)                | Gauge   |

**Multiple plugs:**
Metrics include a `plug` label:
```
shellyplug_power{plug="plug1"} 12.3
shellyplug_power{plug="plug2"} 8.7
```

## Contributing

Bug reports and pull requests are welcome!
By contributing, you agree to the Code of Merit.

1. Fork: [github.com/d1ceward/shellyplug-exporter](https://github.com/d1ceward/shellyplug-exporter/fork)
2. Create a branch: `git checkout -b my-new-feature`
3. Commit: `git commit -am 'Add some feature'`
4. Push: `git push origin my-new-feature`
5. Open a Pull Request

## Development

1. Install Crystal (see `.crystal-version`)
2. Install dependencies: `shards install`
3. Build: `shards build`
4. Binary: `bin/shellyplug-exporter`

**Run tests:**
```shell
crystal spec
```

## Documentation

See: [d1ceward.github.io/shellyplug-exporter](https://d1ceward.github.io/shellyplug-exporter/)

## Contributors

- [d1ceward](https://github.com/d1ceward) – creator and
