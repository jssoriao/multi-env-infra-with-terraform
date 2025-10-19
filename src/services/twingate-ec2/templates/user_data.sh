#!/bin/bash
set -e
mkdir -p /etc/twingate/
{
    echo TWINGATE_URL="https://${TWINGATE_NETWORK}.twingate.com"
    echo TWINGATE_ACCESS_TOKEN="${TWINGATE_ACCESS_TOKEN}"
    echo TWINGATE_REFRESH_TOKEN="${TWINGATE_REFRESH_TOKEN}"
} >/etc/twingate/connector.conf
sudo systemctl enable --now twingate-connector
