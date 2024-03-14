set -x
set -e

## export values from config file
set -o allexport
source config
set +o allexport


echo -n "" > index.txt

mkdir -p private
mkdir -p certs
openssl genrsa -out private/cakey.pem 4096
## Create CA Request
openssl req -new -x509 -set_serial 01 -days 3650 -config ./openssl.cnf -extensions v3_ca \
  -key private/cakey.pem -out certs/cacert.pem -subj "/C=DE/ST=Berlin/L=Berlin/O=FIWARE CA/CN=FIWARE-CA/emailAddress=ca@fiware.org/serialNumber=01"
## Convert x509 CA cert
openssl x509 -in certs/cacert.pem -out certs/cacert.pem -outform PEM
## Verify CA Cert
openssl x509 -noout -text -in certs/cacert.pem

# Intermediate
mkdir -p ./intermediate/private
openssl genrsa -out ./intermediate/private/intermediate.cakey.pem 4096
mkdir -p ./intermediate/csr
openssl req -new -sha256 -set_serial 02 -config ./intermediate/openssl.cnf \
  -subj "/C=DE/ST=Berlin/L=Berlin/O=FIWARE CA/CN=FIWARE-CA/emailAddress=ca@fiware.org/serialNumber=02" \
  -key ./intermediate/private/intermediate.cakey.pem \
  -out ./intermediate/csr/intermediate.csr.pem

mkdir -p intermediate/certs
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 2650 -notext \
  -batch -in intermediate/csr/intermediate.csr.pem \
  -out intermediate/certs/intermediate.cacert.pem

openssl x509 -in intermediate/certs/intermediate.cacert.pem -out intermediate/certs/intermediate.cacert.pem -outform PEM

openssl x509 -noout -text -in intermediate/certs/intermediate.cacert.pem

cat intermediate/certs/intermediate.cacert.pem certs/cacert.pem > intermediate/certs/ca-chain-bundle.cert.pem
openssl verify -CAfile certs/cacert.pem intermediate/certs/ca-chain-bundle.cert.pem


# Client
openssl genrsa -out ./client/client.key.pem 4096
openssl req -new -set_serial 03 -key ./client/client.key.pem -out ./client/client.csr \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANISATION/CN=$COMMON_NAME/emailAddress=$EMAIL/serialNumber=03/organizationIdentifier=$ORGANISATION_IDENTIFIER" \
  -config client/client_cert_ext.cnf
openssl x509 -req -in ./client/client.csr -CA ./intermediate/certs/ca-chain-bundle.cert.pem \
  -CAkey ./intermediate/private/intermediate.cakey.pem -out ./client/client.cert.pem \
  -CAcreateserial -days 1825 -sha256 -extfile ./client/client_cert_ext.cnf

openssl x509 -in client/client.cert.pem -out client/client.cert.pem -outform PEM

## Verify
openssl rsa -noout -text -in ./client/client.key.pem
openssl req -noout -text -in ./client/client.csr
openssl x509 -noout -text -in ./client/client.cert.pem