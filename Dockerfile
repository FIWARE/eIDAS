FROM alpine:latest

# Install OpenSSL
RUN apk update && \
  apk add --no-cache openssl && \
  rm -rf "/var/cache/apk/*"

COPY script/script.sh /openssl-certs/
COPY script/config /openssl-certs/
COPY script/openssl-client.cnf /openssl-certs/
COPY script/openssl-intermediate.cnf /openssl-certs/
COPY script/openssl.cnf /openssl-certs/


WORKDIR /openssl-certs

ENTRYPOINT ["sh", "-c", "./script.sh"]