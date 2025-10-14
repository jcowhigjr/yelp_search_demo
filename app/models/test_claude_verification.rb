# Test file for manual Claude Code review verification
class TestClaudeVerification
  def initialize(items)
    @items = items
  end

  # This method has several issues that Claude should identify:
  # 1. No error handling for nil items
  # 2. Inefficient implementation
  # 3. No input validation
  def calculate_total_price
    total = 0
    @items.each do |item|
      if item.has_key?('price')
        total = total + item['price']
      end
    end
    return total
  end

  # This method also has issues:
  # 1. No validation of the discount parameter  
  # 2. Magic number (100) should be a constant
  # 3. Could be more idiomatic Ruby
  def apply_discount(discount)
    if discount > 0
      original_total = calculate_total_price()
      discounted_amount = original_total * (discount / 100)
      return original_total - discounted_amount
    else
      return calculate_total_price()
    end
  end

  # Method with potential security issues Claude should catch
  def execute_command(command)
    system(command) # Potential security vulnerability
  end
end