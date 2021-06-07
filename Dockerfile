FROM python:3.8-alpine as base

RUN apk update && \
    apk upgrade

FROM base as build_lxml

RUN apk add --no-cache build-base gcc musl-dev python3-dev libffi-dev libxml2-dev libxslt-dev
RUN python -OO -m pip install --no-cache-dir -U pip && \
    python -OO pip wheel --no-cache-dir --wheel-dir=/root/lxml_wheel lxml

FROM base
COPY --from=build_lxml /root/lxml_wheel /root/lxml_wheel

# lxml binary dependencies
COPY --from=build_lxml /usr/lib/libxslt.so.1 /usr/lib/libxslt.so.1
COPY --from=build_lxml /usr/lib/libexslt.so.0 /usr/lib/libexslt.so.0
COPY --from=build_lxml /usr/lib/libxml2.so.2 /usr/lib/libxml2.so.2
COPY --from=build_lxml /usr/lib/libgcrypt.so.20 /usr/lib/libgcrypt.so.20
COPY --from=build_lxml /usr/lib/libgpg-error.so.0 /usr/lib/libgpg-error.so.0

RUN python -OO -m pip install --no-cache --no-index --find-links=/root/lxml_wheel/* && \
    python -OO -m pip install dnsrecon
