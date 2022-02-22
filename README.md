# shellyplug-exporter (v0.1.2)
![GitHub Workflow Status (event)](https://github.com/D1ceWard/shellyplug-exporter/actions/workflows/main.yml/badge.svg?branch=master)
[![GitHub issues](https://img.shields.io/github/issues/D1ceWard/shellyplug-exporter)](https://github.com/D1ceWard/shellyplug-exporter/issues)
[![GitHub license](https://img.shields.io/github/license/D1ceWard/shellyplug-exporter)](https://github.com/D1ceWard/shellyplug-exporter/blob/master/LICENSE)

Prometheus Exporter for Shelly plugs model S

:rocket: Suggestions for new improvements are welcome in the issue tracker.

## Usage

Run with docker-compose file :
```
---
version: "3"

services:
  plug_exporter:
    image: d1ceward/shellyplug-prometheus-exporter
    restart: unless-stopped
    ports:
      - "80:8080"
    environment:
      - EXPORTER_PORT=80
      - SHELLYPLUG_HOSTNAME="shelly-plug-hostname-or-ip"
      - SHELLYPLUG_PORT=80
      - SHELLYPLUG_HTTP_USERNAME="username-for-http-auth"
      - SHELLYPLUG_HTTP_PASSWORD="password-for-http-auth"
```

Documentation available here : https://d1ceward.github.io/shellyplug-exporter/

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/D1ceWard/shellyplug-exporter. By contributing you agree to abide by the Code of Merit.

1. Fork it (<https://github.com/D1ceWard/shellyplug-exporter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [D1ceWard](https://github.com/D1ceWard) - creator and maintainer
