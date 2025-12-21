FROM ruby:3.3.10

# Install base packages
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    yarn \
    git \
    vim \
    curl \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash vscode

# Set working directory
WORKDIR /workspace

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install gems
RUN bundle config set --local path 'vendor/bundle' && \
    bundle install

# Copy the rest of the application
COPY . .

# Change ownership to vscode user
RUN chown -R vscode:vscode /workspace

USER vscode

# Expose port 3000 to the Docker host
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
