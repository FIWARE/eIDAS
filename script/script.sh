set -x
set -e

## export values from config file
set -o allexport
source config
set +o allexport


echo -n "" > index.txt
echo -n "01" > serial

mkdir -p ca/private
mkdir -p ca/csr
mkdir -p ca/certs
openssl genrsa -out ca/private/cakey.pem 4096
## Create CA Request
openssl req -new -x509 -set_serial 01 -days 3650 -config ./openssl.cnf -extensions v3_ca \
  -key ca/private/cakey.pem -out ca/csr/cacert.pem -subj "/C=DE/ST=Berlin/L=Berlin/O=FIWARE CA/CN=FIWARE-CA/emailAddress=ca@fiware.org/serialNumber=01"
## Convert x509 CA cert
openssl x509 -in ca/csr/cacert.pem -out ca/certs/cacert.pem -outform PEM
## Verify CA Cert
openssl x509 -noout -text -in ca/certs/cacert.pem

# Intermediate
mkdir -p ./intermediate/private
mkdir -p ./intermediate/csr
mkdir -p intermediate/certs

openssl genrsa -out ./intermediate/private/intermediate.cakey.pem 4096
openssl req -new -sha256 -set_serial 02 -config ./openssl-intermediate.cnf \
  -subj "/C=DE/ST=Berlin/L=Berlin/O=FIWARE CA/CN=FIWARE-CA/emailAddress=ca@fiware.org/serialNumber=02" \
  -key ./intermediate/private/intermediate.cakey.pem \
  -out ./intermediate/csr/intermediate.csr.pem

openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 2650 -notext \
  -batch -in intermediate/csr/intermediate.csr.pem \
  -out intermediate/certs/intermediate.cacert.pem

openssl x509 -in intermediate/certs/intermediate.cacert.pem -out intermediate/certs/intermediate.cacert.pem -outform PEM

openssl x509 -noout -text -in intermediate/certs/intermediate.cacert.pem

cat intermediate/certs/intermediate.cacert.pem ca/certs/cacert.pem > intermediate/certs/ca-chain-bundle.cert.pem
openssl verify -CAfile ca/certs/cacert.pem intermediate/certs/ca-chain-bundle.cert.pem


# Client
mkdir -p client/private
mkdir -p client/csr
mkdir -p client/certs

openssl genrsa -out ./client/private/client.key.pem 4096
openssl req -new -set_serial 03 -key ./client/private/client.key.pem -out ./client/csr/client.csr \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANISATION/CN=$COMMON_NAME/emailAddress=$EMAIL/serialNumber=03/organizationIdentifier=$ORGANISATION_IDENTIFIER" \
  -config ./openssl-client.cnf
openssl x509 -req -in ./client/csr/client.csr -CA ./intermediate/certs/ca-chain-bundle.cert.pem \
  -CAkey ./intermediate/private/intermediate.cakey.pem -out ./client/certs/client.cert.pem \
  -CAcreateserial -days 1825 -sha256 -extfile ./openssl-client.cnf \
  -copy_extensions=copyall

openssl x509 -in client/certs/client.cert.pem -out client/certs/client.cert.pem -outform PEM

## Verify
openssl rsa -noout -text -in ./client/private/client.key.pem
openssl req -noout -text -in ./client/csr/client.csr
openssl x509 -noout -text -in ./client/certs/client.cert.pem