module FavoritesHelper
  ICON_BY_TERM = {
    /coffee/i => '☕️',
    /taco/i   => '🌮',
    /pizza/i  => '🍕',
  }.freeze

  def favorite_icon_for(term)
    return '❤️' unless term
    ICON_BY_TERM.detect { |regex, _| term =~ regex }&.last || '❤️'
  end
end
