# frozen_string_literal: true

module AttendanceFormDataLoader
  private

  def load_form_data(year, month, group_id)
    @year = year
    @month = month
    first_date = Date.new(year, month, 1)
    last_date = Date.new(year, month, -1)

    @group = Group.includes(:group_schedules, :martial_art).find(group_id)
    weekdays = @group.group_schedules.map(&:weekday)
    @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }

    @instructors = @group.active_instructors(@dates)

    current_members = @group.members.active(first_date, last_date)
        .includes({ user: { attendances: { practice: :group_schedule }, groups: :group_schedules },
                    graduates: %i[graduation rank] },
            :nkf_member)
    attended_query = Member.references(:practices)
        .includes(user: { attendances: { practice: :group_schedule } }, graduates: %i[graduation rank])
        .where(practices: { group_schedule_id: @group.group_schedules.map(&:id) })
        .where('year > ? OR ( year = ? AND week >= ?)',
            first_date.cwyear, first_date.cwyear, first_date.cweek)
        .where('year < ? OR ( year = ? AND week <= ?)',
            last_date.cwyear, last_date.cwyear, last_date.cweek)
    attended_query = attended_query.where.not('members.id' => @instructors.map(&:id)) if @instructors.any?
    attended_members = attended_query.to_a
    @members = current_members | attended_members
    @trials = @group.trials

    @instructors.sort_by! do |m|
      r = m.current_rank(@group.martial_art_id, last_date)
      [r ? -r.position : 99, m.first_name, m.last_name]
    end
    @members.sort_by! do |m|
      r = m.current_rank(@group.martial_art_id, first_date)
      [r ? -r.position : 99, m.first_name, m.last_name]
    end

    @instructors -= current_members
    @passive_members = (@members - attended_members).select { |m| m.passive_or_absent?(last_date, @group) }
    @members -= @passive_members
    @instructors -= @passive_members

    @birthdate_missing = @members.empty? || @members.find { |m| m.birthdate.nil? }
  end
end
