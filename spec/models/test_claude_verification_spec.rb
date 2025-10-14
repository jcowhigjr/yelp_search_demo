# Test spec for Claude verification - mix of good and improvable patterns
require 'rails_helper'

RSpec.describe TestClaudeVerification, type: :model do
  let(:valid_items) do
    [
      { 'price' => 10.99 },
      { 'price' => 5.50 },
      { 'price' => 15.00 }
    ]
  end

  let(:items_with_missing_price) do
    [
      { 'price' => 10.99 },
      { 'name' => 'Item without price' },
      { 'price' => 15.00 }
    ]
  end

  describe '#initialize' do
    it 'stores items' do
      calculator = TestClaudeVerification.new(valid_items)
      expect(calculator.instance_variable_get(:@items)).to eq(valid_items)
    end
  end

  describe '#calculate_total_price' do
    context 'with valid items' do
      it 'calculates total correctly' do
        calculator = TestClaudeVerification.new(valid_items)
        expect(calculator.calculate_total_price).to eq(31.49)
      end
    end

    # Test case that should reveal issues Claude might identify
    context 'with nil items' do
      it 'should handle nil items gracefully' do
        calculator = TestClaudeVerification.new(nil)
        # This will likely fail - Claude should suggest better error handling
        expect { calculator.calculate_total_price }.not_to raise_error
      end
    end

    context 'with items missing price' do
      it 'ignores items without price' do
        calculator = TestClaudeVerification.new(items_with_missing_price)
        expect(calculator.calculate_total_price).to eq(25.99)
      end
    end
  end

  describe '#apply_discount' do
    let(:calculator) { TestClaudeVerification.new(valid_items) }

    it 'applies discount correctly' do
      discounted_total = calculator.apply_discount(10)
      expect(discounted_total).to be_within(0.01).of(28.34) # 31.49 * 0.9
    end

    # Edge case that might reveal issues
    it 'handles zero discount' do
      discounted_total = calculator.apply_discount(0)
      expect(discounted_total).to eq(31.49)
    end

    # This test reveals potential issues Claude should catch
    it 'handles negative discount' do
      discounted_total = calculator.apply_discount(-5)
      expect(discounted_total).to eq(31.49)
    end

    # Boundary condition that Claude might suggest testing
    it 'handles 100% discount' do
      discounted_total = calculator.apply_discount(100)
      expect(discounted_total).to eq(0.0)
    end
  end

  # Test for the security vulnerability
  describe '#execute_command' do
    let(:calculator) { TestClaudeVerification.new([]) }

    it 'executes system commands' do
      # This is a security risk that Claude should identify
      expect(calculator).to respond_to(:execute_command)
    end
  end
end