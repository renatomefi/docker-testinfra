all: build lint test scan-vulnerability

.PHONY: *

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

build:
	docker build --pull -t renatomefi/testinfra:latest .

help:
	docker run --rm -t renatomefi/testinfra:latest --help

lint:
	docker run -v ${current_dir}:/project:ro --workdir=/project --rm -t hadolint/hadolint:latest-debian hadolint Dockerfile

test:
	docker run --rm -t -v ${current_dir}/test:/tests:ro -v /var/run/docker.sock:/var/run/docker.sock:ro renatomefi/testinfra:latest

scan-vulnerability:
	docker-compose -f test/security/docker-compose.yml -p clair-ci up -d
	RETRIES=0 && while ! wget -T 10 -q -O /dev/null http://localhost:6060/v1/namespaces ; do sleep 1 ; echo -n "." ; if [ $${RETRIES} -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; RETRIES=$$(($${RETRIES}+1)) ; done
	mkdir -p ./tmp/clair/
	clair-scanner --ip 172.17.0.1 -r "./tmp/clair/%.json" -l ./tmp/clair/clair.log renatomefi/testinfra:latest
	docker-compose -f test/security/docker-compose.yml -p clair-ci down
