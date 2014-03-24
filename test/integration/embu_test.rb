require File.expand_path('../test_helper', File.dirname(__FILE__))

class EmbuTest < ActionDispatch::IntegrationTest
  fixtures :all

  def test_display_my_embu
    visit_with_login '/embus'
    screenshot('my_embu')
  end

end
