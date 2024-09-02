puts "Starting debug load order"

Rails.application.config.before_initialize do
  puts "Before initialize:"
  Rails.application.config.eager_load_namespaces.each do |namespace|
    puts "  Namespace: #{namespace}"
  end
end

Rails.application.config.after_initialize do
  puts "After initialize:"
  Rails.application.config.eager_load_namespaces.each do |namespace|
    puts "  Namespace: #{namespace}"
  end

  puts "\nLoaded constants:"
  ObjectSpace.each_object(Module).select { |m| m.name =~ /^[A-Z]/ }.sort_by(&:name).each do |mod|
    puts "  #{mod}"
  end
end

puts "Ending debug load order"

# Add a tracer to track method calls
TracePoint.trace(:call) do |tp|
  puts "#{tp.defined_class}##{tp.method_id} called from #{tp.path}:#{tp.lineno}"
end if ENV['DEBUG_TRACE'] == 'true'
