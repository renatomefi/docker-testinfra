# A testinfra Docker container

[![CircleCI](https://circleci.com/gh/renatomefi/docker-testinfra.svg?style=svg)](https://circleci.com/gh/renatomefi/docker-testinfra)
[![Docker hub](https://img.shields.io/docker/pulls/renatomefi/docker-testinfra.svg)](https://hub.docker.com/r/renatomefi/docker-testinfra/)
[![Docker hub](https://img.shields.io/microbadger/image-size/renatomefi/docker-testinfra/2.svg)](https://hub.docker.com/r/renatomefi/docker-testinfra/)

This image helps you run [testinfra](https://testinfra.readthedocs.io/en/latest/) supporting both docker and ssh plugins

[![Dockerhub badge](http://dockeri.co/image/renatomefi/docker-testinfra)](https://hub.docker.com/r/renatomefi/docker-testinfra)

## Running the image

Considering your tests are under `./tests`

```sh
docker run --rm -t \
  -v "$(pwd)/tests:/tests" \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  renatomefi/docker-testinfra:2 \
  --verbose --hosts='docker://CONTAINER_NAME_OR_ID'
```

Everything on the last line are py.test and infratest parameters, see more at https://testinfra.readthedocs.io/en/latest/invocation.html

This images simply provides an entrypoint to `py.test` with a few parameters to supress caching.

## Tags and versions

You use more to less specific versions for instance:

- `renatomefi/docker-testinfra:3`
- `renatomefi/docker-testinfra:3.2`
- `renatomefi/docker-testinfra:3.2.0`
- `renatomefi/docker-testinfra:2`
- `renatomefi/docker-testinfra:2.0`
- `renatomefi/docker-testinfra:2.0.0`
- `renatomefi/docker-testinfra:1`
- `renatomefi/docker-testinfra:1.19`
- `renatomefi/docker-testinfra:1.19.0`

When `2.1` is released for instance, the new major `2` will become `2.1`, this way you can always be up-to-date with the desired major.

### Python version

Testinfra version `2` is only offered with Python 3.

Testinfra version `1` is oferred with Python 2 by default and Python 3 optionally by appending `python3` to its tag. (This is only valid for 1.19+)

- `renatomefi/docker-testinfra:1-python3`
- `renatomefi/docker-testinfra:1.19-python3`
- `renatomefi/docker-testinfra:1.19.0-python3`

## testinfra and Docker

https://testinfra.readthedocs.io/en/latest/backends.html#docker
