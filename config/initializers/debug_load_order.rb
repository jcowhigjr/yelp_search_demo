# Remove or comment out all puts statements
# Keep the TracePoint for debugging if needed
TracePoint.trace(:call) do |tp|
  puts "#{tp.defined_class}##{tp.method_id} called from #{tp.path}:#{tp.lineno}"
end if ENV['DEBUG_TRACE'] == 'true'
