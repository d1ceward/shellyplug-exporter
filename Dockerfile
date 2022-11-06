FROM alpine:latest

RUN apk --no-cache add curl

COPY ./shellyplug-exporter .
RUN chmod +x /shellyplug-exporter

HEALTHCHECK --interval=30s --timeout=5s CMD curl -f "http://localhost:${EXPORTER_PORT:-5000}/health" || exit 1

ENTRYPOINT ["/shellyplug-exporter", "run"]
