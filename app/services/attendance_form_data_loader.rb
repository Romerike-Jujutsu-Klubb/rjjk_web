# frozen_string_literal: true

module AttendanceFormDataLoader
  private

  def load_form_data(year, month, group_id)
    # FIXME(uwe): Remove use of `@date` and use `first_date` and `last_date` instead
    @date = year && month ? Date.parse("#{year}-#{month}-01") : Date.current

    first_date = Date.new(@date.year, @date.month, 1)
    last_date = Date.new(@date.year, @date.month, -1)

    @instructors = []
    if group_id
      if group_id == 'others'
        @members = Member.includes(attendances: { group_schedule: :group })
            .where('id NOT in (SELECT DISTINCT member_id FROM group_memberships)')
            .where('left_on IS NULL OR left_on > ?', @date)
            .to_a
        @trials = []
        weekdays = [2, 4]
        @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }
        current_members = []
        attended_members = []
      else
        @group = Group.includes(:martial_art).find(group_id)
        weekdays = @group.group_schedules.map(&:weekday)
        @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }

        @instructors = @group.active_instructors(@dates)

        current_members = @group.members.active(first_date, last_date)
            .includes({ attendances: { practice: :group_schedule },
                        graduates: %i[graduation rank], groups: :group_schedules },
                :nkf_member)
        attended_query = Member.references(:practices)
            .includes(attendances: { practice: :group_schedule }, graduates: %i[graduation rank])
            .where('practices.group_schedule_id IN (?)', @group.group_schedules.map(&:id))
            .where('year > ? OR ( year = ? AND week >= ?)',
                first_date.cwyear, first_date.cwyear, first_date.cweek)
            .where('year < ? OR ( year = ? AND week <= ?)',
                last_date.cwyear, last_date.cwyear, last_date.cweek)
        if @instructors.any?
          attended_query = attended_query.where('members.id NOT IN (?)', @instructors.map(&:id))
        end
        attended_members = attended_query.to_a
        @members = current_members | attended_members
        @trials = @group.trials

        @instructors.sort_by! do |m|
          r = m.current_rank(@group.martial_art, last_date)
          [r ? -r.position : 99, m.first_name, m.last_name]
        end
        @members.sort_by! do |m|
          r = m.current_rank(@group.martial_art, first_date)
          [r ? -r.position : 99, m.first_name, m.last_name]
        end
      end
    else
      @members = []
      @trials = []
      current_members = []
      weekdays = [2, 4]
      @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }
      attended_members = []
    end

    @instructors -= current_members
    @passive_members = (@members - attended_members).select { |m| m.passive?(last_date, @group) }
    @members -= @passive_members
    @instructors -= @passive_members

    @birthdate_missing = @members.empty? || @members.find { |m| m.birthdate.nil? }
  end
end
