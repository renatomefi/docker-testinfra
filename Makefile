.PHONY: *

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

build:
	docker build -t renatomefi/testinfra:latest .

help:
	docker run --rm -t renatomefi/testinfra:latest --help

lint:
	docker run -v ${current_dir}:/project:ro --workdir=/project --rm -t hadolint/hadolint:latest-debian hadolint Dockerfile
