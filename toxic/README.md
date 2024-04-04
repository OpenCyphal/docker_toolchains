# toxic (tx): The OpenCyphal Toolchain Container for Python

The `opencyphal/toxic` docker image provides a consistent build and test environment
for development, continuous-integration, and test automation of Python based projects.

## Official Release

To release a new build of this container simply create a [new github release](https://github.com/OpenCyphal/docker_toolchains/releases/new)
that starts with `tx`, uses the Ubuntu major and minor version, and uses an monotonically increasing "patch" version.
For example `tx22.4.1`will cause the Github workflow to rebuild and push the `opencyphal/toxic` container with the
tag `tx22.4.1`.

***PLEASE UPDATE THE TOP-LEVEL README.md FOR EACH NEW RELEASE***

## Manual Build and Push

These instructions are for maintainers with permissions to push to the
[OpenCyphal organization on Github](https://github.com/OpenCyphal/). Normally the container should be published by
a github action but these instructions provide a way to manually update the container from any developer environment.

> **IMPORTANT NOTE**
>
> You must enable [containerd](https://containerd.io/) if you are using Docker Desktop to build locally (this is available as a general setting in Docker desktop). Docker desktop does not support multi-platform images and, if you try to use Docker Desktop without containerd, these instructions will fail with the message:
>
> *WARNING: No output specified with docker-container driver. Build result will only remain in the build cache.*
>

First create a temporary (7-day expiration please) personal access token (classic) with write:packages and read:packages
scope. See [this github help page](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
for instructions.

Next, make sure you can login:

```bash
export FGP = (fine-grained permission for OpenCyphal organization)
echo $FGP | docker login ghcr.io -u (github username) --password-stdin
```

... build a multi-platform image following the instructions [here](https://docs.docker.com/build/building/multi-platform/#multiple-native-nodes):

```bash
docker buildx create --use --name cyphalbuild
```

If you already created the `cyphalbuild` builder then just use it instead of creating it:

```bash
docker buildx use cyphalbuild
```

... then build the container:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --load -t ghcr.io/opencyphal/toxic:tx22.4.x .
```

(where x is the next version number for the container)

After this completes you'll see your image using the classic `docker images` command or the newer `buildx imagetools` command to inspect the multi-architecture manifest:

```
docker buildx imagetools inspect ghcr.io/opencyphal/toxic:tx22.4.x
```

 Now you can login to the container to test it out:

```bash
docker run --rm -it -v ${PWD}:/repo ghcr.io/opencyphal/toxic:tx22.4.x
```

### Push

As with load, you need to re-build with a `--push` argument but you'll be using the cache so the build should be a no-op:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push -t ghcr.io/opencyphal/toxic:tx22.4.x .
```

## More on Multi-Platform Builders

The two commands above make some assumptions about defaults and capabilities that we haven't verified on all build hosts. First, the `buildx create` command is assumed to target the correct Docker context. You can see your contexts by doing:

```
docker context ls
```

... then target a specific context by adding it as an additional argument to the builder create command:

```
docker buildx create --use --name cyphalbuild desktop-linux
```

We also assume you are using a build that has our two supported host platforms `linux/amd64` and `linux/arm64`. You can verify this after creating the builder using the inspect command. This should also verify that your builder is now in effect:

```
docker buildx inspect --bootstrap
```