require 'application_system_test_case'

# Regression coverage for issue #3016: a stale SRI integrity hash on the Font
# Awesome cdnjs stylesheet made every browser drop it, so icons were missing and
# an integrity error fired on each page load. cdnjs sends
# Access-Control-Allow-Origin: *, so cssRules is readable; a blocked stylesheet
# reports zero rules.
class FontAwesomeDeliveryTest < ApplicationSystemTestCase
  test 'Font Awesome stylesheet loads (SRI hash matches served bytes)' do
    visit static_home_path

    rule_count = page.evaluate_script(<<~JS)
      (() => {
        const sheet = Array.from(document.styleSheets)
          .find((s) => (s.href || '').includes('font-awesome'));
        if (!sheet) return -1;
        try { return sheet.cssRules.length; } catch (e) { return -2; }
      })()
    JS

    assert_operator rule_count, :>, 0,
                    'Font Awesome stylesheet missing or blocked (check the SRI integrity hash)'
  end

  test 'auth page renders Font Awesome brand icons' do
    visit '/login'

    assert_selector 'svg.fa-google', wait: 5
    assert_selector 'svg.fa-facebook'
  end
end
