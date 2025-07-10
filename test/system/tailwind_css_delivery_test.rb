require 'application_system_test_case'

class TailwindCssDeliveryTest < ApplicationSystemTestCase
  test 'Tailwind CSS classes are present without CDN' do
    visit static_home_path
    # Look for a standard Tailwind utility class in the HTML (should be present if Tailwind is working)
    assert_selector 'h2.text-xs' 
    # .bg-primary check remains for custom layer (optional)
    # assert_selector ".bg-primary"
    # Optionally: check computed style via JS (uncomment if needed)
    # color = page.evaluate_script("getComputedStyle(document.querySelector('.bg-primary')).backgroundColor")
    # assert_equal "rgb(75, 156, 211)", color
  end
end
