require 'test_helper'

class RankTest < ActiveSupport::TestCase
  fixtures :ranks

  def test_minimum_age
    graduation = Graduation.create!(:group_id => groups(:tiger).id,
        :held_on => Date.parse('2014-06-10'))
    member = members(:sebastian)
    assert_equal 9, member.age
    assert_equal 10, member.age(graduation.held_on)
    assert_equal ranks(:mon_12), member.current_rank(graduation.martial_art, graduation.held_on)
    assert_equal 10, ranks(:mon_10).minimum_age
    assert_equal 14, ranks(:kyu_4).minimum_age
    assert_equal ranks(:mon_10), member.next_rank(graduation)
  end
end
