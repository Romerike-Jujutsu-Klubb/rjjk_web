# frozen_string_literal: true
class Array
  def without_consecutive_zeros
    each_with_index { |v, i| self[i] = (v.positive? || (i.positive? && self[i - 1].to_i.positive?) || self[i + 1].to_i.positive? ? v : nil) }
  end
end

class MemberHistoryGraph
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  ACTIVE_CLAUSE = ->(date) do
    "NOT EXISTS (
      SELECT kontraktsbelop FROM nkf_members
      WHERE member_id = members.id AND kontraktsbelop <= 0)
        AND (joined_on IS NULL OR joined_on <= '#{date.strftime('%Y-%m-%d')}')
        AND (left_on IS NULL OR left_on > '#{date.strftime('%Y-%m-%d')}'
    )"
  end
  NON_PAYING_CLAUSE = ->(date) do
    "EXISTS (
      SELECT kontraktsbelop FROM nkf_members
      WHERE member_id = members.id AND kontraktsbelop <= 0)
        AND (joined_on IS NULL OR joined_on <= '#{date.strftime('%Y-%m-%d')}')
        AND (left_on IS NULL OR left_on > '#{date.strftime('%Y-%m-%d')}'
    )"
  end

  def self.history_graph(size = 480)
    begin
      require 'gruff'
    rescue MissingSourceFile
      return File.read('public/images/rails.png')
    end

    g = Gruff::Line.new(size)
    g.theme_37signals
    g.title = 'Antall aktive medlemmer'
    g.font = '/usr/share/fonts/bitstream-vera/Vera.ttf'
    g.legend_font_size = 14
    g.marker_font_size = 14
    g.hide_dots = true
    g.colors = %w(gray blue brown orange black red yellow lightblue green)

    first_date = Date.civil(2011, 1, 1)
    dates = []
    Date.today.step(first_date, -14) { |date| dates << date }
    dates.reverse!
    g.data('Totalt', totals(dates))
    g.data('Totalt betalende', totals_jj(dates))
    g.data('Voksne', seniors_jj(dates))
    g.data('Tiger', juniors_jj(dates))
    g.data('Panda', aspirants(dates))
    g.data('Gratis', gratis(dates))
    g.data('Prøvetid', dates.map { |d| NkfMemberTrial.where('reg_dato <= ?', d).count }.without_consecutive_zeros)

    g.minimum_value = 0

    labels = {}
    current_year = nil
    current_month = nil
    dates.each_with_index do |date, i|
      next unless date.month != current_month && [1, 8].include?(date.month)
      labels[i] = (date.year != current_year ? "#{date.strftime('%m')}\n    #{date.strftime('%Y')}" : date.strftime('%m'))
      current_year = date.year
      current_month = date.month
    end
    g.labels = labels

    # g.draw_vertical_legend

    precision = 1
    g.maximum_value = (g.maximum_value.to_s[0..precision].to_i + 1) * (10**(Math.log10(g.maximum_value.to_i).to_i - precision)) if g.maximum_value.positive?
    g.maximum_value = [100, g.maximum_value].max
    g.marker_count = g.maximum_value / 10
    g.to_blob
  end

  def self.totals(dates)
    dates.map { |date| Member.where(ACTIVE_CLAUSE.call(date)).count + Member.where(NON_PAYING_CLAUSE.call(date)).count }
  end

  def self.totals_paying(dates)
    dates.map { |_date| Member.where(ACTIVE_CLAUSE.call(date)).count }
  end

  def self.gratis(dates)
    dates.map { |date| Member.where(NON_PAYING_CLAUSE.call(date)).count }
  end

  def self.totals_jj(dates)
    dates.map do |date|
      Member.includes(groups: :martial_art).references(:martial_arts)
          .where("(#{ACTIVE_CLAUSE.call(date)}) AND (martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai')")
          .count
    end
  end

  def self.seniors_jj(dates)
    dates.map do |date|
      Member
          .where("(#{ACTIVE_CLAUSE.call(date)})")
          .where('birthdate IS NOT NULL AND birthdate < ?', senior_birthdate(date))
          .where("(martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai')")
          .references(:martial_arts).includes(groups: :martial_art).count
    end
  end

  def self.juniors_jj(dates)
    dates.map do |date|
      Member
          .where("(#{ACTIVE_CLAUSE.call(date)}) AND birthdate IS NOT NULL AND birthdate BETWEEN ? AND ?",
              senior_birthdate(date), junior_birthdate(date))
          .where("(martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai')")
          .references(:martial_arts).includes(groups: :martial_art).count
    end
  end

  def self.seniors_ad(dates)
    dates.map do |date|
      Member.where("(#{ACTIVE_CLAUSE.call(date)}) AND birthdate IS NOT NULL AND birthdate < '#{senior_birthdate(date)}' AND martial_arts.name = 'Aikikai'")
          .references(:martial_arts).includes(groups: :martial_art).count
    end
  end

  def self.juniors_ad(dates)
    dates.map do |date|
      Member.where("(#{ACTIVE_CLAUSE.call(date)}) AND birthdate IS NOT NULL AND birthdate >= '#{senior_birthdate(date)}' AND martial_arts.name = 'Aikikai'")
          .references(:martial_arts).includes(groups: :martial_art).count
    end
  end

  def self.aspirants(dates)
    dates.map { |date| Member.where("(#{ACTIVE_CLAUSE.call(date)}) AND birthdate IS NOT NULL AND birthdate >= '#{junior_birthdate(date)}'").count }
  end

  def self.was_senior?(date)
    birthdate.nil? || ((date - birthdate) / 365) > JUNIOR_AGE_LIMIT
  end

  def self.senior_birthdate(date)
    date - JUNIOR_AGE_LIMIT.years
  end

  def self.junior_birthdate(date)
    date - ASPIRANT_AGE_LIMIT.years
  end
end
