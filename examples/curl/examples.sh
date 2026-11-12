#!/usr/bin/env bash
# Fusion Proxy residential proxies with cURL.
# export FUSION_USER=... FUSION_PASS=... [FUSION_COUNTRY=us]
set -euo pipefail
: "${FUSION_USER:?set FUSION_USER}" "${FUSION_PASS:?set FUSION_PASS}"
COUNTRY="${FUSION_COUNTRY:-us}"
HOST="resi.fusionproxy.net"

echo "1. Rotating IP in $COUNTRY (new IP on every request)"
curl -s -x "http://$HOST:12286" -U "$FUSION_USER-country-$COUNTRY:$FUSION_PASS" https://ipinfo.io/json
echo

echo "2. Sticky session: the same session ID keeps the same IP for 10 minutes"
SESSION=$RANDOM$RANDOM
for i in 1 2; do
  curl -s -x "http://$HOST:12286" -U "$FUSION_USER-country-$COUNTRY-sessid-$SESSION-sessTime-600s:$FUSION_PASS" https://ipinfo.io/ip
  echo
done

echo "3. SOCKS5 (socks5h resolves DNS on the proxy side)"
curl -s -x "socks5h://$HOST:5390" -U "$FUSION_USER-country-$COUNTRY:$FUSION_PASS" https://ipinfo.io/json
echo
