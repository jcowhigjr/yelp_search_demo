Rails.application.config.middleware.use Flipper::Middleware::Memoizer, preload_all: true
