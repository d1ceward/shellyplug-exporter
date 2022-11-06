FROM alpine:latest

COPY ./shellyplug-exporter .
RUN chmod +x /shellyplug-exporter

HEALTHCHECK --interval=30s --timeout=5s CMD curl -f https://localhost/health || exit 1

ENTRYPOINT ["/shellyplug-exporter", "run"]
