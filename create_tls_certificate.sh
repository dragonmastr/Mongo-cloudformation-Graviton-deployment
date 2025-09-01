#!/bin/bash

if ! command -v openssl &> /dev/null; then
    echo "openssl command not found. Please install openssl."
    exit 1
fi


export DOMAIN=$DOMAIN
echo $DOMAIN
HOSTNAME=mongodb-env.$DOMAIN
#openssl genpkey -algorithm RSA -out ca.key
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/C=US/ST=CAL/L=CAL/O=<company-name>/OU=SRE/CN=$HOSTNAME"
#openssl genpkey -algorithm RSA -out server.key
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/C=US/ST=CAL/L=CAL/O=<Company-name>/OU=SRE/CN=$HOSTNAME"
cat > server.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $HOSTNAME
EOF
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256 -extfile server.ext
cat server.key server.crt > server.pem
openssl verify -CAfile ca.crt server.crt
