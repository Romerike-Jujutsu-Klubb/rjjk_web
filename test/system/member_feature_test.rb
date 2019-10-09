# frozen_string_literal: true

require 'application_system_test_case'

class MemberFeatureTest < ApplicationSystemTestCase
  setup { screenshot_section :member }

  def test_show
    screenshot_group :show
    visit_with_login member_path(members(:sebastian)), redirected_path: '/users/594055058'
    screenshot :person
    find('a.nav-link', text: 'Medlemskap').click
    screenshot :membership
    find('a.nav-link', text: 'Kontakter').click
    screenshot :contacts
    find('a.nav-link', text: 'Graderinger').click
    screenshot :graduations
    find('a.nav-link', text: 'Verv').click
    screenshot :duties
    # find('a.nav-link', text: 'Signaturer').click
    screenshot :signatures
    find('a.nav-link', text: 'NKF').click
    screenshot :nkf_tab
    execute_script 'window.scrollBy(0, $(window).height())'
    screenshot :nkf_tab_down
  end
end
