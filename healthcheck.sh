#!/bin/sh
# Docker healthcheck for shellyplug-exporter
# Reads exporter port from /run/shellyplug-exporter.info if present, else defaults to 5000

INFO_FILE="/run/shellyplug-exporter.info"
PORT="5000"

if [ -f "$INFO_FILE" ]; then
  EXTRACTED_PORT=$(grep '^EXPORTER_PORT=' "$INFO_FILE" | cut -d'=' -f2)
  if [ -n "$EXTRACTED_PORT" ]; then
    PORT="$EXTRACTED_PORT"
  fi
fi

curl -fs --max-time 5 "http://localhost:${PORT}/health" || exit 1
