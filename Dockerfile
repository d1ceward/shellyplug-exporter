FROM crystallang/crystal:1.5.0-alpine as builder

WORKDIR /app

# Cache dependencies
COPY ./shard.yml ./shard.lock /app/
RUN shards install --production -v

# Build a binary
COPY . /app/
RUN shards build --static --no-debug --release --production -v

FROM alpine:latest

WORKDIR /
COPY --from=builder /app/bin/shellyplug-exporter .

ENTRYPOINT ["/shellyplug-exporter", "run"]
