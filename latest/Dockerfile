# Like the GNU Emacs dumper, the remacs dumper is unable to run with
# ASLR (Address space layout randomization) enabled on the host OS.
#
# The following command disables ASLR on Linux:
# sudo sh -c 'echo 0 > /proc/sys/kernel/randomize_va_space'
#
# The dumper only needs to run in the build stage, so once built the
# container runs fine even with ASLR enabled.

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
 && git fetch origin bbd9ac5f8887ebdbf441082bd46578f81b37389c --depth 1 \
 && git reset --hard FETCH_HEAD
RUN rustup install "$(cat rust-toolchain)"
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make check
RUN make install

FROM debian:buster-slim
COPY --from=build /usr/local/ /usr/local/
RUN apt-get update \
 && apt-get -y --no-install-recommends install \
      ca-certificates \
      libjpeg62-turbo libtiff5 libgif7 libxpm4 \
      libgtk-3-0 libgnutls30 libncurses5 libxml2 libxt6 \
      libx11-xcb1 libxft2 \
 && rm -rf /var/lib/apt/lists/*
CMD ["remacs"]
