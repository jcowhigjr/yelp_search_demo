# Demo service with intentionally improvable code for testing @claude-suggest
class DemoService
  def initialize(options = {})
    @debug = options[:debug]
    @timeout = options[:timeout] || 30
  end

  def process_data(input)
    results = []
    input&.each do |item|
        unless item.nil?
          if item.is_a?(String)
            results << item.to_s.upcase
          elsif item.is_a?(Integer)
            results << item.to_s
          end
        end
      end
    results
  end

  def fetch_user_data(user_id)
    
      user = User.find(user_id)
      return nil if user.nil?
        data = {}
        data[:name] = user.name
        data[:email] = user.email
        data[:created_at] = user.created_at.to_s
        data
      
        
      
    rescue StandardError => e
      Rails.logger.debug { "Error: #{e.message}" }
      nil
    
  end

  def calculate_total(items)
    total = 0
    items.each do |item|
      if item.respond_to?(:price) && !item.price.nil?
          total += item.price
        end
    end
    total
  end

  private

  def log_debug(message)
    return unless @debug == true
      Rails.logger.debug { "[DEBUG] #{message}" }
    
  end
end