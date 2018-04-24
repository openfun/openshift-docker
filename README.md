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

> You will need to create a DockerHub account first and log in via the `docker
> login` command.

### Continuous Integration and Delivery

To make sure our release process is reproducible, we have automated image build
and publication using CircleCI.

Our building strategy follows:

1. All services are constantly build when a new pull request is proposed and the
   related branch merged to `master`.
2. We publish a new image to DockerHub when the git repository is tagged with a
   tag matching the following pattern: `<service>-<version>`, _e.g._
   `nginx-1.13`.
3. We publish all images to DocherHub when the git repository is tagged with a
   tag matching the following pattern: `all-<date>`, _e.g._ `all-20180423`.

## Adding a new service

To add a new service `foo`, create the service directory first:

```bash
$ mkdir docker/images/foo
```

Then write OpenShift compatibility statements that will add new Docker layers
over the base image (see [OpenShift's
documentation](https://docs.openshift.com/enterprise/3.0/creating_images/guidelines.html#openshift-specific-guidelines)
to get official guidelines):

```Dockerfile
# docker/images/foo/Dockerfile
FROM foo:2.4.12

# Allow foo to be started by a non privileged user
RUN chgrp -R 0 /var/run/foo
```

### Remarks

* Always derive your `Dockerfile` from an official image and make sure it is
  still maintained.
* When building an image, the building context is the `docker/images/<service>`
  directory, so if you need to add files to the context (_e.g._ for a `COPY`
  statement), make sure to place them in this directory.

### Publish your image using the CI

Once your image is ready to be published, you are invited to:

1. Update the list of available images in the next section of this document.
2. Push your feature-branch (you've created a feature branch, right?) to GitHub
   and open a new pull request (PR).
3. Look for CI status and wait for a review of your work. If everything went
   well, proceed to the next step.
4. Create a new repository on DockerHub under the `fundocker` organization
   umbrella (it should be named following our image tagging pattern - see
   above), and give the `bot` team `write` access to this repository.
5. Tag the repository (see building strategy in the CI/CD section) to publish
   your image:

```bash

$ git tag nginx-1.13
$ git push origin --tags
```

6. Merge your PR.

## Available images

We maintain a restricted set of OpenShift-compatible images we use in
production. An exhaustive list of those Docker image follows:

### `nginx`

* Source: [Dockerfile](./docker/images/nginx/Dockerfile)
* Availability:
  [fundocker/openshift-nginx](https://hub.docker.com/r/fundocker/openshift-nginx/)

## License

This work is released under the MIT License (see [LICENSE](./LICENSE)).
