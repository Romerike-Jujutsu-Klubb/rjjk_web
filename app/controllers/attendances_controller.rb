# encoding: UTF-8
class AttendancesController < ApplicationController
  user_actions = [:announce, :plan, :review]
  before_filter :admin_required, :except => user_actions
  before_filter :authenticate_user, :only => user_actions

  caches_page :history_graph, :month_chart, :month_per_year_chart
  update_actions = [:announce, :create, :destroy, :review, :update]
  cache_sweeper :attendance_image_sweeper, :only => update_actions
  cache_sweeper :grade_history_image_sweeper, :only => update_actions

  def index
    @attendances = Attendance.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @attendances }
    end
  end

  def since_graduation
    @member = Member.find(params[:id])
    @date = params[:date].try(:to_date) || Date.today
    @graduate = @member.current_graduate(nil, @date)
    @attendances = @member.attendances_since_graduation(@date)
  end

  def show
    @attendance = Attendance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @attendance }
    end
  end

  def new
    @attendance ||= Attendance.new params[:attendance]
    @attendance.status ||= Attendance::Status::ATTENDED
    group_id = params[:group]
    @members = Member.order(:first_name, :last_name).all
    @group_schedules = GroupSchedule.where(group_id ? {:group_id => group_id} : {}).all

    respond_to do |format|
      format.html { render :action => 'new' }
      format.xml { render :xml => @attendance }
    end
  end

  def edit
    @attendance = Attendance.find(params[:id])
  end

  def create
    @attendance = Attendance.new(params[:attendance])

    respond_to do |format|
      if @attendance.save
        flash[:notice] = 'Attendance was successfully created.'
        format.html do
          if request.xhr?
            flash.clear
            render :partial => '/attendances/attendance_delete_link', :locals => {:attendance => @attendance}
          else
            back_or_redirect_to(@attendance)
          end
          format.xml { render :xml => @attendance, :status => :created, :location => @attendance }
        end
      else
        format.html { new }
        format.xml { render :xml => @attendance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @attendance = Attendance.find(params[:id])

    respond_to do |format|
      if @attendance.update_attributes(params[:attendance])
        flash[:notice] = 'Attendance was successfully updated.'
        format.html { redirect_to(@attendance) }
        format.xml { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml { render :xml => @attendance.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @attendance = Attendance.find(params[:id])
    @attendance.destroy

    respond_to do |format|
      format.html do
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
      format.xml { head :ok }
    end
  end

  def report
    @date = (params[:year] && params[:month] && Date.new(params[:year].to_i, params[:month].to_i, 1)) || Date.today.beginning_of_month
    @year = @date.year
    @month = @date.month
    @first_date = @date
    @last_date = @date.end_of_month
    @attendances = Attendance.includes(:practice => :group_schedule).
        where('practices.year = ? AND practices.week >= ? AND practices.week <= ? AND attendances.status NOT IN (?)',
              @year, @first_date.cweek, @last_date.cweek, Attendance::ABSENT_STATES).
        all.select { |a| (@first_date..@last_date).include? a.date }
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
    year = params[:year]
    week = params[:week]
    gs_id = params[:gs_id]
    if year && week && gs_id
      practice = Practice.where(:group_schedule_id => gs_id,
                                :year => year,
                                :week => week).first_or_create!
    else
      practice = m.groups.where(:name => 'Voksne').first.next_practice
    end
    criteria = {:member_id => m.id, :practice_id => practice.id}
    @attendance = Attendance.includes(:practice).where(criteria).first_or_initialize

    new_status = params[:id]
    if new_status == 'toggle'
      if @attendance.status == Attendance::Status::WILL_ATTEND
        new_status = Attendance::Status::ABSENT
      else
        new_status = Attendance::Status::WILL_ATTEND
      end
    end
    @attendance.status = new_status
    @attendance.save!
    if request.xhr?
      render :partial => 'attendance_delete_link', :locals => {:attendance => @attendance}
    else
      back_or_redirect_to(@attendance)
    end
  end

  def plan
    today = Date.today
    @weeks = [[today.year, today.cweek], [(today + 7).year, (today + 7).cweek]]
    if today.month >= 6 && today.month <= 7
      @weeks += [[(today + 14).year, (today + 14).cweek], [(today + 21).year, (today + 21).cweek]]
    end
    member = current_user.member
    @group_schedules = member.groups.reject(&:school_breaks).map(&:group_schedules).flatten
    @weeks.each do |w|
      @group_schedules.each { |gs| gs.practices.where(:year => today.year, :week => today.cweek).first_or_create! }
      @group_schedules.each { |gs| gs.practices.where(:year => (today + 7).year, :week => (today + 7).cweek).first_or_create! }
    end
    @planned_attendances = Attendance.includes(:practice).
        where('member_id = ? AND (practices.year > ? OR (practices.year = ? AND practices.week >= ?)) AND (practices.year < ? OR (practices.year = ? AND practices.week <= ?))',
              member, today.year, today.year, today.cweek,
              @weeks.last[0], @weeks.last[0], @weeks.last[1]).
        all
    start_date = 6.months.ago.to_date.beginning_of_month
    attendances = Attendance.includes(:practice).
        where('member_id = ? AND attendances.status = ? AND ((practices.year = ? AND practices.week >= ?) OR (practices.year = ?))',
              member, Attendance::Status::ATTENDED, start_date.year, start_date.cweek, today.year).
        all
    @attended_groups = attendances.map { |a| a.group_schedule.group }.uniq.sort_by { |g| -g.from_age }
    per_month = attendances.group_by { |a| d = a.date; [d.year, d.mon] }
    @months = per_month.keys.sort.map do |ym|
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
    @attendance = Attendance.find(params[:id])
    raise 'Wrong user' unless @attendance.member == current_user.member
    @attendance.update_attributes params[:attendance]

    if request.xhr?
      render :text => @attendance.status
    else
      flash[:notice] = "Bekreftet oppmøte #{@attendance.date}:  #{t(:attendances)[@attendance.status.to_sym]}"
      back_or_redirect_to(:action => :plan)
    end
  end

  def form_index
    @groups = Group.active(Date.today).order :from_age
  end

  def form
    if params[:date]
      @date = Date.parse(params[:date])
    end
    @date ||= Date.today

    first_date = Date.new(@date.year, @date.month, 1)
    last_date = Date.new(@date.year, @date.month, -1)

    if params[:group_id]
      if params[:group_id] == 'others'
        @instructors = []
        @members = Member.includes(:attendances => {:group_schedule => :group}).
            where('id NOT in (SELECT DISTINCT member_id FROM groups_members) AND (left_on IS NULL OR left_on > ?)', @date).
            all
        @trials = []
        weekdays = [2, 4]
        @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }
        current_members = []
      else
        @group = Group.includes(:martial_art).find(params[:group_id])
        weekdays = @group.group_schedules.map { |gs| gs.weekday }
        @dates = (first_date..last_date).select { |d| weekdays.include? d.cwday }

        @instructors = Member.active(@date).
            includes({:attendances => {:practice => :group_schedule}, :graduates => [:graduation, :rank]}, :groups).find_all_by_instructor(true).
            select { |m| m.groups.any? { |g| g.martial_art_id == @group.martial_art_id } }
        @instructors.delete_if { |m| m.attendances.select { |a| ((@dates.first - 92.days)..@dates.last).include?(a.date) && a.group_schedule.group_id == @group.id }.empty? }
        @instructors += GroupInstructor.includes(:group_schedule).
            where('member_id NOT IN (?)', @instructors.map(&:id)).
            where(:group_schedules => {:group_id => @group.id}).all.
            select { |gi| @dates.any? { |d| gi.active?(d) } }.map(&:member).uniq

        current_members = @group.members.active(@date).
            includes({:attendances => {:practice => :group_schedule}, :graduates => [:graduation, :rank], :groups => :group_schedules}, :nkf_member)
        attended_members = Member.
            includes(:attendances => {:practice => :group_schedule}, :graduates => [:graduation, :rank]).
            where('members.id NOT IN (?) AND practices.group_schedule_id IN (?) AND (year > ? OR ( year = ? AND week >= ?)) AND (year < ? OR ( year = ? AND week <= ?))',
                  @instructors.map(&:id), @group.group_schedules.map(&:id), first_date.cwyear, first_date.cwyear, first_date.cweek, last_date.cwyear, last_date.cwyear, last_date.cweek).
            all
        @members = current_members + (attended_members - current_members)
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
    @passive_members = @members.select { |m| m.passive?(@date, @group) }
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
