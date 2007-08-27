require File.dirname(__FILE__) + '/../test_helper'
require 'members_controller'

# Re-raise errors caught by the controller.
class MembersController; def rescue_action(e) raise e end; end

class MembersControllerTest < Test::Unit::TestCase
  fixtures :members, :users
  
  def setup
    @controller = MembersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @first_id = members(:first).id
    @request.session['user'] = users(:admin)
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end
  
  def test_list
    get :list
    
    assert_response :success
    assert_template 'list'
    
    assert_not_nil assigns(:members)
  end
  
  def test_new
    get :new
    
    assert_response :success
    assert_template 'new'
    
    assert_not_nil assigns(:member)
  end
  
  def test_create
    num_members = Member.count
    
    post :create, :member => { :male => true,
      :first_name => 'Lars',
      :last_name => 'Bråten',
      :senior => true,
      :address => 'Torsvei 8b',
      :postal_code => 1472,
      :payment_problem => false,
      :instructor => false,
      :nkf_fee => true
    }
    
    assert_response :redirect
    assert_redirected_to :action => 'list'
    
    assert_equal num_members + 1, Member.count
  end
  
  def test_edit
    get :edit, :id => @first_id
    
    assert_response :success
    assert_template 'edit'
    
    assert_not_nil assigns(:member)
    assert assigns(:member).valid?
  end
  
  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
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
end
