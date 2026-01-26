ARG RUBY_VERSION=3.3.10
FROM ruby:${RUBY_VERSION}

# Install base packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby gems
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Precompile assets (if needed)
RUN bundle exec rails assets:precompile 2>/dev/null || bundle exec rails assets:precompile || true

# Expose port
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
