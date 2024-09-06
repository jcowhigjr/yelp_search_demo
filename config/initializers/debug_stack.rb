module DebugStack
  extend ActiveSupport::Concern

  included do
    # Your debug logic here
  end
end

# Include the DebugStack module in ActionView::PartialRenderer
ActionView::PartialRenderer.include(DebugStack)
