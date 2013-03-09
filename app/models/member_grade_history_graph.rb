# encoding: utf-8
require 'gruff'
class MemberGradeHistoryGraph
  ACTIVE_CLAUSE = '"EXISTS (SELECT 1 FROM attendances WHERE member_id = members.id
AND (year > #{prev_date.cwyear} OR (year = #{prev_date.cwyear} AND week >= #{prev_date.cweek}))
AND (year < #{date.cwyear} OR (year = #{date.cwyear} AND week <= #{date.cweek})))

AND (\'#{next_date}\' > CURRENT_DATE OR
EXISTS (SELECT 1 FROM attendances WHERE member_id = members.id
AND (year > #{date.cwyear} OR (year = #{date.cwyear} AND week >= #{date.cweek}))
AND (year < #{next_date.cwyear} OR (year = #{next_date.cwyear} AND week <= #{next_date.cweek}))))

AND (joined_on IS NULL OR joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\') AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'

  ATTENDANCE_CLAUSE = '"(SELECT COUNT(*) FROM attendances WHERE member_id = members.id
AND (year > #{prev_date.cwyear} OR (year = #{prev_date.cwyear} AND week >= #{prev_date.cweek}))
AND (year < #{date.cwyear} OR (year = #{date.cwyear} AND week <= #{date.cweek}))) >= #{(practices * percentage) / 100}

AND (joined_on IS NULL OR joined_on <= \'#{date.strftime(\'%Y-%m-%d\')}\') AND (left_on IS NULL OR left_on > \'#{date.strftime(\'%Y-%m-%d\')}\')"'

  def self.history_graph(options)
    size = options[:size] || 480
    interval = options[:interval] || 8.weeks
    step = options[:step] || 1.weeks
    percentage = options[:percentage]

    ranks = MartialArt.find_by_name('Kei Wa Ryu').ranks.reverse
    ranks = ranks.first(9)[1..-1]

    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = 'Fordeling av grader'
    if percentage
      g.title_font_size *= 0.95
      g.title += " med oppmøte over #{percentage}%"
    end
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.hide_dots = true
    g.colors = %w{yellow yellow orange orange green green blue blue yellow yellow orange orange green green blue blue brown yellow orange green blue brown black black black}.last(ranks.size)

    # first_date = Member.order(:joined_on).first.joined_on
    # first_date = 5.years.ago.to_date
    first_date = Date.civil(2010, 8, 1)
    # first_date = Date.civil(2011, 1, 1)
    dates = []
    Date.today.step(first_date, -step) { |date| dates << date }
    dates.reverse!
    sums = nil
    data = ranks.map do |rank|
      rank_totals = totals(rank, dates, interval, percentage)
      if sums
        sums = sums.zip(rank_totals).map { |s, t| s + t }
      else
        sums = rank_totals
      end
    end

    data.reverse.zip(ranks.reverse) { |d, rank| g.data(rank.name, d) }

    g.minimum_value = 0

    labels = {}
    current_year = nil
    current_month = nil
    dates.each_with_index { |date, i|
      if date.month != current_month && [1, 8].include?(date.month)
        labels[i] = (date.year != current_year ? "#{date.strftime('%m')}\n    #{date.strftime('%Y')}" : "#{date.strftime('%m')}"); current_year = date.year; current_month = date.month
      end }
    g.labels = labels

    g.maximum_value = 25
    g.marker_count = 5
    g.to_blob
  end

  def self.totals(rank, dates, interval, percentage)
    dates.each.map do |date|
      prev_date = date - interval
      next_date = date + interval
      practices = Group.find_by_name('Voksne').trainings_in_period(prev_date..date)
      active_members = Member.all(
          :select => (Member.column_names - %w(image)).join(','),
          :conditions => eval(percentage ? ATTENDANCE_CLAUSE : ACTIVE_CLAUSE),
          :include => {:graduates => {:graduation => :martial_art}}
      )
      ranks = active_members.select { |m| m.graduates.select { |g| g.graduation.martial_art.name =='Kei Wa Ryu' && g.graduation.held_on <= date }.sort_by { |g| g.graduation.held_on }.last.try(:rank) == rank }.size
      logger.debug "#{prev_date} #{date} #{next_date} Active members: #{active_members.size}, ranks: #{ranks}"
      ranks
    end
  end

  def self.logger
    Rails.logger
  end

end
