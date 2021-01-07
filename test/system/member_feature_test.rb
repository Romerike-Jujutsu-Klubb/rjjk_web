# frozen_string_literal: true

require 'application_system_test_case'

class MemberFeatureTest < ApplicationSystemTestCase
  def test_show
    visit_with_login member_path(members(:sebastian)), redirected_path: '/users/594055058'
    screenshot :membership
    find('a.nav-link', text: 'Sebastian Kubosch').click
    screenshot :person
    find('a.nav-link', text: 'Graderinger').click
    screenshot :graduations
    find('a.nav-link', text: 'Verv').click
    screenshot :duties
    # find('a.nav-link', text: 'Signaturer').click
    screenshot :signatures
  end
end
