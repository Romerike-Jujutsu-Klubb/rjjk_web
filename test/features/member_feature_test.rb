# frozen_string_literal: true

require 'capybara_setup'

class MemberFeatureTest < ActionDispatch::IntegrationTest
  setup { screenshot_section :member }

  def test_show
    screenshot_group :show
    visit_with_login member_path(members(:sebastian))
    screenshot :details
    find('a.nav-link', text: 'Graderinger').click
    screenshot :graduations
    click_on 'Web-bruker'
    screenshot :user
    find('a.nav-link', text: 'Verv').click
    screenshot :duties
    click_on 'Signaturer'
    screenshot :signatures
    click_on 'NKF'
    screenshot :nkf_tab
  end
end
