# frozen_string_literal: true
class MemberGradeHistoryGraph
  ACTIVE_CLAUSE = <<EOF
EXISTS (
  SELECT 1
  FROM attendances a
    INNER JOIN practices p ON p.id = a.practice_id
  WHERE member_id = members.id
    AND (p.year > ? OR (p.year = ? AND p.week >= ?))
    AND (p.year < ? OR (p.year = ? AND p.week <= ?))
)
AND (
  ? > CURRENT_DATE
  OR EXISTS (
    SELECT 1
    FROM attendances a
      INNER JOIN practices p ON p.id = a.practice_id
    WHERE member_id = members.id
      AND (p.year > ? OR (p.year = ? AND p.week >= ?))
      AND (p.year < ? OR (p.year = ? AND p.week <= ?))))
AND (joined_on IS NULL OR joined_on <= ?)
AND (left_on IS NULL OR left_on > ?)
EOF

  ATTENDANCE_CLAUSE = '(SELECT COUNT(*)
                        FROM attendances a
                          INNER JOIN practices p ON p.id = a.practice_id
                        WHERE member_id = members.id
                          AND (p.year > ? OR (p.year = ? AND p.week >= ?))
                          AND (p.year < ? OR (p.year = ? AND p.week <= ?))
                        ) >= ?
                        AND (joined_on IS NULL OR joined_on <= ?)
                        AND (left_on IS NULL OR left_on > ?)'

  def initialize
    @practices = {}
    @active_members = {}
    @group = Group.includes(:group_schedules).find_by_name('Voksne')
  end

  def history_graph(options = {})
    size = options[:size] || 480
    interval = options[:interval] || 8.weeks
    step = (options[:step] || 3.months)
    percentage = options[:percentage]

    ranks = MartialArt.find_by_name('Kei Wa Ryu').ranks.reverse
    ranks = ranks.first(9)[1..-1]

    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = 'Fordeling av grader'
    g.legend_font_size = 15
    g.legend_box_size = 15
    g.marker_font_size = 14
    if percentage
      g.title_font_size *= 0.95
      g.title += "\nmed oppmøte over #{percentage}%"
    end
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.hide_dots = true
    g.colors = (%w(yellow yellow orange orange green green blue blue) * 2 +
        %w(brown yellow orange green blue brown black black black)
               ).last(ranks.size)

    # first_date = 5.years.ago.to_date
    first_date = Date.civil(2011, 1, 1)
    dates = (first_date..Date.today).step(step / 1.day).to_a
    sums = nil
    data = ranks.map do |rank|
      rank_totals = totals(rank, dates, interval, percentage)
      sums = if sums
               sums.zip(rank_totals).map { |s, t| s + t }
             else
               rank_totals
             end
    end

    data.reverse.zip(ranks.reverse) { |d, rank| g.data(rank.name, d) }

    g.minimum_value = 0

    labels = {}
    current_year = nil
    dates.each_with_index do |date, i|
      next unless date.year != current_year
      labels[i] = date.strftime('%Y').to_s
      current_year = date.year
    end
    g.labels = labels
    g.y_axis_increment = 5
    g.to_blob
  end

  def totals(rank, dates, interval, percentage)
    dates.each.map do |date|
      prev_date = date - interval
      next_date = date + interval
      @practices[date] ||= @group.trainings_in_period(prev_date..date)
      @active_members[date] ||= Member
          .where(
              if percentage
                [ATTENDANCE_CLAUSE, prev_date.cwyear, prev_date.cwyear, prev_date.cweek,
                    date.cwyear, date.cwyear, date.cweek, (@practices[date] * percentage) / 100,
                    date, date]
              else
                [ACTIVE_CLAUSE, prev_date.cwyear, prev_date.cwyear, prev_date.cweek,
                    date.cwyear, date.cwyear, date.cweek, next_date, date.cwyear,
                    date.cwyear, date.cweek, next_date.cwyear, next_date.cwyear,
                    next_date.cweek, date, date]
              end
          )
          .includes(graduates: [{ graduation: { group: :martial_art } }, :rank]).to_a
      ranks = @active_members[date].select do |m|
        m.graduates.select do |g|
          g.graduation.martial_art.kwr? && g.graduation.held_on <= date
        end.sort_by { |g| g.graduation.held_on }.last.try(:rank) == rank
      end.size
      logger.debug <<~EOF
        "#{prev_date} #{date} #{next_date} Active members: #{@active_members[date].size}, ranks: #{ranks}"
      EOF
      ranks
    end
  end
end
