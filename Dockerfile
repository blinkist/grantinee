FROM ruby:2.5

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
COPY grantinee.gemspec /myapp/grantinee.gemspec
COPY lib /myapp/lib

RUN bundle install

COPY . /myapp
