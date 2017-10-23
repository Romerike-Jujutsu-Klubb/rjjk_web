# frozen_string_literal: true

require 'test_helper'

class NkfMemberTest < ActiveSupport::TestCase
  test 'converted_attributes' do
    expected = {
      address: 'Bøkeveien 11',
      billing_email: nil,
      billing_phone_mobile: nil,
      birthdate: Date.parse('1974-04-01'),
      email: 'erik@example.net',
      first_name: 'Erik',
      joined_on: Date.parse('1996-05-01'),
      last_name: 'Øyan',
      left_on: nil,
      male: true,
      parent_2_mobile: nil,
      parent_2_name: nil,
      parent_email: nil,
      parent_name: nil,
      phone_home: nil,
      phone_mobile: nil,
      phone_work: nil,
      postal_code: '1470',
    }
    assert_equal expected, Hash[nkf_members(:erik).converted_attributes.sort]
  end
end
