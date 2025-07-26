module FavoritesHelper
  ICON_BY_TERM = {
    /coffee/i => "☕️",
    /taco/i   => "🌮",
    /pizza/i  => "🍕"
  }.freeze

  def favorite_icon_for(term)
    ICON_BY_TERM.find { |regex, _| term =~ regex }&.last || "❤️"
  end
end
