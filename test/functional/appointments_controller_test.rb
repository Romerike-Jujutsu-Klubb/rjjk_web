require 'test_helper'

class AppointmentsControllerTest < ActionController::TestCase
  setup do
    @appointment = appointments(:uwe_first)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:appointments)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create appointment' do
    assert_difference('Appointment.count') do
      post :create, appointment: { from: @appointment.from,
          member_id: @appointment.member_id,
          role_id: @appointment.role_id, to: @appointment.to }
      assert_no_errors :appointment
    end

    assert_redirected_to appointment_path(assigns(:appointment))
  end

  test 'should show appointment' do
    get :show, id: @appointment
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @appointment
    assert_response :success
  end

  test 'should update appointment' do
    put :update, id: @appointment, appointment: { from: @appointment.from,
        member_id: @appointment.member_id, role_id: @appointment.role_id,
        to: @appointment.to }
    assert_redirected_to appointment_path(assigns(:appointment))
  end

  test 'should destroy appointment' do
    assert_difference('Appointment.count', -1) do
      delete :destroy, id: @appointment
    end

    assert_redirected_to appointments_path
  end
end
