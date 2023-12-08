# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
