#!/usr/bin/env bash
set -euo pipefail

CN="www.googleapis.com"
DAYS=730
KEY_FILE="${CN}.key"
CRT_FILE="${CN}.crt"
CONFIG_FILE="openssl-san.cnf"

cat > "$CONFIG_FILE" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
CN = $CN

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $CN
EOF

openssl req -x509 -nodes -days $DAYS \
  -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CRT_FILE" \
  -config "$CONFIG_FILE"

echo "Generated certificate and key:"
echo "  Certificate: $CRT_FILE"
echo "  Key:         $KEY_FILE"
echo "  Config:      $CONFIG_FILE"
