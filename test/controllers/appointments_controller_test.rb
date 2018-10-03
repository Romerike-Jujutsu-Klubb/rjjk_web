# frozen_string_literal: true

require 'controller_test'

# FIXME(uwe): Convert to IntergratonTest instead
class AppointmentsControllerTest < ActionController::TestCase
  setup do
    @appointment = appointments(:uwe_first)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create appointment' do
    assert_difference('Appointment.count') do
      post :create, params: { appointment: { from: @appointment.from,
                                             member_id: @appointment.member_id,
                                             role_id: @appointment.role_id, to: @appointment.to } }
    end

    assert_redirected_to appointment_path(Appointment.last)
  end

  test 'should show appointment' do
    get :show, params: { id: @appointment }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @appointment }
    assert_response :success
  end

  test 'should update appointment' do
    put :update, params: { id: @appointment, appointment: {
      from: @appointment.from, member_id: @appointment.member_id, role_id: @appointment.role_id,
      to: @appointment.to
    } }
    assert_redirected_to appointments_path
  end

  test 'should destroy appointment' do
    assert_difference('Appointment.count', -1) do
      delete :destroy, params: { id: @appointment }
    end

    assert_redirected_to appointments_path
  end
end
