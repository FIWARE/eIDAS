FROM registry.access.redhat.com/ubi8/ubi

# Install OpenSSL
RUN yum install -y openssl

COPY script/script.sh /openssl-certs/
COPY script/config /openssl-certs/
COPY script/openssl-client.cnf /openssl-certs/
COPY script/openssl-intermediate.cnf /openssl-certs/
COPY script/openssl.cnf /openssl-certs/

# Create and set mount volume
WORKDIR /openssl-certs
VOLUME  /openssl-certs

ENTRYPOINT ["sh", "-c", "/openssl-certs/script.sh"]