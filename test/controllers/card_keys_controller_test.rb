# frozen_string_literal: true

require 'test_helper'

class CardKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @card_key = card_keys(:one)
  end

  test 'should get index' do
    get card_keys_url
    assert_response :success
  end

  test 'should get new' do
    get new_card_key_url
    assert_response :success
  end

  test 'should create card_key' do
    assert_difference('CardKey.count') do
      post card_keys_url, params: { card_key: {
        comment: @card_key.comment, label: @card_key.label, user_id: @card_key.user_id
      } }
    end

    assert_redirected_to card_keys_url
  end

  test 'should show card_key' do
    get card_key_url(@card_key)
    assert_response :success
  end

  test 'should get edit' do
    get edit_card_key_url(@card_key)
    assert_response :success
  end

  test 'should update card_key' do
    patch card_key_url(@card_key), params: { card_key: {
      comment: @card_key.comment, label: @card_key.label, user_id: @card_key.user_id
    } }
    assert_redirected_to card_keys_url
  end

  test 'should destroy card_key' do
    assert_difference('CardKey.count', -1) do
      delete card_key_url(@card_key)
    end

    assert_redirected_to card_keys_url
  end
end
