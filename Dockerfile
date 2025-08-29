FROM alpine:latest AS builder

ARG TARGETPLATFORM

WORKDIR /
COPY ./shellyplug-exporter-linux-amd64/shellyplug-exporter-linux-amd64 .
COPY ./shellyplug-exporter-linux-arm64/shellyplug-exporter-linux-arm64 .

RUN export BINARY_PLATFORM="$(echo $TARGETPLATFORM | sed "s#/#-#g")" && \
    mv "./shellyplug-exporter-${BINARY_PLATFORM}" ./shellyplug-exporter

FROM alpine:latest

RUN apk --no-cache add curl

WORKDIR /

COPY ./LICENSE .
COPY --from=builder ./shellyplug-exporter .
COPY ./healthcheck.sh /healthcheck.sh
RUN chmod +x /shellyplug-exporter /healthcheck.sh

HEALTHCHECK --interval=30s --timeout=5s CMD /healthcheck.sh

ENTRYPOINT ["/shellyplug-exporter", "run"]
