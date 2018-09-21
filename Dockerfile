FROM alpine:3.8

# Inhibits python to write byte code cache locally
ENV PYTHONDONTWRITEBYTECODE=1

RUN set -xe \
    && apk add --no-cache docker python py-pip \
    && apk add --no-cache --virtual build-dependencies build-base gcc wget git python-dev libffi-dev libressl-dev

RUN set -xe \
    && pip install --upgrade pip \
    && pip install docker \
    && pip install paramiko \
    && pip install testinfra \
    && apk del build-dependencies \
    && rm -rf /var/cache/apk

WORKDIR /tests

# Inhibits pytest to write tests cache
ENTRYPOINT ["py.test", "-p", "no:cacheprovider"]
