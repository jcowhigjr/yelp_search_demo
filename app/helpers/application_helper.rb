module ApplicationHelper
  def resolve_locale(locale)
    # Convert locale to string format for URLs
    locale.to_s
  end
end
