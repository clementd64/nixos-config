FROM stagex/core-filesystem
COPY --from=stagex/core-ca-certificates . /
COPY --from=ghcr.io/openbao/openbao /bin/bao /usr/bin/bao
COPY config.hcl /app/config.hcl
ENTRYPOINT [ "bao", "server", "-config", "/app/config.hcl" ]
