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
	# Check for v4 files and the Procfile watcher (the standalone binary does not
	# need config/tailwind.config.js)
	@if [ ! -f app/assets/tailwind/application.css ] || \
	   [ ! -d app/assets/builds ] || \
	   [ ! -f Procfile.dev ] || \
	   ! grep -qE 'css: bin/rails .?tailwindcss:watch' Procfile.dev; then \
		echo "\033[31mFAIL:\033[0m Required Tailwind v4 files not found or Procfile.dev css watcher missing. Run 'bin/rails tailwindcss:install' or check setup. See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi
	# Check application.html.erb for correct stylesheet link tag
	@if ! grep -qE 'stylesheet_link_tag .?tailwind' app/views/layouts/application.html.erb; then \
		echo "\033[31mFAIL:\033[0m Missing stylesheet_link_tag for tailwind in application.html.erb. See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi
	# Check the v4 entrypoint imports tailwind
	@if ! grep -q '@import "tailwindcss"' app/assets/tailwind/application.css; then \
		echo "\033[31mFAIL:\033[0m app/assets/tailwind/application.css must import tailwindcss (v4 entrypoint). See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi
	# ensure the cdn is not present
	@if grep -q "cdn.tailwindcss.com" app/views/layouts/application.html.erb; then \
		echo "\033[31mFAIL:\033[0m Tailwind CDN script present in layout! See Makefile:tailwind_enforce_config for details."; \
		exit 1; \
	fi

	@echo "\033[32mSUCCESS:\033[0m Tailwind CSS configuration validated. [See Makefile:tailwind_enforce_config for logic]"
