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

        if (chief_instructor = @group.current_semester&.chief_instructor)
          @instructors << chief_instructor
        end
        group_instructors_query = GroupInstructor
            .includes(:group_schedule,
                member: [{ attendances: { practice: :group_schedule } }, :nkf_member])
            .where(group_schedules: { group_id: @group.id })
        if @instructors.any?
          group_instructors_query = group_instructors_query
              .where('group_instructors.member_id NOT IN (?)', @instructors.map(&:id))
        end
        @instructors += group_instructors_query.to_a.select { |gi| @dates.any? { |d| gi.active?(d) } }
            .map(&:member).uniq
        instructors_query = Member.active(@date)
            .includes({ attendances: { practice: :group_schedule },
                        graduates: %i[graduation rank] }, :groups, :nkf_member)
            .where(instructor: true)
        if @instructors.any?
          instructors_query = instructors_query.where('id NOT IN (?)', @instructors.map(&:id))
        end
        @instructors += instructors_query
            .select { |m| m.groups.any? { |g| g.martial_art_id == @group.martial_art_id } }
            .select do |m|
              m.attendances.any? do |a|
                ((@dates.first - 92.days)..@dates.last).cover?(a.date) &&
                    a.group_schedule.group_id == @group.id
              end
            end

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
