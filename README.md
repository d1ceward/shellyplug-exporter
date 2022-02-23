# shellyplug-exporter (v1.1.0)
![GitHub Workflow Status (main)](https://github.com/D1ceWard/shellyplug-exporter/actions/workflows/main.yml/badge.svg?branch=master)
[![Docker Pulls](https://img.shields.io/docker/pulls/d1ceward/shellyplug-exporter.svg)](https://hub.docker.com/r/d1ceward/shellyplug-exporter)
[![GitHub issues](https://img.shields.io/github/issues/D1ceWard/shellyplug-exporter)](https://github.com/D1ceWard/shellyplug-exporter/issues)
[![GitHub license](https://img.shields.io/github/license/D1ceWard/shellyplug-exporter)](https://github.com/D1ceWard/shellyplug-exporter/blob/master/LICENSE)

Prometheus exporter for Shelly plugs model S written in Crystal.
> **Note** It uses the api provided by the plug, it does not use the MQTT protocol

:rocket: Suggestions for new improvements are welcome in the issue tracker.

## Installation and Usage

The `SHELLYPLUG_HOST` environment variable is required to retrieve information from the plug, `SHELLYPLUG_PORT` is optional (default 80).
Authentication variables `SHELLYPLUG_AUTH_USERNAME` and `SHELLYPLUG_AUTH_PASSWORD` depend on whether http authentication is enabled on the plug.

The `shellyplug-exporter` listens on HTTP port 5000 by default. See the environment variable `EXPORTER_PORT` to change this behavior.

### Docker

With `docker run` command :
```shell
docker run -d \
  -p 8080:5000 \
  -e SHELLYPLUG_HOST="shelly-plug-hostname-or-ip" \
  -e SHELLYPLUG_PORT="80" \
  -e SHELLYPLUG_AUTH_USERNAME="username-for-http-auth" \
  -e SHELLYPLUG_AUTH_PASSWORD="password-for-http-auth" \
  -e EXPORTER_PORT=5000 \
  d1ceward/shellyplug-exporter:latest
```

With docker-compose file :
```yaml
---
version: "3"

services:
  plug_exporter:
    image: d1ceward/shellyplug-exporter:latest
    restart: unless-stopped
    ports:
      - "8080:5000"
    environment:
      - SHELLYPLUG_HOST="shelly-plug-hostname-or-ip"
      - SHELLYPLUG_PORT=80
      - SHELLYPLUG_AUTH_USERNAME="username-for-http-auth"
      - SHELLYPLUG_AUTH_PASSWORD="password-for-http-auth"
      - EXPORTER_PORT=5000
```

Documentation available here : https://d1ceward.github.io/shellyplug-exporter/

## Metrics

Name                   | Description                          | Type    |
-----------------------|--------------------------------------|---------|
shellyplug_power       | Current power drawn in watts         | Gauge   |
shellyplug_overpower   | Overpower drawn in watts/minute      | Gauge   |
shellyplug_total_power | Total power consumed in watts/minute | Counter |
shellyplug_temperature | Plug temperature in celsius          | Gauge   |
shellyplug_uptime      | Plug uptime in seconds               | Gauge   |

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/D1ceWard/shellyplug-exporter. By contributing you agree to abide by the Code of Merit.

1. Fork it (<https://github.com/D1ceWard/shellyplug-exporter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Development building and running

1. Install corresponding version of Crystal lang (cf: `.crystal-version` file)
2. Install Crystal dependencies with `shards install`
3. Build with `shards build`

The newly created binary should be at `bin/shelly_exporter`

### Running tests

```shell
crystal spec
```

## Contributors

- [D1ceWard](https://github.com/D1ceWard) - creator and maintainer
