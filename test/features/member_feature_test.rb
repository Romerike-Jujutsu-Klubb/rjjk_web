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
    find('a.nav-link', text: 'Web-bruker').click
    screenshot :user
    find('a.nav-link', text: 'Verv').click
    screenshot :duties
    find('a.nav-link', text: 'Signaturer').click
    screenshot :signatures
    find('a.nav-link', text: 'NKF').click
    screenshot :nkf_tab
  end
end
