# frozen_string_literal: true

require 'integration_test'

class GraduatesControllerTest < IntegrationTest
  def setup
    @graduate = graduates(:lars_kyu_1)
    @first_id = @graduate.id
    login(:uwe)
  end

  def test_index
    get graduates_path
    assert_response :success
  end

  def test_show
    get graduate_path @first_id
    assert_response :success
  end

  def test_new
    get new_graduate_path
    assert_response :success
  end

  def test_create
    num_graduates = Graduate.count

    post graduates_path, params: { graduate: { member_id: members(:lars).id,
                                               graduation_id: graduations(:tiger).id,
                                               passed: true, rank_id: ranks(:kyu_4).id,
                                               paid_graduation: true, paid_belt: true } }
    assert_response :redirect
    assert_redirected_to action: :index
    assert_equal num_graduates + 1, Graduate.count
  end

  def test_edit
    get edit_graduate_path @first_id
    assert_response :success
  end

  def test_update
    patch graduate_path(@first_id), params: { graduate: { member_id: members(:lars).id } }
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
  end

  def test_destroy
    assert_nothing_raised do
      @graduate.reload
    end

    delete graduate_path @first_id
    assert_response :redirect
    assert_redirected_to edit_graduation_path(@graduate.graduation_id)

    assert_raise(ActiveRecord::RecordNotFound) do
      @graduate.reload
    end
  end

  def test_accept
    assert_nil @graduate.confirmed_at
    assert_nil @graduate.declined
    post accept_graduate_path @first_id
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
    assert_not_nil @graduate.reload.confirmed_at
    assert_equal false, @graduate.declined
  end

  def test_accept_get
    get accept_graduate_path @first_id # request method is get when coming from an email
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
    assert_not_nil @graduate.reload.confirmed_at
    assert_equal false, @graduate.declined
  end

  def test_decline
    post decline_graduate_path @first_id
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
    assert_not_nil @graduate.reload.confirmed_at
    assert_equal true, @graduate.declined
  end

  def test_decline_get
    get decline_graduate_path @first_id  # request method is get when coming from an email
    assert_response :redirect
    assert_redirected_to action: :show, id: @first_id
    assert_not_nil @graduate.reload.confirmed_at
    assert_equal true, @graduate.declined
  end
end
