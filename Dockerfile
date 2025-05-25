FROM ruby:3.3.5

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
    build-essential libpq-dev nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN gem install bundler:2.4.2
RUN bundle config set --local without 'development test' && bundle install

COPY . .

ENV PORT=8080
EXPOSE 8080

CMD ["bundle", "exec", "puma", "-p", "8080"]
