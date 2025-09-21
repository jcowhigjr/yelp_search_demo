# Rails 8.1: Use a Ruby parser to track dependencies between Action View templates.
# Safe change; does not alter user-facing behavior.
Rails.configuration.action_view.render_tracker = :ruby