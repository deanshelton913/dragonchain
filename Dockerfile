FROM python:3.7-alpine as base

WORKDIR /usr/src/core
# Install necessary base dependencies and set UTC timezone for apscheduler
RUN apk --no-cache upgrade && apk --no-cache add libffi libstdc++ gmp && echo "UTC" > /etc/timezone

FROM base AS builder
# Install build dependencies
RUN apk add g++ make gmp-dev libffi-dev automake autoconf libtool
# Install python dependencies
ENV SECP_BUNDLED_EXPERIMENTAL 1
ENV SECP_BUNDLED_WITH_BIGNUM 1
COPY requirements.txt .
RUN python3 -m pip install -r requirements.txt

FROM base AS release
# Copy the installed python dependencies from the builder
COPY --from=builder /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn
# Copy our actual application
COPY --chown=1000:1000 . .
