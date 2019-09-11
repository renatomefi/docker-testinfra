all: lint build test scan-vulnerability check-latest

.PHONY: *

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

export DOCKER_BUILDKIT=1

check-latest:
	docker build -t renatomefi/docker-testinfra:latest-build -f Dockerfile-python3 .
	docker run --rm -it renatomefi/docker-testinfra:latest-build -v | grep testinfra- | cut -d- -f2 > ./tmp/tag.latest
	docker run --rm -it renatomefi/docker-testinfra:latest -v | grep testinfra- | cut -d- -f2 > ./tmp/tag.repo.latest
	diff ./tmp/tag.latest ./tmp/tag.repo.latest

build:
	>./tmp/tags.list
	./build.sh python3 3.2.0 3.2.0 3.2 3 latest
	./build.sh python3 2.1.0 2.1.0 2.1 2
	./build.sh python3 2.0.0 2.0.0 2.0
	./build.sh python3 1.19.0 1.19.0-python3 1.19-python3 1-python3
	./build.sh python2 1.19.0 1.19.0 1.19 1
	./build.sh python2 1.18.0 1.18.0 1.18
	./build.sh python2 1.17.0 1.17.0 1.17
	./build.sh python2 1.16.0 1.16.0 1.16
	./build.sh python2 1.15.0 1.15.0 1.15
	./build.sh python2 1.14.1 1.14.1 1.14

push: ./tmp/tags.list
	cat ./tmp/tags.list | xargs -I % sh -c 'docker push %'

help:
	docker run --rm -t renatomefi/docker-testinfra:latest --help

lint:
	docker run -v ${current_dir}:/project:ro --workdir=/project --rm -t hadolint/hadolint:latest-debian hadolint Dockerfile-python2
	docker run -v ${current_dir}:/project:ro --workdir=/project --rm -t hadolint/hadolint:latest-debian hadolint Dockerfile-python3

test: ./tmp/tags.list
	cat ./tmp/tags.list | grep ":1" | xargs -I % sh -c 'docker run --rm -t -v ${current_dir}/test:/tests:ro -v /var/run/docker.sock:/var/run/docker.sock:ro %'
	cat ./tmp/tags.list | grep ":2\|:latest" | xargs -I % sh -c 'docker run --rm -t -v ${current_dir}/test:/tests:ro -v /var/run/docker.sock:/var/run/docker.sock:ro % -m "not v1"'

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
