FROM ruby:2.4.2-alpine3.7

RUN apk update \
    && apk add ca-certificates wget \
    && update-ca-certificates \
    && wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
    && chmod +x /usr/local/bin/dumb-init

ENV APP /app

RUN mkdir -p $APP
WORKDIR $APP

COPY Gemfile $APP/Gemfile

RUN set -ex \
      && apk add --no-cache --virtual .app-builddeps \
        gcc \
        g++ \
        make \
        sqlite-dev \
      && bundle install -j10 \
      && apk del .app-builddeps \
      && apk add --no-cache --virtual .app-rundeps \
        libstdc++ \
        sqlite-libs

COPY . $APP

RUN bundle exec rake db:create db:migrate db:seed

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["bundle", "exec", "rackup", "-p", "9292", "-o", "0.0.0.0", "config.ru"]

EXPOSE 9292
