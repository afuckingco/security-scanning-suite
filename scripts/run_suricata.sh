#!/usr/bin/env bash
set -euo pipefail
# Pull latest Suricata image (if not present)
docker pull jasonish/suricata:latest
# Run Suricata on a temporary network interface (eth0 inside container)
# Mount a local folder for logs (you can adjust the path)
mkdir -p "$(pwd)/suricata/log"
# Example minimal config; you may replace with your own suricata.yaml
# Here we just run default configuration, assuming the image includes a default rule set.
# Logs will be written to /var/log/suricata/evts.json inside the container.

docker run --rm \
  -v "$(pwd)/suricata:/etc/suricata" \
  -v "$(pwd)/suricata/log:/var/log/suricata" \
  jasonish/suricata -c /etc/suricata/suricata.yaml -i eth0
