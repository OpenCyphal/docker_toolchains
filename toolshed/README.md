# toolshed (ts): The OpenCyphal C and C++ toolchain container.

The `opencyphal/toolshed` docker image provides a consistent build and test environment
for development, continuous-integration, and test automation of C and C++ based projects.

- **What each release contains:** [CHANGELOG.md](CHANGELOG.md)
- **Published tags and the LLVM/MLIR CMake environment defaults:**
  [top-level README](../README.md#opencyphaltoolshedts)

## Official Release

To release a new build of this container simply create a
[new github release](https://github.com/OpenCyphal/docker_toolchains/releases/new)
that starts with `ts`, uses the Ubuntu major and minor version, and uses a monotonically
increasing "patch" version. For example `ts26.4.1` will cause the Github workflow to
rebuild and push the `opencyphal/toolshed` container with the tag `ts26.4.1`.

To trigger the pull-request CI, include `#ts` in the **pull request title**. The
[workflow](../.github/workflows/toolshed.yml) matches on the PR title, not on commit
messages, so a PR without `#ts` in its title will not build this container.

***PLEASE UPDATE THE TOP-LEVEL README.md AND [CHANGELOG.md](CHANGELOG.md) FOR EACH NEW RELEASE***

## Building Locally

All commands in this section are run from the `toolshed` directory — the Dockerfile and
its build context (the `provision-*.sh` scripts, `.deb` payloads, and checksum files)
live there. This matches CI, which builds with `context: toolshed`.

```bash
cd toolshed
```

For day-to-day development, build a single-platform image for your own machine. This is
a native build with no emulation, so it is dramatically faster than a multi-platform
build:

```bash
docker buildx build --platform linux/arm64 --load -t opencyphal/toolshed:ts26.4.x-local .
```

Use `--platform linux/amd64` on an Intel/AMD host. The default `docker` builder is
sufficient for single-platform builds; you do not need the `cyphalbuild` builder
described below.

The full image takes a while to build: the doxygen stage compiles from source and the
Emscripten stage downloads a complete SDK. To iterate on just one part of the build, stop
at an intermediate stage with `--target`:

```bash
docker buildx build --platform linux/arm64 --target llvm --load -t toolshed-llvm .
```

Stages, in order: `base`, `provisioning`, `llvm`, `wasm`, `doxygen`, `gcc-select`,
`arm-none-eabi`, `jlink`, `python`. Omit `--target` to build the complete image.

### Smoke Test

Confirm the toolchains in a freshly built image report the versions you expect:

```bash
docker run --rm opencyphal/toolshed:ts26.4.x-local bash -c '
  set -e
  cmake --version | head -1
  ninja --version
  gcc --version | head -1
  clang --version | head -1
  llvm-config --version
  mlir-opt --version | head -2
  arm-none-eabi-gcc --version | head -1
  python3 --version
  rustc --version
  go version
  node --version
  tsc --version
  emcc --version | head -1
'
```

Note that `JLinkExe` is added to `PATH` through `~/.bashrc` rather than through a
Dockerfile `ENV`, so it resolves only in an interactive shell, not in the
non-interactive `bash -c` above.

To work inside the container with your repository mounted:

```bash
docker run --rm -it -v ${PWD}:/repo opencyphal/toolshed:ts26.4.x-local
```

## Manual Multi-Platform Build and Push

These instructions are for maintainers with permissions to push to the
[OpenCyphal organization on Github](https://github.com/OpenCyphal/). Normally the
container is published by a github action; these instructions provide a way to manually
update the container from any developer environment.

> **NOTE**
>
> CI builds each architecture natively on a separate runner (`ubuntu-latest` for amd64,
> `ubuntu-24.04-arm` for arm64) and merges the results into one manifest by digest.
> Building both platforms on a single host emulates the foreign architecture through
> QEMU, which is *very* slow for this image. Prefer a release build through CI unless you
> specifically need a local multi-platform image.

> **NOTE**
>
> Multi-platform `--load` requires the [containerd](https://containerd.io/) image store.
> Recent versions of Docker Desktop enable this by default; verify with:
>
> ```bash
> docker info --format '{{.DriverStatus}}'
> ```
>
> A result containing `io.containerd.snapshotter.v1` means it is enabled. If it is not,
> turn on "Use containerd for pulling and storing images" in Docker Desktop's general
> settings. Without it, a multi-platform build fails with:
>
> *WARNING: No output specified with docker-container driver. Build result will only remain in the build cache.*

First, log in to the GitHub container registry. If you have the
[GitHub CLI](https://cli.github.com/) installed and authenticated:

```bash
gh auth token | docker login ghcr.io -u "$(gh api user --jq .login)" --password-stdin
```

Otherwise, create a temporary (7-day expiration please) fine-grained personal access
token with `write:packages` and `read:packages` scope — see
[this github help page](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
— and pipe it in, substituting your own github username:

```bash
export GHCR_TOKEN=<your token>
echo "$GHCR_TOKEN" | docker login ghcr.io -u <github username> --password-stdin
```

Next, create a builder that can produce multi-platform images, following the instructions
[here](https://docs.docker.com/build/building/multi-platform/#multiple-native-nodes):

```bash
docker buildx create --use --name cyphalbuild
```

If you already created the `cyphalbuild` builder then just use it instead of creating it:

```bash
docker buildx use cyphalbuild
```

... then build the container:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --load -t ghcr.io/opencyphal/toolshed:ts26.4.x .
```

After this completes you'll see your image using the classic `docker images` command or
the newer `buildx imagetools` command to inspect the multi-architecture manifest:

```bash
docker buildx imagetools inspect ghcr.io/opencyphal/toolshed:ts26.4.x
```

### Push

As with load, you need to re-build with a `--push` argument but you'll be using the cache
so the build should be a no-op:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push -t ghcr.io/opencyphal/toolshed:ts26.4.x .
```

## More on Multi-Platform Builders

The two commands above make some assumptions about defaults and capabilities that we
haven't verified on all build hosts. First, the `buildx create` command is assumed to
target the correct Docker context. You can see your contexts by doing:

```bash
docker context ls
```

... then target a specific context by adding it as an additional argument to the builder
create command:

```bash
docker buildx create --use --name cyphalbuild desktop-linux
```

We also assume you are using a build that has our two supported host platforms
`linux/amd64` and `linux/arm64`. You can verify this after creating the builder using the
inspect command. This should also verify that your builder is now in effect:

```bash
docker buildx inspect --bootstrap
```
