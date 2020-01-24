FROM elixir:1.9.4-alpine as dev

COPY .build-deps /
RUN cat .build-deps | xargs apk add

WORKDIR /app

FROM dev as ci
COPY mix* ./
RUN mix do \
    local.hex --force, \
    local.rebar --force, \
    deps.get, \
    deps.compile

COPY assets/package.json assets/yarn.lock /app/assets/
RUN apk update \
    && apk add -u yarn \
    && cd assets \
    && yarn install

COPY . ./
