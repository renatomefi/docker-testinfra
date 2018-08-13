FROM alpine:3.8

# Inhibits python to write byte code cache locally
ENV PYTHONDONTWRITEBYTECODE=1

RUN apk add --no-cache docker python py-pip python-dev libffi-dev openssl-dev

RUN apk add --no-cache --virtual build-dependencies build-base gcc wget git

RUN pip install --upgrade pip

RUN pip install docker \
    && pip install paramiko \
    && pip install testinfra

RUN apk del build-dependencies build-base gcc wget git python-dev libffi-dev openssl-dev

RUN rm -rf /var/cache/apk

WORKDIR /tests

# Inhibits pytest to write tests cache
ENTRYPOINT [ "py.test", "-p" , "no:cacheprovider" ]
