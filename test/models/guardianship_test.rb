# frozen_string_literal: true

require 'test_helper'

class GuardianshipTest < ActiveSupport::TestCase
  test 'must be valid' do
    assert guardianships(:uwe_sebastian).valid?
  end
end
