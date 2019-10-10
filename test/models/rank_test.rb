# frozen_string_literal: true

require 'test_helper'

class RankTest < ActiveSupport::TestCase
  def test_minimum_age
    graduation = Graduation.create! group_id: groups(:tiger).id, held_on: Date.parse('2014-06-10'),
                                    group_notification: true
    member = members(:sebastian)
    assert_equal 9, member.age
    assert_equal 10, member.age(graduation.held_on)
    assert_equal ranks(:mon_12), member.current_rank(graduation.martial_art, graduation.held_on)
    assert_equal 10, ranks(:mon_10).minimum_age
    assert_equal 14, ranks(:kyu_4).minimum_age
    assert_equal ranks(:mon_10), member.next_rank(graduation)
  end

  test 'label' do
    assert_equal [
      '12. mon blå stripe', '11. mon blå stripe m/svart bånd', '10. mon gule kanter', '5. kyu gult belte',
      '4. kyu oransje belte', '1. kyu brunt belte', 'shodan svart belte', 'shodan svart belte',
      'nidan svart belte m/2 striper', 'nidan svart belte m/2 striper', 'sandan svart belte m/3 striper',
      'sandan svart belte m/3 striper'
    ],
        Rank.order(:position).all.map(&:label)
  end
end
