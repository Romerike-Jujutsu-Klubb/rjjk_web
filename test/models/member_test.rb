# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../test_helper"

class MemberTest < ActiveSupport::TestCase
  test 'next_rank' do
    assert_equal ['sandan', 'shodan', '11. mon', '5. kyu', '5. kyu', '5. kyu'],
        Member.order(:joined_on).all.map(&:next_rank).map(&:name)
  end

  test 'emails' do
    assert_equal [
      ['lars@example.com'],
      ['leftie@example.com'],
      ['lise@example.com', 'sebastian@example.com', 'uwe@example.com'],
      ['neuer@example.com', 'newbie@example.com'],
      ['oldie@example.com'],
      ['uwe@example.com'],
    ], Member.order(:id).map(&:emails)
  end
end
