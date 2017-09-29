# frozen_string_literal: true

require 'feature_test'

class EmbuIntegrationTest < FeatureTest
  setup { screenshot_section :embus }

  def test_display_my_embu
    screenshot_group :my_embu
    visit_with_login '/embus', redirected_path: '/embus/980190962/edit', user: :lars
    screenshot('my_embu')
  end
end
