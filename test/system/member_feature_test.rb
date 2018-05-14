# frozen_string_literal: true

require 'feature_test'

class MemberFeatureTest < FeatureTest
  setup { screenshot_section :member }

  def test_show
    screenshot_group :show
    visit_with_login member_path(members(:sebastian))
    screenshot :person
    find('a.nav-link', text: 'Medlemskap').click
    screenshot :membership
    find('a.nav-link', text: 'Foresatt 1').click
    screenshot :parent_1
    find('a.nav-link', text: 'Graderinger').click
    screenshot :graduations
    find('a.nav-link', text: 'Verv').click
    screenshot :duties
    find('a.nav-link', text: 'Signaturer').click
    screenshot :signatures
    find('a.nav-link', text: 'NKF').click
    screenshot :nkf_tab
  end
end
