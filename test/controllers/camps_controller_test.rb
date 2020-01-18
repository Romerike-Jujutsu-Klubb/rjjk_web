# frozen_string_literal: true

require 'integration_test'

class CampsControllerTest < IntegrationTest
  test 'get camp' do
    get event_path(events(:camp))
    assert_response :success
  end

  test 'get edit anonymously' do
    get edit_event_path(events(:camp))
    assert_redirected_to login_path
  end

  test 'get edit' do
    login
    get edit_event_path(events(:camp))
    assert_response :success
  end

  test 'get update' do
    login
    patch event_path(id(:camp)), params: { event: { name: 'The SUPER Camp' } }
    assert_redirected_to edit_event_path(id(:camp))
    assert_equal 'The SUPER Camp', events(:camp).name
  end
end
