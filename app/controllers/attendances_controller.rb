# encoding: UTF-8
class AttendancesController < ApplicationController
  user_actions = [:announce, :plan]
  before_filter :admin_required, :except => user_actions
  before_filter :authenticate_user, :only => user_actions

  caches_page :history_graph, :month_chart
  cache_sweeper :attendance_image_sweeper, :only => [:create, :update, :destroy]
  cache_sweeper :grade_history_image_sweeper, :only => [:create, :update, :destroy]

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
            render :partial => '/members/attendance_delete_link', :locals => {:attendance => @attendance}
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
          render :partial => '/members/attendance_create_link', :locals => {:member_id => @attendance.member_id, :group_schedule_id => @attendance.group_schedule_id, :date => @attendance.date}
        else
          redirect_to(attendances_url)
        end
      end
      format.xml { head :ok }
    end
  end

  def report
    @date = (params[:id] && Date.parse(params[:id])) || Date.today
    @year = @date.year
    @month = @date.month
    first_date = @date.beginning_of_month
    last_date = @date.end_of_month
    @attendances = Attendance.includes(:group_schedule).
        where('year = ? AND week >= ? AND week <= ? AND status NOT IN (?)', @year, first_date.cweek, last_date.cweek, Attendance::ABSENT_STATES).
        all.select { |a| (first_date..last_date).include? a.date }
    monthly_per_group = @attendances.group_by { |a| a.group_schedule.group }.sort_by { |g, ats| g.from_age }
    @monthly_summary_per_group = {}
    monthly_per_group.each do |g, attendances|
      @monthly_summary_per_group[g] = {}
      @monthly_summary_per_group[g][:attendances] = attendances
      @monthly_summary_per_group[g][:present] = attendances.select { |a| !Attendance::ABSENT_STATES.include? a.status }
      @monthly_summary_per_group[g][:absent] = attendances.select { |a| Attendance::ABSENT_STATES.include? a.status }
      @monthly_summary_per_group[g][:practices] = attendances.map { |a| [a.year, a.week, a.group_schedule_id] }.uniq.size
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
    m = current_user.member
    year = (params[:year] || Date.today.cwyear).to_i
    week = (params[:week] || Date.today.cweek).to_i
    gs_id = params[:gs_id] || m.groups[0].next_schedule.id
    criteria = {:member_id => m.id,
                :group_schedule_id => gs_id,
                :year => year,
                :week => week}
    @attendance = Attendance.where(criteria).first || Attendance.new(criteria)

    new_status = params[:id]
    if new_status == 'toggle'
      if @attendance.status == Attendance::Status::WILL_ATTEND
        new_status = 'NONE'
        @attendance.destroy
      else
        new_status = Attendance::Status::WILL_ATTEND
        @attendance.status = Attendance::Status::WILL_ATTEND
        @attendance.save!
      end
    else
      @attendance.status = new_status
      @attendance.save!
    end
    if (request.xhr?)
      render :text => "Stored: #{new_status}"
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
    @group_schedules = member.groups.map(&:group_schedules).flatten
    @planned_attendances = Attendance.where('member_id = ? AND (year > ? OR (year = ? AND week >= ?)) AND (year < ? OR (year = ? AND week <= ?))',
                                            member, today.year, today.year, today.cweek,
                                            @weeks.last[0], @weeks.last[0], @weeks.last[1]).
        all
    start_date = 6.months.ago.to_date.beginning_of_month
    attendances = Attendance.where('member_id = ? AND status = ? AND ((year = ? AND week >= ?) OR (year = ?))',
                                   member, Attendance::Status::ATTENDED, start_date.year, start_date.cweek, today.year).
        all
    @attended_groups = attendances.map { |a| a.group_schedule.group }.uniq.sort_by { |g| -g.from_age }
    per_month = attendances.group_by { |a| d = Date.commercial(a.year, a.week, a.group_schedule.weekday); [d.year, d.mon] }
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
    raise "Wrong user" unless @attendance.member == current_user.member
    @attendance.update_attributes params[:attendance]

    if (request.xhr?)
      render :text => "Stored: #{@attendance.status}"
    else
      flash[:notice] = "Bekreftet oppmøte #{@attendance.date}:  #{t(:attendances)[@attendance.status.to_sym]}"
      back_or_redirect_to(:action => :plan)
    end
  end

end
