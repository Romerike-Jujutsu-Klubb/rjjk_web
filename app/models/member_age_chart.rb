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
    (0..60).to_a.each { |a| g.labels[a] = (a % 5).zero? ? a.to_rfc2445_string : '' }
    members = Member.active(Date.current).to_a
    g.data('Antall per årstrinn',
        g.labels.keys.map { |age| members.select { |m| m.age == age }.size })
    g.minimum_value = 0
    g.maximum_value = 12
    g.marker_count = 6
    g.to_blob
  end
end
