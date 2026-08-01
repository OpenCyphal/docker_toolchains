# Changelog — toolshed (ts)

Per-release notes for the `ghcr.io/opencyphal/toolshed` image. The summary table of
every published tag lives in the [top-level README](../README.md#opencyphaltoolshedts).

## ts26.4.3

Adds:

- Bazel, via bazelisk 1.29.0, on both `linux/amd64` and `linux/arm64`
- Bazel 9.2.0, unpacked into the image rather than fetched on first use

`bazel` on `PATH` is bazelisk, not a Bazel release binary. Bazel's own apt
repository publishes `amd64` only while this image ships both architectures — the
same constraint that decided how Dafny is installed in ts26.4.2 — and bazelisk
publishes both. Installing the launcher rather than a fixed binary is also what
lets a project pin its own Bazel through `.bazelversion`.

`BAZELISK_HOME` is `/opt/bazelisk`, world-readable, rather than the default under
`$HOME`. The default is invisible to any other user the container runs as, which
CI routinely does; this is the trap `dotnet tool install --tool-path` avoids for
Dafny.

**`USE_BAZEL_VERSION` is deliberately not set.** It takes precedence over a
project's `.bazelversion` — measured, not assumed — so setting it here would
silently build every project with 9.2.0 whatever that project pinned. A project
that wants the pre-warmed toolchain writes `9.2.0` into its own `.bazelversion`,
which is where that decision belongs; a project pinning anything else downloads it
on first use.

### Bazel builds in this image are not offline

Worth stating plainly, because it is the first thing anyone reaching for Bazel
will assume otherwise.

Bazel's hermeticity guarantees cover action *execution* — sandboxed actions,
declared inputs, no leakage from the host. They have never covered the fetch
phase. Under bzlmod that phase is unavoidable: a module declaring **no**
dependencies at all still resolves `bazel_tools`' transitive deps
(`apple_support`, `protobuf`, `rules_java`, `rules_python`, `platforms`,
`rules_cc`, `bazel_skylib`, and more) from `bcr.bazel.build` before analysis
begins. `--noenable_bzlmod` does not escape it on Bazel 9.

None of the obvious mitigations move this, all measured against a cold cache:
a warmed `--repository_cache` holds archives rather than registry metadata; a
committed `MODULE.bazel.lock` records the resolution but still fetches the module
files; and `bazel vendor --vendor_dir` does not cover registry access either. What
does work is a warm per-user `$HOME/.cache/bazel`, which is no help to CI running
as an arbitrary uid.

A project that needs offline or air-gapped builds points Bazel at its own registry
mirror (`--registry=file:///...`) or vendors into its own workspace. Those are
per-project decisions — which modules you need is a function of your dependency
graph — so this image deliberately does not pin `--registry`, ship a partial
mirror that would go stale at every Bazel bump, or otherwise get in the way. It
supplies the toolchain; the dependency policy stays with the project.

## ts26.4.2

Adds:

- Dafny 4.11.0, on both `linux/amd64` and `linux/arm64`
- .NET SDK 10.0, which hosts Dafny
- z3 4.13.3, the SMT solver Dafny drives

Dafny is installed from its NuGet tool package rather than from a GitHub release
asset. Upstream publishes prebuilt Dafny binaries for x64 Linux only, so the
release assets cannot furnish the arm64 half of this image; the NuGet package is
architecture-neutral IL and does. `dafny` is on `PATH` at `/opt/dafny`.

That package carries no native binaries, which is what makes it portable and also
means it brings no solver: z3 comes from the distro instead. The Dafny release
zips bundle z3 but only for x64. Dafny nominally pairs with z3 4.12.1 while Ubuntu
26.04 packages 4.13.3; the two were measured to give identical results on the
proofs this image is used for.

Dafny 4.11.0 is built against .NET 8 while Ubuntu 26.04 packages only .NET 10, so
the image sets `DOTNET_ROLL_FORWARD=Major`. Obtaining .NET 8 from Microsoft's apt
repository instead would tie the image to a runtime that reaches end of life in
November 2026.

## ts26.4.1

Rebases toolshed onto Ubuntu 26.04 LTS and keeps only the latest native toolchain
families provided by that base:

- Python 3.14
- GCC 15
- CMake 4.2
- Ninja 1.13
- LLVM, Clang, and MLIR 22, including `libmlir-22-dev` and `mlir-22-tools`

Also adds:

- Rust
- Go
- Node.js and TypeScript
- Emscripten SDK 6.0.2, Binaryen, and WABT
- libcurl development headers for LLVM/MLIR CMake consumers
- libedit development headers for LLVM/MLIR CMake consumers
- Python package `lit`

Exports `LLVM_DIR`, `MLIR_DIR`, and `CMAKE_PREFIX_PATH` defaults for CMake-based
LLVM/MLIR builds. See the
[top-level README](../README.md#opencyphaltoolshedts) for the current values.
