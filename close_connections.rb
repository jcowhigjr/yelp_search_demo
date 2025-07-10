ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord::Base)
Process.fork do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  # Run tests here
end
