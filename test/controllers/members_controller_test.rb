# frozen_string_literal: true

require 'controller_test'

class MembersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  setup do
    @lars = members(:lars)
    login(:uwe)
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_list_active
    get :list_active
    assert_response :success
  end

  def test_list_inactive
    get :list_inactive
    assert_response :success
  end

  def test_list
    get :index
    assert_response :success
  end

  def test_email_list
    get :email_list
    assert_response :success
  end

  def test_telephone_list
    get :telephone_list
    assert_response :success
  end

  def test_new
    get :new

    assert_response :success
  end

  def test_create_with_user_and_guardians
    num_members = Member.count

    VCR.use_cassette 'GoogleMaps Lars' do
      post :create, params: { member: {
        instructor: false,
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
    assert_redirected_to action: :edit, id: Member.last.id
    assert_equal 'Medlem opprettet.', flash[:notice]
    assert_equal num_members + 1, Member.count
  end

  def test_edit
    get :edit, params: { id: @lars.id }

    assert_redirected_to user_path(@lars.user, anchor: :tab_membership_228855109_tab)
  end

  def test_update
    VCR.use_cassette 'GoogleMaps Lars' do
      post :update, params: { id: @lars.id, member: { user_attributes: { id: @lars.user_id, male: true } } }
    end
    assert_response :redirect
    assert_redirected_to action: :edit, id: @lars.id
  end

  def test_destroy
    Member.find(@lars.id)
    delete :destroy, params: { id: @lars.id }
    assert_response :redirect
    assert_redirected_to users(:lars)

    assert_raise(ActiveRecord::RecordNotFound) do
      Member.find(@lars.id)
    end
  end
end
