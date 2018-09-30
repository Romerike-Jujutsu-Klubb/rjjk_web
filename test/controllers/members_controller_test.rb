# frozen_string_literal: true

require 'controller_test'

class MembersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  def setup
    @lars = members(:lars)
    login(:admin)
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
  end

  def test_list_active
    get :list_active
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:members)
  end

  def test_list_inactive
    get :list_inactive
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:members)
  end

  def test_list
    get :index
    assert_response :success
    assert_template :index
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
    assert_template 'members/telephone_list'
    assert_template layout: 'dark_ritual'
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:member)
  end

  def test_create_with_user_and_guardians
    num_members = Member.count

    VCR.use_cassette 'GoogleMaps Lars' do
      post :create, params: { member: {
        payment_problem: false,
        instructor: false,
        nkf_fee: true,
        joined_on: '2007-06-21',
        user_id: id(:unverified_user),
        user_attributes: {
          birthdate: '1967-06-21',
          email: 'lars@example.net',
          first_name: 'Lars',
          last_name: 'Bråten',
          male: true,
          guardians_attributes: [
            {},
          ],
        },
      } }
    end

    assert_response :redirect
    assert_redirected_to action: :edit, id: assigns(:member).id
    assert_equal 'Medlem opprettet.', flash[:notice]
    assert_equal num_members + 1, Member.count
  end

  def test_edit
    get :edit, params: { id: @lars.id }

    assert_response :success
    assert_template 'edit'

    assert_no_errors :member
  end

  def test_update
    assert_enqueued_with(job: NkfMemberSyncJob) do
      VCR.use_cassette 'GoogleMaps Lars' do
        post :update, params: { id: @lars.id, member: { user_attributes: { id: @lars.user_id, male: true } } }
      end
    end
    assert_equal 1, ActiveJob::Base.queue_adapter.enqueued_jobs.count
    assert_no_errors :member
    assert_response :redirect
    assert_redirected_to action: :edit, id: @lars.id
  end

  def test_destroy
    Member.find(@lars.id)
    delete :destroy, params: { id: @lars.id }
    assert_response :redirect
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      Member.find(@lars.id)
    end
  end

  def test_thumbnail
    get :thumbnail, params: { id: id(:lars) }
    assert_response :success
  end

  def test_save_image
    post :save_image, params: { id: id(:lars), imgBase64: 'data:content/type;base64,some data' }
    assert_response :success
  end

  def test_yaml
    get :yaml
    assert_response :success
  end
end
