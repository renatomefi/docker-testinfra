A testinfra Docker container
======

This image helps you run [testinfra](https://testinfra.readthedocs.io/en/latest/) supporting both docker and ssh plugins

[![Dockerhub badge](http://dockeri.co/image/renatomefi/docker-testinfra)](https://hub.docker.com/r/renatomefi/docker-testinfra)

Running
======

Considering your tests are under `./tests`

```sh
docker run --rm -t \
  -v "$(pwd)/tests:/tests" \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  renatomefi/testinfra:latest \
  --verbose --hosts='docker://CONTAINER_NAME_OR_ID'
```

Everything on the last line are py.test and infratest parameters, see more at https://testinfra.readthedocs.io/en/latest/invocation.html

This images simply provides an entrypoint to `py.test` with a few parameters to supress caching.

testinfra and Docker
======

https://testinfra.readthedocs.io/en/latest/backends.html#docker
