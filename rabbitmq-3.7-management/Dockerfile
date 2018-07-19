FROM scratch

COPY --from=rabbitmq:3.7.7-management / /

RUN usermod -u 1000 rabbitmq \
&& groupmod -g 1000 rabbitmq \
&& chown -hR rabbitmq:rabbitmq /var/lib/rabbitmq /etc/rabbitmq /var/log/rabbitmq

# ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-
ENV PATH /usr/lib/rabbitmq/bin:$PATH
ENV RABBITMQ_VERSION 3.7.7
ENV LANG C.UTF-8
ENV HOME /var/lib/rabbitmq

VOLUME /var/lib/rabbitmq

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 4369 5671 5672 25672 15671 15672
CMD ["rabbitmq-server"]

