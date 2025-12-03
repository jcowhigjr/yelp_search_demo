module Locales
  extend ActiveSupport::Concern

  included do
    def set_locale(&)
      locale =
        if params[:locale].present?
          params[:locale].to_s.to_sym.in?(I18n.available_locales) ? params[:locale].to_sym : I18n.default_locale
        else
          I18n.default_locale
        end
      I18n.locale = locale
      yield if block_given?
    end

    def default_url_options(options = {})
      options.merge({locale: resolve_locale})
    end

    def resolve_locale(locale = I18n.locale)
      locale == I18n.default_locale ? nil : locale
    end
  end
end
