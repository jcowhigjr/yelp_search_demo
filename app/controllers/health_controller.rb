class HealthController < ApplicationController
  # Skips all authentication and authorization checks for this controller
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :ensure_user_fully_authenticated!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false

  def index
    db_healthy = check_database_health

    if db_healthy
      render plain: 'OK', status: :ok
    else
      render plain: 'Service Unavailable', status: :service_unavailable
    end
  end

  private

  def check_database_health
    ActiveRecord::Base.connection.execute('SELECT 1')
    true # If both checks pass without raising an exception
  rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::NoDatabaseError => e
    logger.error "Health check failed: Database connection error - #{e.class}: #{e.message}"
    false
  rescue StandardError => e
    logger.error "Health check failed: Unexpected error during database check - #{e.class}: #{e.message}"
    false
  end
end
