# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.4.7
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev libvips pkg-config npm curl zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN npm install standard prettier --global

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json ./
RUN npm install

COPY . .

ENTRYPOINT ["/app/bin/docker-entrypoint"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
