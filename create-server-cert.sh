#!/bin/bash
DNSNAME=${1:-default.lab}
SERIALNR=${2:-1122}
ALTNAME="DNS.1:$DNSNAME,DNS.2:localhost"

source envsettings

# gen key
if [ -f "intermediate/private/$DNSNAME.pem" ]; then
    echo skipping keygen, already exists
else
    openssl genrsa -aes256 -passout pass:$PASSPHRASE -out intermediate/private/$DNSNAME.pem 2048
    chmod 400 intermediate/private/$DNSNAME.pem
fi

# gen csr
openssl req -new -sha256 \
    -key intermediate/private/$DNSNAME.pem \
    -passin pass:$PASSPHRASE \
    -subj "/CN=$DNSNAME/O=$CERT_O/L=$CERT_L/ST=$CERT_ST/C=$CERT_C/serialNumber=$SERIALNR" \
    -reqexts SAN -extensions SAN -config <(cat intermediate/openssl.conf <(printf "[SAN]\nsubjectAltName=$ALTNAME")) \
    -out intermediate/csr/$DNSNAME.csr.pem

# sign cert
openssl ca -config intermediate/openssl.conf \
    -extensions server_cert -days 375 -notext -md sha256 -batch \
    -passin pass:$PASSPHRASE \
    -in intermediate/csr/$DNSNAME.csr.pem \
    -out intermediate/certs/$DNSNAME.pem

openssl x509 -noout -text -in intermediate/certs/$DNSNAME.pem

# export as p12 with ca chain
openssl pkcs12 -export -out $DNSNAME.p12 \
    -passin pass:$PASSPHRASE \
    -passout pass:$PASSPHRASE \
    -inkey intermediate/private/$DNSNAME.pem \
    -in intermediate/certs/$DNSNAME.pem \
    -chain -CAfile intermediate/certs/ca-chain.cert.pem