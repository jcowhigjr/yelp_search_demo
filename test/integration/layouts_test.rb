require 'test_helper'

class LayoutsTest < ActionDispatch::IntegrationTest
  test 'static home has search link' do
    get static_home_url
  end

  test '#root_path returns the correct path' do
    assert_equal('/', static_home_path)
  end

  test 'defaults to English translation' do
    get static_home_path
    assert_select 'h2', 'New Search'
  end

  test 'renders translated versions of the markdown' do
    get static_home_path(locale: 'pt-BR')
    assert_select 'h2', 'Nova pesquisa'
  end
end
