# Changelog — toolshed (ts)

Per-release notes for the `ghcr.io/opencyphal/toolshed` image. The summary table of
every published tag lives in the [top-level README](../README.md#opencyphaltoolshedts).

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
