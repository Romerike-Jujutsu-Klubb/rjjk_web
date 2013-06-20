# encoding: UTF-8
require File.dirname(__FILE__) + '/../test_helper'
require 'members_controller'

# Re-raise errors caught by the controller.
class MembersController
  def rescue_action(e)
    raise e
  end
end

class MembersControllerTest < ActionController::TestCase
  fixtures :members, :users

  def setup
    @controller = MembersController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    @first_id = members(:first).id
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list_active
    get :list_active
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:members)
  end

  def test_list_inactive
    get :list_inactive
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:members)
  end

  def test_list
    get :list
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:members)
  end

  def test_email_list
    get :email_list
    assert_response :success
    assert_template 'email_list'
  end

  def test_telephone_list
    get :telephone_list
    assert_response :success
    assert_template 'list'
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:member)
  end

  def test_create
    num_members = Member.count

    post :create, :member => {:male => true,
                              :first_name => 'Lars',
                              :last_name => 'Bråten',
                              :address => 'Torsvei 8b',
                              :postal_code => 1472,
                              :payment_problem => false,
                              :instructor => false,
                              :nkf_fee => true,
                              :joined_on => '2007-06-21',
                              :birthdate => '1967-06-21',
                              :user_id => users(:unverified_user).id,
    }

    assert_no_errors :member
    assert_response :redirect
    assert_redirected_to :action => :edit, :id => assigns(:member).id

    assert_equal num_members + 1, Member.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_no_errors :member
  end

  def test_update
    post :update, :id => @first_id
    assert_no_errors :member
    assert_response :redirect
    assert_redirected_to :action => 'edit', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Member.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Member.find(@first_id)
    }
  end

  def test_grade_history_graph
    get :grade_history_graph
    assert_response :success
  end

  def test_grade_history_graph_800
    get :grade_history_graph, :id => 800, :format => 'png'
    assert_response :success
  end

  def test_grade_history_graph_percentage
    get :grade_history_graph_percentage
    assert_response :success
  end

  def test_grade_history_graph_percentage_800
    get :grade_history_graph_percentage, :id => 800, :format => 'png',
        :interval => 365, :percentage => 67, :step => 30
    assert_response :success
  end

end
