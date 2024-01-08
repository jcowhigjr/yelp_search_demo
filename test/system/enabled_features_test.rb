require 'application_system_test_case'

class EnabledFeaturesTest < ApplicationSystemTestCase

    # https://github.com/flippercloud/flipper/issues/615#issuecomment-1879449641

    setup do
        # Memory works here, as long as the same instance is shared across this thread and the app thread
        @adapter = Flipper::Adapters::Memory.new

        Flipper.configure do |config|
         config.adapter { @adapter }
        end
        Flipper.instance = nil # Ensure flipper gets reset
    end

    test 'Flipper feature should be enabled' do
      Flipper.add :early_access_preview
      Flipper.enable :early_access_preview

      assert_predicate Flipper[:early_access_preview], :enabled?
    end

    test 'I should see Early Access Preview' do
        Flipper.add :early_access_preview
        Flipper.enable :early_access_preview

        visit '/'

        assert_text 'Early Access Preview'
    end

end