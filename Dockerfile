FROM ubuntu:20.04 AS jq
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        build-essential \
        git \
        ca-certificates \
        autoconf \
        automake \
        libtool \
 && rm /usr/local/sbin/unminimize
# renovate: datasource=github-releases depName=containers/crun
ARG JQ_VERSION=1.6
WORKDIR /crun
RUN test -n "${JQ_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --recursive --branch "jq-${JQ_VERSION}" \
        https://github.com/stedolan/jq .
RUN git submodule update --init \
 && autoreconf -fi \
 && ./configure --with-oniguruma=builtin \
 && make LDFLAGS=-all-static \
 && make install

FROM scratch AS local
COPY --from=jq /usr/local/ .
