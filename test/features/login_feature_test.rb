# frozen_string_literal: true

require 'controller_test'
require 'integration_test'
require 'feature_test'

# This file contains differents ways to log in during tests to test wether they interfere with each other.

# Sequence that fails:
#
#
# Sequences that succeed:
#

class LoginControllerTest < ActionController::TestCase
  test 'controller test login' do
    login(:admin)
  end

  test 'controller action login' do
    post :login_with_password, params: LoginIntegrationTest::LOGIN_PARAMS
    assert_logged_in(:admin)
  end
end

class LoginIntegrationTest < IntegrationTest
  LOGIN_PARAMS = { user: { login: 'admin', password: 'atest' } }.freeze
  test 'integration test login' do
    login(:admin)
    assert_logged_in
  end

  test 'integration action login' do
    post '/login/password', params: LOGIN_PARAMS
    assert_logged_in
  end
end

class LoginFeatureTest < FeatureTest
  setup { screenshot_section :session }

  def test_login_with_password
    screenshot_group :login_with_password
    visit '/'
    click_menu 'Logg inn'
    assert_current_path '/login?detour%5Baction%5D=index&detour%5Bcontroller%5D=welcome'
    click_on 'logge på med passord'
    assert_current_path '/login/password'
    screenshot :empty_form
    fill_in 'user_login', with: :admin
    fill_in 'user_password', with: :atest
    screenshot :filled_in
    click_button 'Logg inn'
    assert_current_path '/'
    screenshot :welcome
  end

  def test_send_email_link
    screenshot_group :email_link
    visit '/'
    click_menu 'Logg inn'
    assert_current_path '/login?detour%5Baction%5D=index&detour%5Bcontroller%5D=welcome'
    screenshot :email_form
    fill_in 'user_email', with: users(:admin).email
    screenshot :email_filled_in
    click_on 'Send e-post'
    assert_current_path '/'
    screenshot :email_sent
    assert_equal 1, UserMessage.pending.size
    msg = UserMessage.pending[0]
    assert_match %r{<h1>Hei Uwe Kubosch!</h1>}, msg.body
    assert_match %r{<a href="https://example.com/">Klikk meg for å logge på Romerike Jujutsu Klubb!</a>},
        msg.body
    UserMessageSender.send
    assert_equal 1, Mail::TestMailer.deliveries.size
    email = Mail::TestMailer.deliveries[0]
    assert %r{<a href="(https://example.com/\?key=([^"]+))">Klikk meg for å logge på Romerike Jujutsu Klubb!</a>} =~
        email.body.decoded
    visit root_path(key: Regexp.last_match(2))
    open_menu
    assert has_css?('h1', text: 'Uwe Kubosch'), all('h1').to_a.map(&:text).inspect
    screenshot :welcome
  end
end
