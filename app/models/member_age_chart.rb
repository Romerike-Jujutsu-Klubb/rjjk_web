# frozen_string_literal: true

class MemberAgeChart
  def self.data_set
    members = Member.active(Date.current).to_a
    member_ages = members.map(&:age)
    max_age = ((member_ages.max / 5.0).ceil * 5)
    age_groups = [0..5, 6..9, 10..14, 15..19, 20..24, 25..29, 30..39, 40..49, 50..max_age]
    age_data = age_groups.map { |age_range| members.select { |m| age_range.cover? m.age }.size }
    [age_data, age_groups]
  end
end
