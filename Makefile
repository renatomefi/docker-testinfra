all: lint build test scan-vulnerability

.PHONY: *

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

check-latest:
	docker build -t renatomefi/docker-testinfra:latest-build .
	docker run --rm -it renatomefi/docker-testinfra:latest-build -v | grep testinfra- | cut -d- -f2 > ./tmp/tag.latest
	docker run --rm -it renatomefi/docker-testinfra:latest -v | grep testinfra- | cut -d- -f2 > ./tmp/tag.repo.latest
	diff ./tmp/tag.latest ./tmp/tag.repo.latest

build:
	rm -f ./tmp/tags.list
	./build.sh 1.16.0 1.16 1 latest
	./build.sh 1.15.0 1.15
	./build.sh 1.14.1 1.14

push: ./tmp/tags.list
	cat ./tmp/tags.list | xargs -I % sh -c 'docker push %'

help:
	docker run --rm -t renatomefi/docker-testinfra:latest --help

lint:
	docker run -v ${current_dir}:/project:ro --workdir=/project --rm -t hadolint/hadolint:latest-debian hadolint Dockerfile

test: ./tmp/tags.list
	cat ./tmp/tags.list | xargs -I % sh -c 'docker run --rm -t -v ${current_dir}/test:/tests:ro -v /var/run/docker.sock:/var/run/docker.sock:ro %'

download-tags:
	docker pull -a renatomefi/docker-testinfra
	docker images -f "reference=renatomefi/docker-testinfra:*" --format "{{.Repository}}:{{.Tag}}" > ./tmp/tags.list

scan-vulnerability: ./tmp/tags.list
	docker-compose -f test/security/docker-compose.yml -p clair-ci up -d
	RETRIES=0 && while ! wget -T 10 -q -O /dev/null http://localhost:6060/v1/namespaces ; do sleep 1 ; echo -n "." ; if [ $${RETRIES} -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; RETRIES=$$(($${RETRIES}+1)) ; done
	cat ./tmp/tags.list | xargs -I % sh -c 'clair-scanner --ip 172.17.0.1 -r "./tmp/clair/%.json" -l ./tmp/clair/clair.log %'; \
	docker-compose -f test/security/docker-compose.yml -p clair-ci down

ci-scan-vulnerability: ./tmp/tags.list
	docker-compose -f test/security/docker-compose.yml -p clair-ci up -d
	RETRIES=0 && while ! wget -T 10 -q -O /dev/null http://localhost:6060/v1/namespaces ; do sleep 1 ; echo -n "." ; if [ $${RETRIES} -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; RETRIES=$$(($${RETRIES}+1)) ; done
	cat ./tmp/tags.list | xargs -I % sh -c 'clair-scanner --ip 172.17.0.1 -r "./tmp/clair/%.json" -l ./tmp/clair/clair.log %'
