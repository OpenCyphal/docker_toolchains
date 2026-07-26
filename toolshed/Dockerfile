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

# +---------------------------------------------------------------------------+# LEAVE THE WORKDIR AS /repo
# LEAVE THE WORKDIR AS /repo
WORKDIR /repo
