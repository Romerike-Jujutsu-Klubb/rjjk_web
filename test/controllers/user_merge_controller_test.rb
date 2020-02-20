# frozen_string_literal: true

require 'integration_test'

class UserMergeControllerTest < IntegrationTest
  setup { login }

  test 'show' do
    get user_merge_path(id(:uwe), other_user_id: id(:lars))
    assert_response :success
  end

  test 'update' do
    VCR.use_cassette('NKF Comparison Single Member Uwe', match_requests_on: %i[method host path query]) do
      patch user_merge_path(id(:uwe), other_user_id: id(:lise))
    end
    assert_redirected_to users(:uwe)
    assert_raise(ActiveRecord::RecordNotFound) { users(:lise) }
  end

  test 'update fails with invalid other user - no name' do
    other_user_label = :uwe
    users(other_user_label).update! name: nil

    assert_no_difference(-> { User.count }) do
      patch user_merge_path(id(:lise), other_user_id: id(other_user_label))
    end

    assert_response :success
    assert users(other_user_label).reload
  end

  test 'update - card key is moved' do
    other_user_label = :lise
    other_user_id = id(other_user_label)
    card_keys(:uwe).update! user_id: other_user_id
    VCR.use_cassette('NKF Comparison Single Member Uwe', match_requests_on: %i[method host path query]) do
      patch user_merge_path(id(:uwe), other_user_id: other_user_id)
    end
    assert_redirected_to users(:uwe)
    assert_raise(ActiveRecord::RecordNotFound) { users(other_user_label) }
    assert_equal id(:uwe), card_keys(:uwe).reload.user_id
  end
end
