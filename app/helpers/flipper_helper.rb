module FlipperHelper
  def flipper_enabled?(feature)
    enabled = Flipper.instance.enabled?(feature)
    Rails.logger.info "Checking Flipper feature '#{feature}': #{enabled}"
    enabled
  end
end
