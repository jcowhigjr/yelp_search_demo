<<<<<<< HEAD
<<<<<<< HEAD
# Get the Ruby version from mise.toml
ARG RUBY_VERSION=$(grep -E '^ruby\s*=' mise.toml | cut -d'"' -f2)
FROM ruby:${RUBY_VERSION:-3.3.10}
=======
FROM ruby:3.3.10
>>>>>>> 10a210bd (Update Ruby version from 3.3.9 to 3.3.10)

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
=======
# Get the Ruby version from mise.toml
ARG RUBY_VERSION=$(grep -E '^ruby\s*=' mise.toml | cut -d'"' -f2)
FROM ruby:${RUBY_VERSION:-3.3.10}

# ... rest of your existing Dockerfile content
>>>>>>> 3f079d14 (chore: ensure consistent Ruby version across all files)
