# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.4.1
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config npm

RUN npm install standard prettier --global

COPY Gemfile Gemfile.lock ./
RUN bundle install

ENTRYPOINT ["/app/bin/docker-entrypoint"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
