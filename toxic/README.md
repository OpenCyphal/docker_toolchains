# toxic (tx): The OpenCyphal Toolchain Container for Python

The `opencyphal/toxic` docker image provides a consistent build and test environment
for development, continuous-integration, and test automation of Python based projects.

## Official Release

To release a new build of this container simply create a [new github release](https://github.com/OpenCyphal/docker_toolchains/releases/new)
that starts with `tx`, uses the Ubuntu major and minor version, and uses an monotonically increasing "patch" version.
For example `txv20.4.1`will cause the Github workflow to rebuild and push the `opencyphal/toxic` container with the
tag `tx20.4.1` (where the release workflow elides the 'v').

***PLEASE UPDATE THE TOP-LEVEL README.md FOR EACH NEW RELEASE***

## Manual Build and Push

These instructions are for maintainers with permissions to push to the
[OpenCyphal organization on Github](https://github.com/OpenCyphal/). Normally the container should be published by
a github action but these instructions provide a way to manually update the container from any developer environment.

First create a temporary (7-day expiration please) personal access token (classic) with write:packages and read:packages
scope. See [this github help page](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
for instructions.

Next, make sure you can login:

```bash
export FGP = (fine-grained permission for OpenCyphal organization)
echo $FGP | docker login ghcr.io -u (github username) --password-stdin
```

... now build (where x is the next version number for the container):

```bash
docker build -t ghcr.io/opencyphal/toxic:tx20.4.x .
```

... and finally, push.

```bash
docker push ghcr.io/opencyphal/toxic:tx20.4.x
```

## Testing out the container

To login to an interactive session do:

```bash
docker run --rm -it -v ${PWD}:/repo ghcr.io/opencyphal/toxic:tx20.4.x
```