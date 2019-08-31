# frozen_string_literal: true

class AttendancesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :announce

  USER_ACTIONS = %i[announce plan practice_details review].freeze
  before_action :authenticate_user, only: USER_ACTIONS
  before_action :instructor_required, except: USER_ACTIONS

  def index
    @attendances = Attendance.includes(:practice)
        .order('practices.year DESC, practices.week DESC, attendances.created_at DESC').limit(100).to_a
  end

  def since_graduation
    @member = Member.find(params[:id])
    @date = params[:date].try(:to_date) || Date.current
    @graduate = @member.current_graduate(nil, @date)
    @attendances = @member.attendances_since_graduation(@date, include_absences: true).sort_by(&:date)
        .reverse
  end

  def show
    @attendance = Attendance.find(params[:id])
  end

  def new
    @attendance ||= Attendance.new params[:attendance]
    if @attendance.practice.nil?
      @attendance.practice = Practice.new
    elsif @attendance.practice&.new_record?
      practice = Practice
          .where(group_schedule_id: @attendance.practice.group_schedule_id,
                 year: @attendance.practice.year, week: @attendance.practice.week)
          .first
      @attendance.practice = practice if practice
    end
    @attendance.status ||= Attendance::Status::ATTENDED
    group_id = params[:group]
    @members = Member.all.sort_by(&:name)
    @group_schedules = GroupSchedule.where(group_id ? { group_id: group_id } : {}).to_a
    render action: 'new'
  end

  def edit
    @attendance = Attendance.find(params[:id])
  end

  def create
    if params[:attendance][:group_schedule_id]
      params[:attendance][:practice_id] = Practice.find_by(
          group_schedule_id: params[:attendance].delete(:group_schedule_id),
          year: params[:attendance].delete(:year), week: params[:attendance].delete(:week)
        ).id
    end
    @attendance = Attendance.new(params[:attendance])
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
    if @attendance.update(params[:attendance])
      flash[:notice] = 'Attendance was successfully updated.'
      redirect_to(@attendance)
    else
      render action: 'edit'
    end
  end

  def destroy
    @attendance = Attendance.find(params[:id])
    @attendance.destroy
    AttendanceNotificationJob.perform_later(@attendance.practice, @attendance.member, nil)
    if request.xhr?
      flash.clear
      render partial: 'attendance_form/attendance_create_link', locals: {
        member_id: @attendance.member_id,
        group_schedule: @attendance.practice.group_schedule,
        date: @attendance.date,
      }
    else
      redirect_to(attendances_url)
    end
  end

  def report
    @date = if params[:year] && params[:month]
              Date.new(params[:year].to_i, params[:month].to_i, 1)
            else
              Date.current.beginning_of_month
            end
    @year = @date.cwyear
    @month = @date.month
    @first_date = @date
    @last_date = @date.end_of_month
    @attendances = Attendance.includes(practice: :group_schedule).references(:practices)
        .from_date(@first_date).to_date(@last_date)
        .where('attendances.status NOT IN (?)', Attendance::ABSENT_STATES)
        .to_a
    monthly_per_group = @attendances.group_by { |a| a.group_schedule.group }
        .sort_by { |g, _ats| g.from_age }
    @monthly_summary_per_group = {}
    monthly_per_group.each do |g, attendances|
      @monthly_summary_per_group[g] = {}
      @monthly_summary_per_group[g][:attendances] = attendances
      @monthly_summary_per_group[g][:present] = attendances.select do |a|
        !Attendance::ABSENT_STATES.include?(a.status) && a.date <= Date.current
      end
      @monthly_summary_per_group[g][:absent] = attendances
          .select { |a| Attendance::ABSENT_STATES.include? a.status }
      @monthly_summary_per_group[g][:practices] =
          @monthly_summary_per_group[g][:present].map(&:practice_id).uniq.size
    end
    @by_group_and_member = Hash[monthly_per_group
        .map { |g, ats| [g, ats.group_by(&:member)] }]
  end

  def history_graph; end

  def history_graph_data
    timestamp = Attendance.maximum(:updated_at).strftime('%F_%T.%N')
    json_data = Rails.cache.fetch("attendances/history/#{timestamp}") do
      group_data, weeks, _labels = AttendanceHistoryGraph.history_graph_data
      expanded_data = group_data.map do |label, values, color|
        next unless values

        exp = weeks.zip(values).map { |(year, week), value| [Date.commercial(year, week, 1), value] }
        { name: label, data: exp, color: color }
      end
      expanded_data.compact.to_json
    end

    render json: json_data
  end

  def month_chart; end

  def month_chart_data
    year = params[:year].to_i
    month = params[:month].to_i
    timestamp = Attendance.maximum(:updated_at).strftime('%F_%T.%N')
    json_data = Rails.cache.fetch("attendances/month_chart_data/#{year}/#{month}/#{timestamp}") do
      data, _dates = AttendanceHistoryGraph.month_chart_data(year, month)
      expanded_data = data.map { |name, values, color| { name: name, data: values.sort, color: color } }
      expanded_data.to_json
    end
    render json: json_data
  end

  def announce
    m = (params[:member_id] && Member.find(params[:member_id])) || current_user.member
    year = params[:year].to_i
    week = params[:week].to_i
    gs_id = params[:group_schedule_id]
    practice = if year.positive? && week.positive? && gs_id
                 Practice.where(group_schedule_id: gs_id, year: year, week: week).first_or_create!
               else
                 m.groups.find_by(planning: true).next_practice
               end
    @attendance = Attendance.includes(:practice).where(member_id: m.id, practice_id: practice.id)
        .first_or_initialize

    new_status = params[:status]
    if new_status == 'toggle'
      if !@attendance.practice.passed? && @attendance.status == Attendance::Status::WILL_ATTEND
        new_status = nil
        @attendance.destroy
        @attendance = nil
      elsif @attendance.status == Attendance::Status::ATTENDED
        new_status = Attendance::Status::ABSENT
      else
        new_status =
            if @attendance.practice.passed?
              Attendance::Status::ATTENDED
            else
              Attendance::Status::WILL_ATTEND
            end
      end
    elsif new_status == Attendance::Status::WILL_ATTEND && practice.imminent?
      new_status = Attendance::Status::ATTENDED
    end

    @attendance.update!(status: new_status) if new_status

    AttendanceNotificationJob.perform_later(practice, m, new_status)

    if request.xhr?
      if params[:status] == 'toggle'
        if params[:member_id]
          render partial: 'button', locals: {
            gs: practice.group_schedule, year: year, week: week, attendance: @attendance, member_id: m.id
          }
        else
          render partial: 'plan_practice', locals: {
            gs: practice.group_schedule, year: year, week: week, attendance: @attendance
          }
        end
      else
        render partial: 'attendance_form/attendance_delete_link', locals: { attendance: @attendance }
      end
    else
      back_or_redirect_to(@attendance)
    end
  end

  def plan
    today = Date.current

    @weeks = [[today.cwyear, today.cweek], [(today + 7).cwyear, (today + 7).cweek]]
    if today.month >= 6 && today.month <= 7
      @weeks += [[(today + 14).cwyear, (today + 14).cweek],
                 [(today + 21).cwyear, (today + 21).cweek]]
    end

    @member = current_user.member
    @group_schedules = @member.groups.select(&:planning).map(&:group_schedules).flatten
    last_unconfirmed = @member.attendances.includes(practice: :group_schedule)
        .where("attendances.status = 'P'")
        .where('practices.year < ? OR (practices.year = ? AND practices.week < ?)',
            today.cwyear, today.cwyear, today.cweek)
        .order('practices.year, practices.week').last
    if last_unconfirmed
      @weeks.unshift [last_unconfirmed.date.cwyear, last_unconfirmed.date.cweek]
      unless @group_schedules.include?(last_unconfirmed.group_schedule)
        @group_schedules << last_unconfirmed.group_schedule
      end
    end
    @group_schedules = @group_schedules.sort_by(&:weekday)
    if (reviewed_attendance_id = params[:reviewed_attendance_id])
      @reviewed_attendance = Attendance.find(reviewed_attendance_id)
      @weeks.unshift [@reviewed_attendance.date.cwyear, @reviewed_attendance.date.cweek]
      @weeks.sort!.uniq!
    end
    @weeks.each do |year, week|
      @group_schedules.each { |gs| gs.practices.where(year: year, week: week).first_or_create! }
    end
    year_weeks = @weeks.map { |y, w| "(#{y}, #{w})" }.join(', ')
    @planned_attendances = Attendance.includes(:practice).references(:practices)
        .where("member_id = ? AND (practices.year, practices.week) IN (#{year_weeks})",
            @member.id)
        .to_a
    start_date = 6.months.ago.to_date.beginning_of_month
    attendances = Attendance.includes(practice: { group_schedule: :group }).references(:practices)
        .where('member_id = ? AND attendances.status IN (?)',
            @member, Attendance::PRESENT_STATES)
        .where('(practices.year = ? AND practices.week >= ?) OR (practices.year = ?)',
            start_date.cwyear, start_date.cweek, today.cwyear)
        .to_a
    @attended_groups = attendances.map { |a| a.practice.group_schedule.group }
        .uniq.sort_by { |g| -g.from_age }
    per_month = attendances.group_by do |a|
      d = a.date
      [d.cwyear, d.mon]
    end
    @months = per_month.keys.sort.reverse.map do |ym|
      per_group = per_month[ym].group_by { |a| a.group_schedule.group }
      [helpers.month_name(ym[1]).capitalize, *@attended_groups.map { |g| (per_group[g] || []).size }]
    end
    return unless @member.current_rank

    attendances_since_graduation = @member
        .attendances_since_graduation(includes: { group_schedule: :group })
        .to_a
    return if attendances_since_graduation.empty?

    by_group = attendances_since_graduation.group_by { |a| a.group_schedule.group }
    @months << ['Siden gradering', *@attended_groups.map { |g| (by_group[g] || []).size }]
  end

  def practice_details
    practice = Practice
        .includes(attendances: { member: [{ graduates: %i[graduation rank] }, :user] })
        .find(params[:id])
    attendances = practice.attendances.to_a
    other_attendees = attendances.select { |a| Attendance::PRESENCE_STATES.include? a.status }
    other_absentees = attendances.select { |a| Attendance::ABSENT_STATES.include? a.status }
    render partial: 'practice_details', layout: false, locals: {
      practice: practice, your_attendance: nil, other_attendees: other_attendees,
      other_absentees: other_absentees
    }
  end

  def review
    member_id = params[:member_id] || current_user.member.id
    group_schedule_id = params[:group_schedule_id]
    year = params[:year].to_i
    week = params[:week].to_i
    unless year.positive? && week.positive? && group_schedule_id
      redirect_to({ action: :plan }, notice: 'Year and week is required')
      return
    end
    practice = Practice.where(group_schedule_id: group_schedule_id,
                              year: year, week: week).first_or_create!
    @attendance = Attendance.where(member_id: member_id, practice_id: practice.id).first_or_create
    new_status = params[:status]
    if new_status == 'toggle'
      new_status =
          case @attendance.status
          when Attendance::Status::WILL_ATTEND, Attendance::Status::ABSENT,
              Attendance::Status::HOLIDAY
            Attendance::Status::ATTENDED
          when Attendance::Status::ATTENDED, Attendance::Status::INSTRUCTOR,
              Attendance::Status::ASSISTANT
            Attendance::Status::ABSENT
          when nil
            Attendance::Status::ATTENDED
          end
    end
    @attendance.update! status: new_status

    if request.xhr?
      if params[:member_id]
        render partial: 'button', locals: { gs: practice.group_schedule, year: year, week: week,
                                            attendance: @attendance, member_id: member_id }
      else
        render partial: 'plan_practice', locals: {
          gs: practice.group_schedule, year: year, week: week, attendance: @attendance
        }
      end
    else
      flash[:notice] = "Bekreftet oppmøte #{@attendance.date}:  " \
          "#{t(:attendances)[@attendance.status.to_sym]}"
      redirect_to attendance_plan_path(reviewed_attendance_id: @attendance.id)
    end
  end

  def month_per_year_chart; end

  def month_per_year_chart_data
    month = params[:month].to_i
    timestamp = Attendance.maximum(:updated_at).strftime('%F_%T.%N')
    json_data = Rails.cache.fetch("attendances/month_per_year_chart_data/#{month}/#{timestamp}") do
      data, _years = AttendanceHistoryGraph.month_per_year_chart_data(month)
      expanded_data = data.map do |name, values, color|
        { name: name, data: values, color: color }
      end
      expanded_data.to_json
    end
    render json: json_data
  end
end
