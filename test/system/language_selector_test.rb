require "application_system_test_case"

class LanguageSelectorTest < ApplicationSystemTestCase
  test "should switch locales" do
    visit "/"
    assert_selector "html[lang='en']"

    find(".language-selector__button").click
    click_on "Español"

    assert_selector "html[lang='es']"
    assert_text "Buscar" # "Search" in Spanish
  end

  test "should have accessible attributes" do
    visit "/"
    button = find(".language-selector__button")
    assert_equal "false", button["aria-expanded"]
    button.click
    assert_equal "true", button["aria-expanded"]
  end
end
