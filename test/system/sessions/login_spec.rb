# frozen_string_literal: true

require "application_system_test_case"

describe "Log in", auth: false do
  # fixtures :workspaces

  it "I should login before visiting the workspace" do
    visit login_url
  end
end
