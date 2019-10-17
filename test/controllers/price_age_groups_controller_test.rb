# frozen_string_literal: true

require 'test_helper'

class PriceAgeGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @price_age_group = price_age_groups(:panda)
    login :uwe
  end

  test 'should get index' do
    get price_age_groups_url
    assert_response :success
  end

  test 'should get new' do
    get new_price_age_group_url
    assert_response :success
  end

  test 'should create price_age_group' do
    assert_difference('PriceAgeGroup.count') do
      post price_age_groups_url, params: { price_age_group: {
        from_age: 1, monthly_fee: @price_age_group.monthly_fee, name: 'Mygger', to_age: 4,
        yearly_fee: @price_age_group.yearly_fee
      } }
    end

    assert_redirected_to price_age_group_url(PriceAgeGroup.last)
  end

  test 'should show price_age_group' do
    get price_age_group_url(@price_age_group)
    assert_response :success
  end

  test 'should get edit' do
    get edit_price_age_group_url(@price_age_group)
    assert_response :success
  end

  test 'should update price_age_group' do
    patch price_age_group_url(@price_age_group), params: { price_age_group: {
      from_age: @price_age_group.from_age, monthly_fee: @price_age_group.monthly_fee,
      name: @price_age_group.name, to_age: @price_age_group.to_age,
      yearly_fee: @price_age_group.yearly_fee
    } }
    assert_redirected_to price_age_group_url(@price_age_group)
  end

  test 'should destroy price_age_group' do
    assert_difference('PriceAgeGroup.count', -1) do
      delete price_age_group_url(@price_age_group)
    end

    assert_redirected_to price_age_groups_url
  end
end
