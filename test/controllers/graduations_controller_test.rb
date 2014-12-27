require 'test_helper'

class GraduationsControllerTest < ActionController::TestCase
  fixtures :users, :martial_arts, :graduations

  def setup
    @first_id = graduations(:panda).id
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert assigns :graduations
    assert_template 'index'
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:graduation)
    assert assigns(:graduation).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:graduation)
  end

  def test_create
    num_graduations = Graduation.count

    post :create, :graduation => {:held_on => '2007-10-07', :group_id => groups(:panda).id}

    assert_no_errors :graduation
    assert_response :redirect
    assert_redirected_to :action => :index

    assert_equal num_graduations + 1, Graduation.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:graduation)
    assert assigns(:graduation).valid?
  end

  def test_update
    post :update, id: @first_id, graduation: {}
    assert_response :redirect
    assert_redirected_to action: 'show', id: @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Graduation.find(@first_id)
    }

    post :destroy, id: @first_id
    assert_response :redirect
    assert_redirected_to action: :index, id: nil

    assert_raise(ActiveRecord::RecordNotFound) {
      Graduation.find(@first_id)
    }
  end

  def test_certificates
    get :certificates, id: @first_id
    assert_response :success
  end

  def test_censor_form
    get :censor_form, id: @first_id
    assert_response :success
  end

  def test_censor_form_pdf
    get :censor_form_pdf, id: @first_id
    assert_response :success
  end

  def test_approve
    assert_equal [nil, nil], graduations(:panda).censors.map(&:approved_grades_at)
    post :approve, id: @first_id
    assert_response :redirect
    assert_redirected_to edit_graduation_path(@first_id)
    assert_equal [0.0, Time.now.to_f.ish(1)], graduations(:panda).censors(true).map(&:approved_grades_at).map(&:to_f)
    assert_equal [nil, Time.now.ish], graduations(:panda).censors(true).map(&:approved_grades_at)
  end

end
