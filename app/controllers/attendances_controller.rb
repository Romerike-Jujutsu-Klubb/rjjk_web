class AttendancesController < ApplicationController
  USER_ACTIONS = [:announce, :plan, :review]
  before_filter :authenticate_user, only: USER_ACTIONS
  before_filter :instructor_required, except: USER_ACTIONS

  # FIXME(uwe):  check caching
  caches_page :history_graph, :month_chart, :month_per_year_chart
  update_actions = [:announce, :create, :destroy, :review, :update]
  cache_sweeper :attendance_image_sweeper, :only => update_actions
  cache_sweeper :grade_history_image_sweeper, :only => update_actions

  def index
    @attendances = Attendance.all
  end

  def since_graduation
    @member = Member.find(params[:id])
    @date = params[:date].try(:to_date) || Date.today
    @graduate = @member.current_graduate(nil, @date)
    @attendances = @member.attendances_since_graduation(@date)
  end

  def show
    @attendance = Attendance.find(params[:id])
  end

  def new
    @attendance ||= Attendance.new params[:attendance]
    if @attendance.practice && @attendance.practice.try(:new_record?)
      practice = Practice.where(:group_schedule_id => @attendance.practice.group_schedule_id, :year => @attendance.practice.year, :week => @attendance.practice.week).first
      @attendance.practice = practice if practice
    end
    @attendance.status ||= Attendance::Status::ATTENDED
    group_id = params[:group]
    @members = Member.order(:first_name, :last_name).to_a
    @group_schedules = GroupSchedule.where(group_id ? { :group_id => group_id } : {}).to_a
    render :action => 'new'
  end

  def edit
    @attendance = Attendance.find(params[:id])
  end

  def create
    if params[:attendance][:group_schedule_id]
      params[:attendance][:practice_id] = Practice.find_by_group_schedule_id_and_year_and_week(
          params[:attendance].delete(:group_schedule_id),
          params[:attendance].delete(:year), params[:attendance].delete(:week)
      ).id
    end
    @attendance = Attendance.new(params[:attendance], without_protection: true)
    if @attendance.save
      flash[:notice] = 'Attendance was successfully created.'
      if request.xhr?
        flash.clear
        render partial: '/attendances/attendance_delete_link', locals: { attendance: @attendance }
      else
        back_or_redirect_to(@attendance)
      end
    else
      new
    end
  end

  def update
    @attendance = Attendance.find(params[:id])
    if @attendance.update_attributes(params[:attendance])
      flash[:notice] = 'Attendance was successfully updated.'
      redirect_to(@attendance)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @attendance = Attendance.find(params[:id])
    @attendance.destroy
    if request.xhr?
      flash.clear
      render :partial => '/attendances/attendance_create_link', :locals => {
              :member_id => @attendance.member_id,
              :group_schedule_id => @attendance.practice.group_schedule_id,
              :date => @attendance.date, :status => Attendance::Status::ATTENDED
          }
    else
      redirect_to(attendances_url)
    end
  end

  def report
    @date = (params[:year] && params[:month] && Date.new(params[:year].to_i, params[:month].to_i, 1)) || Date.today.beginning_of_month
    @year = @date.cwyear
    @month = @date.month
    @first_date = @date
    @last_date = @date.end_of_month
    @attendances = Attendance.includes(:practice => :group_schedule).references(:practices)
        .where('practices.year = ? AND practices.week >= ? AND practices.week <= ? AND attendances.status NOT IN (?)',
            @year, @first_date.cweek, @last_date.cweek, Attendance::ABSENT_STATES)
        .to_a.select { |a| (@first_date..@last_date).cover? a.date }
    monthly_per_group = @attendances.group_by { |a| a.group_schedule.group }.sort_by { |g, ats| g.from_age }
    @monthly_summary_per_group = {}
    monthly_per_group.each do |g, attendances|
      @monthly_summary_per_group[g] = {}
      @monthly_summary_per_group[g][:attendances] = attendances
      @monthly_summary_per_group[g][:present] = attendances.select { |a| !Attendance::ABSENT_STATES.include?(a.status) && a.date <= Date.today }
      @monthly_summary_per_group[g][:absent] = attendances.select { |a| Attendance::ABSENT_STATES.include? a.status }
      @monthly_summary_per_group[g][:practices] = @monthly_summary_per_group[g][:present].map(&:practice_id).uniq.size
    end
    @by_group_and_member = Hash[monthly_per_group.map { |g, ats| [g, ats.group_by(&:member)] }]
  end

  def history_graph
    if params[:id] && params[:id].to_i <= 1280
      if params[:id] =~ /^\d+x\d+$/
        g = AttendanceHistoryGraph.new.history_graph params[:id]
      else
        g = AttendanceHistoryGraph.new.history_graph params[:id].to_i
      end
    else
      g = AttendanceHistoryGraph.new.history_graph
    end
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => 'RJJK_Oppmøtehistorikk.png')
  end

  def month_chart
    if params[:size] && params[:size].to_i <= 1280
      if params[:size] =~ /^\d+x\d+$/
        g = AttendanceHistoryGraph.new.month_chart params[:year].to_i, params[:month].to_i, params[:size]
      else
        g = AttendanceHistoryGraph.new.month_chart params[:year].to_i, params[:month].to_i, params[:size].to_i
      end
    else
      g = AttendanceHistoryGraph.new.month_chart
    end
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => 'RJJK_Oppmøtehistorikk.png')
  end

  def announce
    m = (params[:member_id] && Member.find(params[:member_id])) || current_user.member
    year = params[:year].to_i
    week = params[:week].to_i
    gs_id = params[:group_schedule_id]
    if year > 0 && week > 0 && gs_id
      practice = Practice.where(group_schedule_id: gs_id,
          year: year, week: week).first_or_create!
    else
      practice = m.groups.where(name: 'Voksne').first.next_practice
    end
    criteria = { member_id: m.id, practice_id: practice.id }
    @attendance = Attendance.includes(:practice).where(criteria).first_or_initialize

    new_status = params[:status]
    if new_status == 'toggle'
      if !@attendance.practice.passed? && @attendance.status == Attendance::Status::WILL_ATTEND
        new_status = nil
        @attendance.destroy
        @attendance = nil
      elsif @attendance.status == Attendance::Status::ATTENDED
        new_status = Attendance::Status::ABSENT
      else
        new_status = @attendance.practice.passed? ? Attendance::Status::ATTENDED : Attendance::Status::WILL_ATTEND
      end
    end
    @attendance.update_attributes!(status: new_status) if new_status
    if request.xhr?
      if params[:status] == 'toggle'
        render partial: 'plan_practice', locals: { gs: practice.group_schedule,
                year: year, week: week, attendance: @attendance }
      else
        render :partial => 'attendance_delete_link', :locals => { :attendance => @attendance }
      end
    else
      back_or_redirect_to(@attendance)
    end
  end

  def plan
    today = Date.today

    @weeks = [[today.cwyear, today.cweek], [(today + 7).cwyear, (today + 7).cweek]]
    if today.month >= 6 && today.month <= 7
      @weeks += [[(today + 14).cwyear, (today + 14).cweek], [(today + 21).cwyear, (today + 21).cweek]]
    end

    member = current_user.member
    last_unconfirmed = member.attendances.includes(:practice).references(:practices)
        .where("attendances.status = 'P' AND (practices.year < ? OR (practices.year = ? AND practices.week < ?))",
            today.cwyear, today.cwyear, today.cweek)
        .order('practices.year, practices.week').last
    if last_unconfirmed
      @weeks.unshift [last_unconfirmed.date.cwyear, last_unconfirmed.date.cweek]
    end
    if flash[:attendance_id]
      @reviewed_attendance = Attendance.find(flash[:attendance_id])
      @weeks.unshift [@reviewed_attendance.date.cwyear, @reviewed_attendance.date.cweek]
      @weeks.sort!.uniq!
    end
    @group_schedules = member.groups.reject(&:school_breaks).map(&:group_schedules).flatten
    @weeks.each do |w|
      @group_schedules.each { |gs| gs.practices.where(year: today.cwyear, week: today.cweek).first_or_create! }
      @group_schedules.each { |gs| gs.practices.where(year: (today + 7).cwyear, week: (today + 7).cweek).first_or_create! }
    end
    @planned_attendances = Attendance.includes(:practice).references(:practices)
        .where("member_id = ? AND (practices.year, practices.week) IN (#{@weeks.map { |y, w| "(#{y}, #{w})" }.join(', ')})", member.id)
        .to_a
    start_date = 6.months.ago.to_date.beginning_of_month
    attendances = Attendance.includes(practice: { group_schedule: :group }).references(:practices)
        .where('member_id = ? AND attendances.status IN (?) AND ((practices.year = ? AND practices.week >= ?) OR (practices.year = ?))',
            member, Attendance::PRESENT_STATES, start_date.cwyear, start_date.cweek, today.cwyear)
        .to_a
    @attended_groups = attendances.map { |a| a.practice.group_schedule.group }.uniq.sort_by { |g| -g.from_age }
    per_month = attendances.group_by do |a|
      d = a.date
      [d.cwyear, d.mon]
    end
    @months = per_month.keys.sort.reverse.map do |ym|
      per_group = per_month[ym].group_by { |a| a.group_schedule.group }
      [t(:date)[:month_names][ym[1]], *@attended_groups.map { |g| (per_group[g] || []).size }]
    end
    if member.current_rank
      attendances_since_graduation = member.attendances_since_graduation
      if attendances_since_graduation.size > 0
        by_group = attendances_since_graduation.group_by { |a| a.group_schedule.group }
        @months << ['Siden gradering', *@attended_groups.map { |g| (by_group[g] || []).size }]
      end
    end
  end

  def review
    group_schedule_id = params[:group_schedule_id]
    year = params[:year].to_i
    week = params[:week].to_i
    unless year > 0 && week > 0 && group_schedule_id
      redirect_to({ action: :plan }, notice: 'Year and week is required')
      return
    end
    practice = Practice.where(group_schedule_id: group_schedule_id,
        year: year, week: week).first_or_create!
    @attendance = Attendance
        .where(member_id: current_user.member.id, practice_id: practice.id)
        .first_or_create
    new_status = params[:status]
    if new_status == 'toggle'
      new_status =
          case @attendance.status
          when Attendance::Status::WILL_ATTEND, Attendance::Status::ABSENT, Attendance::Status::HOLIDAY
            Attendance::Status::ATTENDED
          when Attendance::Status::ATTENDED, Attendance::Status::INSTRUCTOR, Attendance::Status::ASSISTANT
            Attendance::Status::ABSENT
          when nil
            Attendance::Status::ATTENDED
          end
    end
    @attendance.update_attributes! status: new_status

    if request.xhr?
      render partial: 'plan_practice', locals: { gs: practice.group_schedule,
              year: year, week: week, attendance: @attendance }
    else
      flash[:notice] = "Bekreftet oppmøte #{@attendance.date}:  #{t(:attendances)[@attendance.status.to_sym]}"
      flash[:attendance_id] = @attendance.id
      redirect_to attendance_plan_path
    end
  end

  def form_index
    @groups = Group.active(Date.today).order :from_age
  end

  def form
    if params[:year] && params[:month]
      @date = Date.parse("#{params[:year]}-#{params[:month]}-01")
    end
    @date ||= Date.today

    first_date = Date.new(@date.year, @date.month, 1)
    last_date = Date.new(@date.year, @date.month, -1)

    if params[:group_id]
      if params[:group_id] == 'others'
        @instructors = []
        @members = Member.includes(attendances: { group_schedule: :group })
            .where('id NOT in (SELECT DISTINCT member_id FROM groups_members) AND (left_on IS NULL OR left_on > ?)', @date)
            .to_a
        @trials = []
        weekdays = [2, 4]
        @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }
        current_members = []
        attended_members = []
      else
        @group = Group.includes(:martial_art).find(params[:group_id])
        weekdays = @group.group_schedules.map { |gs| gs.weekday }
        @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }

        @instructors = Member.active(@date)
            .includes({ attendances: { practice: :group_schedule }, graduates: [:graduation, :rank] }, :groups, :nkf_member)
            .where(instructor: true)
            .select { |m| m.groups.any? { |g| g.martial_art_id == @group.martial_art_id } }
        @instructors.delete_if { |m| m.attendances.select { |a| ((@dates.first - 92.days)..@dates.last).cover?(a.date) && a.group_schedule.group_id == @group.id }.empty? }
        @instructors += GroupInstructor.includes(:group_schedule, member: [{ attendances: { practice: :group_schedule } }, :nkf_member])
            .where('group_instructors.member_id NOT IN (?)', @instructors.map(&:id))
            .where(group_schedules: { group_id: @group.id }).to_a
            .select { |gi| @dates.any? { |d| gi.active?(d) } }.map(&:member).uniq

        current_members = @group.members.active(first_date, last_date)
            .includes({ :attendances => { :practice => :group_schedule }, :graduates => [:graduation, :rank], :groups => :group_schedules }, :nkf_member)
        attended_members = Member.references(:practices)
            .includes(:attendances => { :practice => :group_schedule }, :graduates => [:graduation, :rank])
            .where('members.id NOT IN (?) AND practices.group_schedule_id IN (?) AND (year > ? OR ( year = ? AND week >= ?)) AND (year < ? OR ( year = ? AND week <= ?))',
                @instructors.map(&:id), @group.group_schedules.map(&:id), first_date.cwyear, first_date.cwyear, first_date.cweek, last_date.cwyear, last_date.cwyear, last_date.cweek)
            .to_a
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
      @instructors = []
      @members = []
      @trials = []
      current_members = []
      weekdays = [2, 4]
      @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }
    end

    @instructors -= current_members
    @passive_members = (@members - attended_members).select { |m| m.passive?(last_date, @group) }
    @members -= @passive_members
    @instructors -= @passive_members

    @birthdate_missing = @members.empty? || @members.find { |m| m.birthdate.nil? }

    render :layout => 'print'
  end

  def month_per_year_chart
    if params[:size] && params[:size].to_i <= 1600
      if params[:size] =~ /^\d+x\d+$/
        size = params[:size]
      else
        size = params[:size].to_i
      end
    else
      size = '800x600'
    end
    g = AttendanceHistoryGraph.new.month_per_year_chart params[:month].to_i, size
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => 'RJJK_Oppmøtehistorikk.png')
  end
end
