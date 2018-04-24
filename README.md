# OpenShift Docker

This repository contains the docker image sources used in FUN's new
OpenShift-based infrastructure to run Open-edX.

## Usage

### Build a service image

Building a service Docker image can be achieved thanks to the `bin/build`
utility script, _e.g._:

```bash
$ bin/build nginx
```

For a target `service`, the `build` script expect a `Dockerfile` and context to
be located in a `docker/images/<service>/` directory, _e.g._:

```
.
├── ...
├── docker
│   └── images
│       └── nginx
│           └── Dockerfile
└── ...
```

The target build image will be automatically tagged with the following pattern:

```
fundocker/openshift-<service>:<version>
```

with `<service>` the service name (_e.g._ `nginx`) and `<version>` the version
tag of the original service image (_e.g._ `1.13`) extracted from the first
`FROM` statement of the service's `Dockerfile`, _e.g._:

```Dockerfile
# docker/images/nginx/Dockerfile
FROM nginx:1.13

# ...
```

Once the build succeed, you can check image availability _via_:

```bash
$ docker images "fundocker/openshift*"
REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
fundocker/openshift-nginx   1.12                97fa5695dab6        22 hours ago        108MB
fundocker/openshift-nginx   1.13                367a1bb94e8a        23 hours ago        109MB
```

### Publish a service image

Once built, you can publish your image to [DockerHub](https://hub.docker.com)
via the `bin/publish` script, _e.g._:

```bash
$ bin/publish nginx
```

The script will automatically look up for a built image tagged with the pattern
described in the previous section and will push this new image to the DockerHub
public repository.

> You will need to create a DockerHub account first and log in via the
> `docker login` command.

## Adding a new service

To add a new service `foo`, create the service directory first:

```bash
$ mkdir docker/images/foo
```

Then write OpenShift compatibility statements that will add new Docker layers
over the base image:

```Dockerfile
# docker/images/foo/Dockerfile
FROM foo:2.4.12

# Allow foo to be started by a non priviledged user
RUN chgrp -R 0 /var/run/foo
```

And finally don't forget to update the list of available images below.

### Remarks

* Always derive your `Dockerfile` from an official image and make sure it is
  still maintained.
* When building an image, the building context is the `docker/images/<service>`
  directory, so if you need to add files to the context (_e.g._ for a `COPY`
  statement), make sure to place them in this directory.

## Available images

We maintain a restricted set of OpenShift-compatible images we use in
production. An exhaustive list of those Docker image follows:

### `nginx`

* Source: [Dockerfile](./docker/images/nginx/Dockerfile)
* Availability:
  [fundocker/openshift-nginx](https://hub.docker.com/r/fundocker/openshift-nginx/)

## License

This work is released under the MIT License (see [LICENSE](./LICENSE)).
