# encoding: UTF-8
class AttendancesController < ApplicationController
  before_filter :admin_required

  caches_page :history_graph
  cache_sweeper :attendance_image_sweeper, :only => [:create, :update, :destroy]
  cache_sweeper :grade_history_image_sweeper, :only => [:create, :update, :destroy]

  def index
    @attendances = Attendance.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @attendances }
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
      format.xml  { render :xml => @attendance }
    end
  end
  
  def new
    @attendance ||= Attendance.new params[:attendance]
    group_id = params[:group]
    @members = Member.order(:first_name, :last_name).all
    @group_schedules = GroupSchedule.where(group_id ? {:group_id => group_id} : {}).all
    
    respond_to do |format|
      format.html { render :action => 'new' }
      format.xml  { render :xml => @attendance }
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
            redirect_to(@attendance) 
          end
          format.xml  { render :xml => @attendance, :status => :created, :location => @attendance }
        end
      else
        format.html { new }
        format.xml  { render :xml => @attendance.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @attendance = Attendance.find(params[:id])
    
    respond_to do |format|
      if @attendance.update_attributes(params[:attendance])
        flash[:notice] = 'Attendance was successfully updated.'
        format.html { redirect_to(@attendance) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @attendance.errors, :status => :unprocessable_entity }
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
      format.xml  { head :ok }
    end
  end
  
  def history_graph
    if params[:id] && params[:id].to_i <= 1280
      g = AttendanceHistoryGraph.new.history_graph params[:id].to_i
    else
      g = AttendanceHistoryGraph.new.history_graph
    end
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => 'RJJK_Oppmøtehistorikk.png')
  end
  
end
