# frozen_string_literal: true
require 'gruff'
class MemberAgeChart
  def self.chart(size = 480)
    g = Gruff::Bar.new(size)
    g.theme_37signals
    g.title = 'Antall aktive medlemmer'
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.hide_legend = true
    g.colors = %w(darkblue)
    g.labels = {}
    members = Member.active(Date.current).to_a
    member_ages = members.map(&:age)
    age_range = 0..((member_ages.max / 5.0).ceil * 5)
    age_range.select { |a| a % 5 == 0 }.each { |a| g.labels[a] = a.to_s }
    g.data('Antall per årstrinn', age_range.map { |age| members.select { |m| m.age == age }.size })
    g.minimum_value = 0
    g.maximum_value = 12
    g.marker_count = 6
    g.to_blob
  end
end
