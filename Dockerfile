FROM ruby:3.3

WORKDIR /app

# Install OS-level dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# Copy Gemfiles first for caching
COPY Gemfile Gemfile.lock ./

# Install bundler and gems
RUN gem install bundler:2.4.2
RUN bundle install --without development test

# Copy the rest of the app
COPY . .

# Environment setup
ENV PORT=8080
EXPOSE 8080

# Start server
CMD ["bundle", "exec", "puma", "-p", "8080"]
