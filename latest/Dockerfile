FROM debian:buster-slim AS build
RUN apt-get update \
 && apt-get -y --no-install-recommends install \
      ca-certificates curl git \
      build-essential automake texinfo \
      clang libclang-dev \
      libjpeg-dev libtiff-dev libgif-dev libxpm-dev \
      libgtk-3-dev gnutls-dev libncurses5-dev libxml2-dev libxt-dev \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /root
RUN curl -o rustup-init --proto =https --tlsv1.2 -sSf https://sh.rustup.rs \
 && chmod +x rustup-init \
 && ./rustup-init -y
ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /build/remacs
RUN git init \
 && git remote add origin https://github.com/remacs/remacs.git \
 && git fetch origin 42860365e6602cc5a1a005cc98eeaa5b72d52811 --depth 1 \
 && git reset --hard FETCH_HEAD
RUN rustup install "$(cat rust-toolchain)"
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make check
RUN make install

FROM debian:buster-slim
COPY --from=build /usr/local/ /usr/local/
CMD ["remacs"]
