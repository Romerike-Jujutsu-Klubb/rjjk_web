# frozen_string_literal: true

require 'test_helper'

class NkfMemberTest < ActiveSupport::TestCase
  test 'converted_attributes' do
    expected = {
      billing: {
        email: nil,
      },
      guardian_1: {
        email: nil,
        phone: nil,
      },
      guardian_2: {
        name: nil,
        phone: nil,
      },
      membership: {
        joined_on: Date.parse('1996-05-01'),
        left_on: nil,
        martial_art_name: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Voksne',
        phone_home: nil,
        phone_work: nil,
      },
      trial: { reg_dato: nil },
      user: {
        address: 'Bøkeveien 11',
        birthdate: Date.parse('1974-04-01'),
        contact_email: 'erik@example.net',
        first_name: 'Erik',
        guardian_1_or_billing_name: nil,
        height: nil,
        last_name: 'Øyan',
        male: true,
        phone: nil,
        postal_code: '1470',
      },
    }
    assert_equal expected, Hash[nkf_members(:erik).converted_attributes.sort_by_key]
  end
end

class Hash
  def sort_by_key(&block)
    keys.sort(&block).each_with_object({}) do |key, seed|
      seed[key] = self[key]
      seed[key] = seed[key].sort_by_key(&block) if seed[key].is_a?(Hash)
    end
  end
end
