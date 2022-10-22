FROM alpine:latest

COPY ./shellyplug-exporter .
RUN chmod +x /shellyplug-exporter

ENTRYPOINT ["/shellyplug-exporter", "run"]
