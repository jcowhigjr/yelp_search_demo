require 'application_system_test_case'


class EnabledFeaturesTest < ApplicationSystemTestCase
  # This is a workaround for Flipper
  # This is flaky and fails periodically
  # https://github.com/flippercloud/flipper/issues/615#issuecomment-1879449641
  # https://github.com/flippercloud/flipper/pull/808/files/05e2ce04c2e68ffeafffc126bf5ced60f6b45fb1#r1457378780

  # setup do
  #   # Memory works here, as long as the same instance is shared across this thread and the app thread
  #   # Flipper.instance.import(Flipper::Adapters::Memory.new)

  # end

  # parallelize_setup do |_worker|
  #   Flipper.instance=nil
  # end

  # enable the feature manually in .env.test.local
  # FLIPPER_EARLY_ACCESS_PREVIEW=true
  test 'I should see Early Access Preview' do
    Flipper.enable(:early_access_preview)
    visit '/'

    assert_text 'Early Access Preview'
  end

  test 'I should not see Early Access Preview' do
    Flipper.disable(:early_access_preview)
    visit '/'

    assert_text 'Coming Soon: Sign up for Early Access'
  end
end
