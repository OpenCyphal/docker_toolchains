#
# Builds the toolshed/ubuntu-26.04 toolchain container.
#
FROM ubuntu:26.04 AS base

LABEL org.opencontainers.image.source=https://github.com/OpenCyphal/docker_toolchains
LABEL org.opencontainers.image.description="Provides a consistent build and test environment for development, continuous-integration, and test automation of OpenCyphal C and C++ based projects."
LABEL org.opencontainers.image.licenses=MIT

ARG TARGETARCH

VOLUME /repo

WORKDIR /repo

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TOOLSHED_LLVM_VERSION=22
ENV LLVM_DIR=/usr/lib/llvm-22/lib/cmake/llvm
ENV MLIR_DIR=/usr/lib/llvm-22/lib/cmake/mlir
ENV CMAKE_PREFIX_PATH=/usr/lib/llvm-22


# +---------------------------------------------------------------------------+
# | UBUNTU PROVISIONING
# +---------------------------------------------------------------------------+
FROM base AS provisioning
WORKDIR /tmp
ADD pre-provision.sh ./pre-provision.sh
ADD provision-repositories.sh ./provision-repositories.sh
ADD provision-repositories-${TARGETARCH}.sh ./provision-repositories-${TARGETARCH}.sh
ADD provision.sh ./provision.sh
ADD provision-${TARGETARCH}.sh ./provision-${TARGETARCH}.sh
ADD post-provision.sh ./post-provision.sh

RUN apt update
RUN ./pre-provision.sh
RUN ./provision-repositories.sh
RUN ./provision-repositories-${TARGETARCH}.sh
RUN apt update
RUN ./provision.sh
RUN ./provision-${TARGETARCH}.sh
RUN ./post-provision.sh

# INSTALL THE PATH FOR INTERACTIVE SESSIONS
RUN echo "export PATH=$PATH" >> ~/.bashrc

# +---------------------------------------------------------------------------+
# | LLVM
# +---------------------------------------------------------------------------+
FROM provisioning AS llvm
WORKDIR /tmp

ADD llvm-select.sh ./llvm-select.sh
ADD mlir-select.sh ./mlir-select.sh
RUN apt-get -y install \
    clang-${TOOLSHED_LLVM_VERSION} \
    clangd-${TOOLSHED_LLVM_VERSION} \
    clang-format-${TOOLSHED_LLVM_VERSION} \
    clang-tidy-${TOOLSHED_LLVM_VERSION} \
    clang-tools-${TOOLSHED_LLVM_VERSION} \
    lld-${TOOLSHED_LLVM_VERSION} \
    lldb-${TOOLSHED_LLVM_VERSION} \
    llvm-${TOOLSHED_LLVM_VERSION}-dev \
    llvm-${TOOLSHED_LLVM_VERSION}-tools \
    libomp-${TOOLSHED_LLVM_VERSION}-dev \
    libc++-${TOOLSHED_LLVM_VERSION}-dev \
    libc++abi-${TOOLSHED_LLVM_VERSION}-dev \
    libclang-common-${TOOLSHED_LLVM_VERSION}-dev \
    libclang-${TOOLSHED_LLVM_VERSION}-dev \
    libclang-cpp${TOOLSHED_LLVM_VERSION}-dev \
    libclang-rt-${TOOLSHED_LLVM_VERSION}-dev \
    libpolly-${TOOLSHED_LLVM_VERSION}-dev \
    libunwind-${TOOLSHED_LLVM_VERSION}-dev \
    libmlir-${TOOLSHED_LLVM_VERSION}-dev \
    mlir-${TOOLSHED_LLVM_VERSION}-tools
RUN ./llvm-select.sh ${TOOLSHED_LLVM_VERSION} 99
RUN ./mlir-select.sh ${TOOLSHED_LLVM_VERSION} 99
RUN dpkg-query -W libmlir-${TOOLSHED_LLVM_VERSION}-dev mlir-${TOOLSHED_LLVM_VERSION}-tools
RUN mkdir -p /usr/lib/cmake \
    && ln -sfn /usr/lib/llvm-${TOOLSHED_LLVM_VERSION}/lib/cmake/llvm /usr/lib/cmake/llvm \
    && ln -sfn /usr/lib/llvm-${TOOLSHED_LLVM_VERSION}/lib/cmake/mlir /usr/lib/cmake/mlir
RUN mkdir -p /tmp/cmake-find-mlir \
    && printf '%s\n' \
        'cmake_minimum_required(VERSION 3.20)' \
        'project(FindMLIR LANGUAGES C CXX)' \
        'find_package(CURL REQUIRED)' \
        'find_package(MLIR CONFIG REQUIRED)' \
        'find_package(LibEdit REQUIRED)' \
        'message(STATUS CURL_LIBRARIES_FROM_CMAKE=${CURL_LIBRARIES})' \
        'message(STATUS LibEdit_LIBRARIES_FROM_CMAKE=${LibEdit_LIBRARIES})' \
        'message(STATUS MLIR_DIR_FROM_CMAKE=${MLIR_DIR})' \
        > /tmp/cmake-find-mlir/CMakeLists.txt \
    && env -u MLIR_DIR -u CMAKE_PREFIX_PATH cmake -S /tmp/cmake-find-mlir -B /tmp/cmake-find-mlir-build \
    && rm -rf /tmp/cmake-find-mlir /tmp/cmake-find-mlir-build

# +---------------------------------------------------------------------------+
# | WASM/EMSCRIPTEN
# +---------------------------------------------------------------------------+
FROM llvm AS wasm
WORKDIR /tmp

ARG EMSDK_VERSION=6.0.2
ENV EMSDK=/opt/emsdk
RUN git clone --depth 1 --branch ${EMSDK_VERSION} https://github.com/emscripten-core/emsdk.git ${EMSDK}
RUN ${EMSDK}/emsdk install ${EMSDK_VERSION}
RUN ${EMSDK}/emsdk activate ${EMSDK_VERSION}
ENV PATH=${EMSDK}:${EMSDK}/upstream/emscripten:${PATH}

# +---------------------------------------------------------------------------+
# | DOXYGEN BUILD (PARALLEL)
# +---------------------------------------------------------------------------+
FROM wasm AS doxygen
WORKDIR /tmp
RUN mkdir doxygen-Release
RUN mkdir doxygen-Release/build
COPY cached-download.sh .

ARG DOXYGEN_VERSION=1_13_2

COPY doxygen-Release_${DOXYGEN_VERSION}.sha512.txt .
RUN --mount=type=cache,target=/doxygen-download \
    ./cached-download.sh \
    --cache-target "/doxygen-download" \
    --download-url "https://github.com/doxygen/doxygen/archive/refs/tags/Release_${DOXYGEN_VERSION}.tar.gz" \
    --download-to-file "/doxygen-download/doxygen-Release_${DOXYGEN_VERSION}.tar.gz" \
    --checksums "/tmp/doxygen-Release_${DOXYGEN_VERSION}.sha512.txt" \
    --tar-args "--strip-components=1" \
    --unpack-dir "/tmp/doxygen-Release"


WORKDIR /tmp/doxygen-Release/build
RUN cmake -G "Ninja"  -Dbuild_parse:BOOL=ON ..
RUN cmake --build .
RUN cmake --install .

WORKDIR /tmp
RUN rm -rf doxygen-Release

# +---------------------------------------------------------------------------+
# | GCC::native
# +---------------------------------------------------------------------------+
FROM doxygen AS gcc-select

WORKDIR /tmp

RUN gcc --version
RUN g++ --version

# +---------------------------------------------------------------------------+
# | arm-none-eabi-gcc
# +---------------------------------------------------------------------------+
FROM gcc-select AS arm-none-eabi-arm64
ARG GCC_HOST_VERSION=aarch64

FROM gcc-select AS arm-none-eabi-amd64
ARG GCC_HOST_VERSION=x86_64

FROM arm-none-eabi-${TARGETARCH} AS arm-none-eabi
WORKDIR /tmp
COPY cached-download.sh .

ARG ARM_NONE_EABI_VERSION=14.2.rel1
ARG ARM_NONE_EABI_CHECKSUM_FILE=arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi.tar.xz.sha256asc

COPY ${ARM_NONE_EABI_CHECKSUM_FILE} .
RUN --mount=type=cache,target=/arm-none-eabi-download \
    ./cached-download.sh \
    --cache-target "/arm-none-eabi-download" \
    --download-url "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_NONE_EABI_VERSION}/binrel/arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi.tar.xz" \
    --download-to-file "/arm-none-eabi-download/arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi.tar.xz" \
    --checksums "/tmp/${ARM_NONE_EABI_CHECKSUM_FILE}" \
    --algorithm 256 \
    --unpack-dir "/opt"

ADD arm-none-eabi-gcc-select.sh ./arm-none-eabi-gcc-select.sh
RUN ./arm-none-eabi-gcc-select.sh 1 /opt/arm-gnu-toolchain-${ARM_NONE_EABI_VERSION}-${GCC_HOST_VERSION}-arm-none-eabi/bin/
RUN update-alternatives --display arm-none-eabi-gcc

# +---------------------------------------------------------------------------+
# | GCC::native
# +---------------------------------------------------------------------------+
FROM arm-none-eabi AS jlink

WORKDIR /tmp

# From the forum: https://forum.segger.com/index.php/Thread/8953-SOLVED-J-Link-Linux-installer-fails-for-Docker-containers-Error-Failed-to-update/
ADD JLink_Linux_V816_${TARGETARCH}.deb ./JLink_Linux_V816.deb
RUN apt-get -y install libxcb-render-util0 libxcb-icccm4 libxcb-keysyms1 libxcb-image0 libxkbcommon0 libxkbcommon-x11-0
RUN dpkg --unpack JLink_Linux_V816.deb \
    && rm -f /var/lib/dpkg/info/jlink.postinst
RUN dpkg --configure jlink
RUN apt install -yf
RUN echo "export PATH=/opt/SEGGER/JLink:$PATH" >> ~/.bashrc
RUN rm JLink_Linux_V816.deb

# +---------------------------------------------------------------------------+
# | INSTALL PYTHON STUFF
# +---------------------------------------------------------------------------+
FROM jlink AS python
WORKDIR /tmp

RUN apt-get -y install pipx
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN echo "export PATH=$PIPX_HOME:$PIPX_BIN_DIR:$PATH" >> ~/.bashrc
RUN pipx install cowsay
RUN pipx install tox
RUN pipx install nox
RUN pip install --break-system-packages gcovr
RUN pipx install yakut
RUN pipx install lit
RUN rustc --version
RUN cargo --version
RUN go version
RUN node --version
RUN npm --version
RUN tsc --version
RUN emcc --version
RUN lit --version
RUN cowsay -t moo
RUN git clone --depth 1 https://github.com/OpenCyphal/public_regulated_data_types.git ~/public_regulated_data_types

# +---------------------------------------------------------------------------+
# | INSTALL DAFNY
# +---------------------------------------------------------------------------+
# Installed from NuGet rather than from a GitHub release asset. Dafny publishes
# prebuilt binaries for x64 Linux only -- there is no arm64 Linux build in any
# release, including nightlies -- and this image ships both architectures. The
# NuGet tool package is architecture-neutral IL, so it is the only route that
# puts the same Dafny on both. The cost is the .NET SDK that `dotnet tool
# install` requires.
FROM python AS dafny
WORKDIR /tmp

ARG DAFNY_VERSION=4.11.0
# Ubuntu 26.04 publishes .NET 10 and nothing older, so that is what is installed.
# Adding Microsoft's apt repository to obtain the .NET 8 that Dafny targets would
# pin this image to a runtime reaching end of life in November 2026.
ARG DOTNET_SDK_VERSION=10.0

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=1
# Dafny 4.11.0 ships as tools/net8.0/any -- architecture-neutral IL, but built
# against .NET 8. A framework-dependent app rolls forward only within its own
# major by default, so without this it refuses to start on a host that has only
# .NET 10 and asks for an 8.x runtime that Ubuntu does not package.
ENV DOTNET_ROLL_FORWARD=Major

RUN apt-get -y install dotnet-sdk-${DOTNET_SDK_VERSION}

# Dafny needs an SMT solver, and the NuGet package deliberately carries no native
# binaries -- that is exactly why it works on both architectures. The GitHub
# release zips bundle z3, but only for x64, so the distro package is the one
# source that serves both. Dafny nominally pairs with z3 4.12.1; 4.13.3 was
# measured to give identical results on the proofs this image is used for.
RUN apt-get -y install z3

# --tool-path rather than --global: a global install lands under $HOME and is
# invisible to any other user the container runs as, which CI routinely does.
RUN dotnet tool install --tool-path /opt/dafny dafny --version ${DAFNY_VERSION}
ENV PATH=/opt/dafny:${PATH}
RUN echo "export PATH=/opt/dafny:$PATH" >> ~/.bashrc

# Verify a real proof obligation rather than just `--version`. Launching proves
# only that the .NET roll-forward works; discharging an obligation additionally
# proves the solver is present and callable, which is the part that silently
# goes missing.
RUN printf 'method Smoke(x: int) requires x > 0 ensures x + 1 > 1 { }\n' > /tmp/smoke.dfy \
    && dafny verify /tmp/smoke.dfy \
    && rm /tmp/smoke.dfy

# +---------------------------------------------------------------------------+
# | INSTALL BAZEL
# +---------------------------------------------------------------------------+
# bazelisk rather than a Bazel release binary, and from GitHub rather than from
# apt. Bazel's own apt repository publishes amd64 only, and this image ships both
# architectures -- the same constraint that decided Dafny above. bazelisk
# publishes linux/amd64 and linux/arm64, so it is the one route that serves both.
#
# Installing bazelisk as `bazel` is also what lets a project pin its own Bazel:
# bazelisk reads .bazelversion from the workspace root and fetches that version.
FROM dafny AS bazel
WORKDIR /tmp
COPY cached-download.sh .

ARG BAZELISK_VERSION=1.29.0
# The version pre-warmed into the image below. A project pinning this one gets it
# without a download; any other version is fetched on first use.
ARG BAZEL_VERSION=9.2.0

# BAZELISK_HOME defaults to $HOME/.cache/bazelisk, which is invisible to any other
# user the container runs as -- and CI routinely runs as one. A shared path, made
# world-readable below, is what lets all of them use the pre-warmed Bazel. This is
# the same trap `dotnet tool install --tool-path` avoids for Dafny.
ENV BAZELISK_HOME=/opt/bazelisk

ARG BAZELISK_CHECKSUM_FILE=bazelisk-${BAZELISK_VERSION}-linux-${TARGETARCH}.sha256
COPY ${BAZELISK_CHECKSUM_FILE} .
RUN --mount=type=cache,target=/bazelisk-download \
    ./cached-download.sh \
    --cache-target "/bazelisk-download" \
    --download-url "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-${TARGETARCH}" \
    --download-to-file "/bazelisk-download/bazelisk-linux-${TARGETARCH}" \
    --checksums "/tmp/${BAZELISK_CHECKSUM_FILE}" \
    --algorithm 256 \
    && install -m 0755 "/bazelisk-download/bazelisk-linux-${TARGETARCH}" /usr/local/bin/bazel

# Bazel itself is unpacked into BAZELISK_HOME here rather than on first use. The
# throwaway workspace is what makes that happen: bazelisk honours .bazelversion
# only at a workspace root, and with no workspace it resolves "latest" over the
# network instead.
#
# Deliberately NOT setting USE_BAZEL_VERSION. That variable takes precedence over
# a project's .bazelversion -- measured, not assumed -- so an image setting it
# would silently build every project with this version whatever the project
# pinned. A project that wants the pre-warmed Bazel commits `9.2.0` to its own
# .bazelversion, which is where that decision belongs.
RUN mkdir -p /tmp/bazel-warm \
    && cd /tmp/bazel-warm \
    && printf 'module(name = "warm", version = "0.0.1")\n' > MODULE.bazel \
    && touch BUILD.bazel \
    && echo "${BAZEL_VERSION}" > .bazelversion \
    && bazel --version \
    && bazel shutdown \
    && cd /tmp \
    && rm -rf /tmp/bazel-warm \
    && chmod -R a+rX "${BAZELISK_HOME}"

# Build something rather than just running --version. Launching proves bazelisk
# resolved a binary; building additionally proves that binary can execute an
# action and write an output, which is the part that silently goes missing.
#
# This step needs network, and so will any real Bazel build: Bazel resolves even
# its built-in module dependencies through the Bazel Central Registry, exactly as
# npm, cargo, and pip in this image fetch theirs. The image supplies the
# toolchain, not a hermetic dependency cache.
RUN mkdir -p /tmp/bazel-smoke \
    && cd /tmp/bazel-smoke \
    && printf 'module(name = "smoke", version = "0.0.1")\n' > MODULE.bazel \
    && printf 'genrule(name = "g", outs = ["o.txt"], cmd = "echo built > $@")\n' > BUILD.bazel \
    && echo "${BAZEL_VERSION}" > .bazelversion \
    && bazel build //:g \
    && grep -q built bazel-bin/o.txt \
    && bazel shutdown \
    && cd /tmp \
    && rm -rf /tmp/bazel-smoke

# +---------------------------------------------------------------------------+
# LEAVE THE WORKDIR AS /repo
WORKDIR /repo
