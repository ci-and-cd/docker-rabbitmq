
ARG IMAGE_ARG_IMAGE_TAG

FROM rabbitmq:${IMAGE_ARG_IMAGE_TAG:-3.7.7-management-alpine} as base

# see: https://github.com/docker-library/rabbitmq/blob/4b2b11c59ee65c2a09616b163d4572559a86bb7b/3.7/alpine/management/Dockerfile

FROM scratch

ARG IMAGE_ARG_ALPINE_MIRROR
ARG IMAGE_ARG_VERSION

COPY --from=base / /

RUN set -ex \
  && if [ -f /etc/alpine-release ]; then \
       echo IMAGE_ARG_ALPINE_MIRROR ${IMAGE_ARG_ALPINE_MIRROR}; \
       echo /etc/apk/repositories; cat /etc/apk/repositories; \
       sed -E -i "s#[0-9a-z-]+\.alpinelinux\.org#${IMAGE_ARG_ALPINE_MIRROR:-dl-cdn.alpinelinux.org}#g" /etc/apk/repositories; \
       echo /etc/apk/repositories; cat /etc/apk/repositories; \
       apk upgrade --update; \
       apk add --no-cache shadow sudo; \
       rm -rf /tmp/* /var/cache/apk/*; \
     fi \
  && usermod -u 1000  rabbitmq \
  && groupmod -g 1000 rabbitmq \
  && chown -hR rabbitmq:rabbitmq /var/lib/rabbitmq /etc/rabbitmq \
  && if [ ! -d /var/log/rabbitmq ]; then mkdir -p /var/log/rabbitmq; fi \
  && chown -hR rabbitmq:rabbitmq /var/log/rabbitmq \
  && echo whoami $(whoami) \
  && find / -name "rabbitmq-plugins" | xargs ls -la

# debian:stretch-slim  /usr/lib/rabbitmq/bin
# alpine:3.8           /opt/rabbitmq/sbin
ENV PATH /usr/lib/rabbitmq/bin:/opt/rabbitmq/sbin:$PATH
ENV RABBITMQ_VERSION ${IMAGE_ARG_VERSION:-3.7.7}
ENV LANG C.UTF-8
ENV HOME /var/lib/rabbitmq

VOLUME ["/var/lib/rabbitmq", "/var/log/rabbitmq"]

ENTRYPOINT ["docker-entrypoint.sh"]

# management
EXPOSE 4369 5671 5672 25672 15671 15672
# non-management
#EXPOSE 4369 5671 5672 25672

CMD ["rabbitmq-server"]
