module FlipperHelper
  def flipper_enabled?(feature)
    Flipper.instance.enabled?(feature)
  end
end
