require 'test_helper'

class EmbuTest < ActionDispatch::IntegrationTest
  fixtures :all

  def test_display_my_embu
    visit_with_login '/embus', redirected_path: '/embus/980190962/edit', user: :lars
    screenshot('my_embu')
  end

end
