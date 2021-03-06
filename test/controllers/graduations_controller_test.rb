# frozen_string_literal: true

require 'controller_test'

class GraduationsControllerTest < ActionController::TestCase
  setup do
    @first_id = graduations(:panda).id
    login(:uwe)
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_show
    get :show, params: { id: @first_id }
    assert_response :success
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_new_for_instructor
    login(:lars)
    get :new
    assert_response :success
  end

  def test_create
    assert_difference 'Graduation.count' do
      post :create, params: { graduation: { held_on: '2007-10-07', group_id: groups(:panda).id,
                                            group_notification: true } }
    end
    assert_response :redirect
    assert_redirected_to edit_graduation_path(Graduation.last)
  end

  def test_create_for_instructor
    login(:lars)
    assert_difference 'Graduation.count' do
      post :create, params: { graduation: { held_on: '2007-10-07', group_id: groups(:panda).id,
                                            group_notification: true } }
    end
    assert_response :redirect
    assert_redirected_to edit_graduation_path(Graduation.last)
  end

  def test_edit
    get :edit, params: { id: @first_id }
    assert_response :success
  end

  def test_update
    post :update, params: { id: @first_id, graduation: { held_on: '2007-10-07' } }
    assert_response :redirect
    assert_redirected_to action: :edit, id: @first_id, anchor: :form_tab
  end

  def test_destroy
    assert_nothing_raised do
      Graduation.find(@first_id)
    end

    post :destroy, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to action: :index, id: nil

    assert_raise(ActiveRecord::RecordNotFound) do
      Graduation.find(@first_id)
    end
  end

  def test_send_date_change_message
    get :send_date_change_message, params: { id: @first_id }
    assert_redirected_to edit_graduation_path(@first_id, anchor: 'form_tab')
  end

  def test_certificates
    get :certificates, params: { id: @first_id }
    assert_response :success
  end

  def test_censor_form
    get :censor_form, params: { id: @first_id }
    assert_response :success
  end

  def test_censor_form_pdf
    get :censor_form_pdf, params: { id: @first_id }
    assert_response :success
  end

  def test_lock
    assert_equal [nil, nil], graduations(:panda).censors.map(&:locked_at)
    post :lock, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to edit_graduation_path(@first_id)
    assert_equal [Time.current.to_f, 0.0], graduations(:panda).censors.reload
        .order(:locked_at).map(&:locked_at).map(&:to_f)
    assert_equal [Time.current, nil], graduations(:panda).censors.reload
        .order(:locked_at).map(&:locked_at)
  end

  def test_approve
    assert_equal [nil, nil], graduations(:panda).censors.map(&:approved_grades_at)
    post :approve, params: { id: @first_id }
    assert_response :redirect
    assert_redirected_to edit_graduation_path(@first_id)
    assert_equal [Time.current.to_f, 0.0], graduations(:panda).censors.reload
        .order(:approved_grades_at).map(&:approved_grades_at).map(&:to_f)
    assert_equal [Time.current, nil], graduations(:panda).censors.reload
        .order(:approved_grades_at).map(&:approved_grades_at)
  end
end
