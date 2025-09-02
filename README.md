![](.github/images/shelly_plug_s.png)

# shellyplug-exporter (v2.0.1)

![GitHub Workflow Status (main)](https://github.com/d1ceward/shellyplug-exporter/actions/workflows/main.yml/badge.svg?branch=master)
[![Docker Pulls](https://img.shields.io/docker/pulls/d1ceward/shellyplug-exporter.svg?logo=docker)](https://hub.docker.com/r/d1ceward/shellyplug-exporter)
[![GHCR](https://img.shields.io/badge/GHCR-Available-blue?logo=github)](https://github.com/users/d1ceward/packages/container/package/shellyplug-exporter)
[![GitHub issues](https://img.shields.io/github/issues/d1ceward/shellyplug-exporter)](https://github.com/d1ceward/shellyplug-exporter/issues)
[![GitHub license](https://img.shields.io/github/license/d1ceward/shellyplug-exporter)](https://github.com/d1ceward/shellyplug-exporter/blob/master/LICENSE)

**Prometheus exporter for Shelly Plug S, written in Crystal.**
> **Note** Uses the plug’s HTTP API (not MQTT).

:rocket: Feature requests and suggestions are welcome, open an issue!

## Quick Start

###  Step 1. Configure Your Plugs

Create a config.yaml to manage one or more plugs:

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

### Step 2. Run exporter

#### With docker

Directly using your config file:
```bash
docker run -d \
  -p 8080:5000 \
  -v $(pwd)/config.yaml:/config.yaml \
  ghcr.io/d1ceward/shellyplug-exporter:latest \
  shellyplug-exporter run --config /config.yaml
```

Or with docker-compose:
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

#### With binary

Using your config file:
```bash
shellyplug-exporter run --config config.yaml
```

### Legacy environment variables (Single Plug, Not recommended)

If you want to run with environment variables (for a single plug), you can use the following variables:
- `SHELLYPLUG_HOST` (required): IP address or hostname of the Shelly Plug S
- `SHELLYPLUG_PORT` (optional, default: 80): Port of the Shelly Plug S
- `SHELLYPLUG_AUTH_USERNAME` (optional): Username for HTTP Basic Auth
- `SHELLYPLUG_AUTH_PASSWORD` (optional): Password for HTTP Basic Auth
- `EXPORTER_PORT` (optional, default: 5000): Port for the exporter to listen on

Example with docker:
```bash
docker run -d \
  -p 8080:5000 \
  -e SHELLYPLUG_HOST="192.168.33.2" \
  -e SHELLYPLUG_PORT="80" \
  -e SHELLYPLUG_AUTH_USERNAME="user1" \
  -e SHELLYPLUG_AUTH_PASSWORD="pass1" \
  -e EXPORTER_PORT=5000 \
  ghcr.io/d1ceward/shellyplug-exporter:latest
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

- [d1ceward](https://github.com/d1ceward) – creator and maintainer
