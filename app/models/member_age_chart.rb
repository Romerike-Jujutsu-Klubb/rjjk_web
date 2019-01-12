# frozen_string_literal: true

class MemberAgeChart
  def self.data_set(timestamp = Member.maximum(:updated_at).strftime('%F_%T.%N'))
    Rails.cache.fetch(age_group_key(timestamp)) do
      members = Member.active(Date.current).select { |m| m.paying? || m.active? }
      member_ages = members.map(&:age)
      max_age = ((member_ages.max / 5.0).ceil * 5)
      age_groups = [0..5, 6..9, 10..14, 15..19, 20..24, 25..29, 30..39, 40..49, 50..max_age]
      age_data = age_groups.map { |age_range| members.select { |m| age_range.cover? m.age } }
      age_groups = age_groups.map(&:to_s).zip(age_data)
      chart_data = [
        {
          name: 'Totalt',
          data: age_groups.map { |group, mbrs| [group, mbrs.size] }, color: :black
        },
        {
          name: 'Betalende',
          data: age_groups.map { |group, mbrs| [group, mbrs.select(&:paying?).size] }, color: :red
        },
        {
          name: 'Aktive',
          data: age_groups.map { |group, mbrs| [group, mbrs.select(&:active?).size] }, color: :green
        },
      ]
      [age_groups, chart_data]
    end
  end

  private_class_method def self.age_group_key(timestamp)
    "member_reports/age_groups/#{timestamp}"
  end
end
