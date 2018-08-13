.PHONY: *

build:
	docker build -t renatomefi/testinfra:latest .

help:
	docker run --rm -t renatomefi/testinfra:latest --help
