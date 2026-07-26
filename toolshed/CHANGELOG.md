# Changelog — toolshed (ts)

Per-release notes for the `ghcr.io/opencyphal/toolshed` image. The summary table of
every published tag lives in the [top-level README](../README.md#opencyphaltoolshedts).

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
