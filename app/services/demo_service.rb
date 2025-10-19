# Demo service with intentionally improvable code for testing @claude-suggest
class DemoService
  def initialize(options = {})
    @debug = options[:debug]
    @timeout = options[:timeout] || 30
  end

  def process_data(input)
    results = []
    if input != nil
      input.each do |item|
        if item != nil
          if item.is_a?(String)
            results << item.to_s.upcase
          elsif item.is_a?(Integer)
            results << item.to_s
          end
        end
      end
    end
    return results
  end

  def fetch_user_data(user_id)
    begin
      user = User.find(user_id)
      if user != nil
        data = {}
        data[:name] = user.name
        data[:email] = user.email
        data[:created_at] = user.created_at.to_s
        return data
      else
        return nil
      end
    rescue => e
      puts "Error: #{e.message}"
      return nil
    end
  end

  def calculate_total(items)
    total = 0
    items.each do |item|
      if item.respond_to?(:price)
        if item.price != nil
          total = total + item.price
        end
      end
    end
    total
  end

  private

  def log_debug(message)
    if @debug == true
      puts "[DEBUG] #{message}"
    end
  end
end