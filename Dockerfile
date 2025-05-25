FROM ruby:3.3.5

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN gem install bundler:2.4.2
RUN bundle config set --local without 'development test'
RUN bundle install --jobs 4 --retry 3

COPY . .

# Use default Puma port
ENV PORT=3000
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-p", "3000"]
