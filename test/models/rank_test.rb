require 'test_helper'

class RankTest < ActiveSupport::TestCase
  fixtures :ranks

  def test_minimum_age
    graduation = Graduation.create!(group_id: groups(:tiger).id,
        held_on: Date.parse('2014-06-10'))
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
            '12. mon blå stripe', '11. mon blå stripe m/svart bånd',
            '10. mon gule kanter', '5. kyu gult', '4. kyu oransje',
            '1. kyu brunt', 'shodan svart', 'nidan svart m/2 striper',
            'sandan svart m/3 striper',
        ],
        Rank.order(:position).all.map(&:label)
  end
end
