# Makefile for yelp_search_demo development workflows

.PHONY: help tailwind_enforce_config

# Default target
help:
	@echo "Available commands:"
	@echo "-------------------"
	@echo "make tailwind_enforce_config  - Validate Tailwind CSS v4 configuration"

# Tailwind CSS configuration validation
tailwind_enforce_config:
	@echo "Validating Tailwind CSS v4 configuration..."
	# Ensure tailwindcss-rails gem is installed (basic check, assumes bundle install is run)
	@if ! bundle show tailwindcss-rails > /dev/null 2>&1; then \
		echo "\033[31mFAIL:\033[0m tailwindcss-rails gem not found. Please install it. See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi
	# Check for v4 files and configs (existence check)
	@if [ ! -f app/assets/tailwind/application.css ] || \
	   [ ! -d app/assets/builds ] || \
	   [ ! -f Procfile.dev ] || \
	   ! grep -q "css: bin/rails tailwindcss:watch" Procfile.dev || \
	   [ ! -f config/tailwind.config.js ]; then \
		echo "\033[31mFAIL:\033[0m Required Tailwind v4 files/configs not found or Procfile.dev incorrect. Run 'bin/rails tailwindcss:install' or check setup. See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi
	# Check application.html.erb for correct stylesheet link tag
	@if ! grep -q '<%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>' app/views/layouts/application.html.erb; then \
		echo "\033[31mFAIL:\033[0m Incorrect stylesheet_link_tag in application.html.erb. Expected '<%= stylesheet_link_tag \"tailwind\", \"data-turbo-track\": \"reload\" %>'. See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi
	# Check application.css does not import tailwind directly
	@if grep -q '@import "tailwindcss";' app/assets/tailwind/application.css; then \
		echo "\033[31mFAIL:\033[0m application.css should not import tailwindcss directly when using tailwindcss-rails. See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi
	# ensure the cdn is not present
	@if grep -q "cdn.tailwindcss.com" app/views/layouts/application.html.erb; then \
		echo "\033[31mFAIL:\033[0m Tailwind CDN script present in layout! See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi

	@echo "\033[32mSUCCESS:\033[0m Tailwind CSS configuration validated. [See Makefile:tailwind_enforce_config for logic]"
