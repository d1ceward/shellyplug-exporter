![](.github/images/shelly_plug_s.png)

# shellyplug-exporter (v1.11.3)
![GitHub Workflow Status (main)](https://github.com/d1ceward/shellyplug-exporter/actions/workflows/main.yml/badge.svg?branch=master)
[![Docker Pulls](https://img.shields.io/docker/pulls/d1ceward/shellyplug-exporter.svg?logo=docker)](https://hub.docker.com/r/d1ceward/shellyplug-exporter)
[![GHCR](https://img.shields.io/badge/GHCR-Available-blue?logo=github)](https://github.com/users/d1ceward/packages/container/package/shellyplug-exporter)
[![GitHub issues](https://img.shields.io/github/issues/d1ceward/shellyplug-exporter)](https://github.com/d1ceward/shellyplug-exporter/issues)
[![GitHub license](https://img.shields.io/github/license/d1ceward/shellyplug-exporter)](https://github.com/d1ceward/shellyplug-exporter/blob/master/LICENSE)

Prometheus exporter for Shelly plugs model S written in Crystal.
> **Note** It uses the api provided by the plug, it does not use the MQTT protocol

:rocket: Suggestions for new improvements are welcome in the issue tracker.

## Installation and Usage

### Recommended: YAML Configuration

It is recommended to use a `config.yaml` file to manage one or more Shelly plugs. This approach is more flexible and easier to maintain than environment variables or CLI flags.

1. Create a `config.yaml` file in your project root (see example below).
2. Start the exporter using:

```shell
shellyplug-exporter run --config config.yaml
```

#### Example config.yaml

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

### Legacy: Environment Variables

You can still use environment variables for single plug setups:

- `SHELLYPLUG_HOST` (required)
- `SHELLYPLUG_PORT` (optional, default 80)
- `SHELLYPLUG_AUTH_USERNAME` and `SHELLYPLUG_AUTH_PASSWORD` (if HTTP auth enabled)
- `EXPORTER_PORT` (default 5000)

Example:

```shell
shellyplug-exporter run --port 5000
```

### Docker (with config.yaml)

To use a custom `config.yaml` file with Docker, mount it as a volume:

```shell
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

### Docker (with Environment Variables)

With `docker run` command :
```shell
docker run -d \
  -p 8080:5000 \
  -e SHELLYPLUG_HOST="shelly-plug-hostname-or-ip" \
  -e SHELLYPLUG_PORT="80" \
  -e SHELLYPLUG_AUTH_USERNAME="username-for-http-auth" \
  -e SHELLYPLUG_AUTH_PASSWORD="password-for-http-auth" \
  -e EXPORTER_PORT=5000 \
  ghcr.io/d1ceward/shellyplug-exporter:latest # Or with Docker Hub: d1ceward/shellyplug-exporter:latest
```

With docker-compose file :
```yaml
---
services:
  plug_exporter:
    image: ghcr.io/d1ceward/shellyplug-exporter:latest # Or with Docker Hub: d1ceward/shellyplug-exporter:latest
    restart: unless-stopped
    ports:
      - 8080:5000
    environment:
      SHELLYPLUG_HOST: shelly-plug-hostname-or-ip
      SHELLYPLUG_PORT: 80
      SHELLYPLUG_AUTH_USERNAME: username-for-http-auth
      SHELLYPLUG_AUTH_PASSWORD: password-for-http-auth
      EXPORTER_PORT: 5000
```

### Linux

Download the executable file :
```shell
wget --no-verbose -O shellyplug-exporter https://github.com/d1ceward/shellyplug-exporter/releases/download/v1.11.3/shellyplug-exporter-linux-amd64
```

Modify the executable's permissions :
```shell
chmod +x shellyplug-exporter
```

Execution example :
```shell
shellyplug-exporter run --port 5000
```

Documentation available here : https://d1ceward.github.io/shellyplug-exporter/

## Metrics

Base path: `/metrics`

Name                   | Description                          | Type    |
-----------------------|--------------------------------------|---------|
shellyplug_power       | Current power drawn in watts         | Gauge   |
shellyplug_overpower   | Overpower drawn in watts             | Gauge   |
shellyplug_total       | Total power consumed in watt-minute  | Counter |
shellyplug_temperature | Plug temperature in celsius          | Gauge   |
shellyplug_uptime      | Plug uptime in seconds               | Gauge   |

When using multiple plugs via YAML, metrics are exposed for each plug with the plug name as a label:

```
shellyplug_power{plug="plug1"} 12.3
shellyplug_power{plug="plug2"} 8.7
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/d1ceward/shellyplug-exporter. By contributing you agree to abide by the Code of Merit.

1. Fork it (<https://github.com/d1ceward/shellyplug-exporter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Development building and running

1. Install corresponding version of Crystal lang (cf: `.crystal-version` file)
2. Install Crystal dependencies with `shards install`
3. Build with `shards build`

The newly created binary should be at `bin/shellyplug-exporter`

### Running tests

```shell
crystal spec
```

## Contributors

- [d1ceward](https://github.com/d1ceward) - creator and maintainer
