FROM elixir:1.11.2-alpine as build

RUN apk update
RUN apk add --no-cache alpine-sdk

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

copy mix.exs mix.lock ./
copy config config

RUN mix do deps.get, deps.compile

COPY lib lib

RUN mix do compile, escript.build

CMD ./reviews_scraper