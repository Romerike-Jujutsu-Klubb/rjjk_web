# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../test_helper"

class GraduateTest < ActiveSupport::TestCase
  test 'cannot be destroyed after invitation' do
    g = graduates(:lars_kyu_1)
    g.update! invitation_sent_at: Time.current
    assert_raises ActiveRecord::RecordNotDestroyed do
      g.destroy!
    end
  end
end
