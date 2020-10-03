# frozen_string_literal: true

class Array
  def without_consecutive_zeros
    each_with_index do |v, i|
      non_zero = v.positive? || (i.positive? && self[i - 1].to_i.positive?) ||
          self[i + 1].to_i.positive?
      self[i] = (non_zero ? v : nil)
    end
  end
end

class MemberHistoryGraph
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  ACTIVE_CLAUSE = ->(date) do
    "NOT EXISTS (
      SELECT kontraktsbelop FROM nkf_members
      WHERE member_id = members.id AND kontraktsbelop::integer <= 0)
        AND (joined_on IS NULL OR joined_on <= '#{date.strftime('%Y-%m-%d')}')
        AND (left_on IS NULL OR left_on > '#{date.strftime('%Y-%m-%d')}'
    )"
  end
  NON_PAYING_CLAUSE = ->(date) do
    "EXISTS (
      SELECT kontraktsbelop FROM nkf_members
      WHERE member_id = members.id AND kontraktsbelop::integer <= 0)
        AND (joined_on IS NULL OR joined_on <= '#{date.strftime('%Y-%m-%d')}')
        AND (left_on IS NULL OR left_on > '#{date.strftime('%Y-%m-%d')}'
    )"
  end

  def self.totals(dates)
    dates.map do |date|
      Member.where(ACTIVE_CLAUSE.call(date)).count + Member.where(NON_PAYING_CLAUSE.call(date))
          .count
    end
  end

  def self.totals_paying(dates)
    dates.map { |_date| Member.where(ACTIVE_CLAUSE.call(date)).count }
  end

  def self.gratis(dates)
    dates.map { |date| Member.where(NON_PAYING_CLAUSE.call(date)).count }
  end

  def self.totals_jj(dates)
    dates.map do |date|
      Member.includes(user: { groups: :martial_art }).references(:martial_arts)
          .where(ACTIVE_CLAUSE.call(date))
          .where("martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai'")
          .count
    end
  end

  def self.seniors_jj(dates)
    dates.map do |date|
      Member
          .where("(#{ACTIVE_CLAUSE.call(date)})")
          .where('birthdate IS NOT NULL AND users.birthdate < ?', senior_birthdate(date))
          .where("(martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai')")
          .references(:martial_arts, :users).includes(user: { groups: :martial_art }).count
    end
  end

  def self.juniors_jj(dates)
    dates.map do |date|
      Member
          .where(ACTIVE_CLAUSE.call(date))
          .where('users.birthdate IS NOT NULL AND users.birthdate BETWEEN ? AND ?',
              senior_birthdate(date), junior_birthdate(date))
          .where("(martial_arts.name IS NULL OR martial_arts.name <> 'Aikikai')")
          .references(:martial_arts, :users).includes(user: { groups: :martial_art }).count
    end
  end

  def self.seniors_ad(dates)
    dates.map do |date|
      Member
          .where(ACTIVE_CLAUSE.call(date))
          .where('birthdate IS NOT NULL AND birthdate < ?',
              senior_birthdate(date))
          .where("martial_arts.name = 'Aikikai'")
          .references(:martial_arts).includes(groups: :martial_art).count
    end
  end

  def self.juniors_ad(dates)
    dates.map do |date|
      Member
          .where(ACTIVE_CLAUSE.call(date))
          .where('birthdate IS NOT NULL AND birthdate >= ?',
              senior_birthdate(date))
          .where("martial_arts.name = 'Aikikai'")
          .references(:martial_arts).includes(groups: :martial_art).count
    end
  end

  def self.aspirants(dates)
    dates.map do |date|
      Member.includes(:user).references(:users).where(ACTIVE_CLAUSE.call(date))
          .where('users.birthdate IS NOT NULL AND birthdate >= ?', junior_birthdate(date))
          .count
    end
  end

  def self.senior_birthdate(date)
    date - JUNIOR_AGE_LIMIT.years
  end

  def self.junior_birthdate(date)
    date - ASPIRANT_AGE_LIMIT.years
  end

  def self.data_set
    first_date = Date.civil(2011, 1, 1)
    dates = []
    Date.current.step(first_date, -14) { |date| dates << date }
    dates.reverse!
    data = {
      'Totalt' => [totals(dates), :gray],
      'Totalt betalende' => [totals_jj(dates), :blue],
      'Voksne' => [seniors_jj(dates), Group.find_by(name: 'Voksne').color],
      'Tiger' => [juniors_jj(dates), Group.find_by(name: 'Tiger').color],
      'Panda' => [aspirants(dates), Group.find_by(name: 'Panda').color],
      'Gratis' => [gratis(dates), :red],
      'Prøvetid' => [
        dates.map { |d| NkfMemberTrial.where('reg_dato <= ?', d).count }.without_consecutive_zeros,
        :yellow,
      ],
    }
    [data, dates]
  end
end
