class TrialAttendancesController < ApplicationController
  before_filter :admin_required

  # GET /trial_attendances
  # GET /trial_attendances.xml
  def index
    @trial_attendances = TrialAttendance.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trial_attendances }
    end
  end

  # GET /trial_attendances/1
  # GET /trial_attendances/1.xml
  def show
    @trial_attendance = TrialAttendance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trial_attendance }
    end
  end

  # GET /trial_attendances/new
  # GET /trial_attendances/new.xml
  def new
    @trial_attendance = TrialAttendance.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trial_attendance }
    end
  end

  # GET /trial_attendances/1/edit
  def edit
    @trial_attendance = TrialAttendance.find(params[:id])
  end

  # POST /trial_attendances
  # POST /trial_attendances.xml
  def create
    @trial_attendance = TrialAttendance.new(params[:trial_attendance])

    respond_to do |format|
      if @trial_attendance.save
        format.html {
          if (request.xhr?)
            render :text => '<img src="/assets/accept.png"/>'
          else
            redirect_to(@trial_attendance, :notice => 'TrialAttendance was successfully created.')
          end
        }
        format.xml  { render :xml => @trial_attendance, :status => :created, :location => @trial_attendance }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trial_attendance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trial_attendances/1
  # PUT /trial_attendances/1.xml
  def update
    @trial_attendance = TrialAttendance.find(params[:id])

    respond_to do |format|
      if @trial_attendance.update_attributes(params[:trial_attendance])
        format.html { redirect_to(@trial_attendance, :notice => 'TrialAttendance was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trial_attendance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trial_attendances/1
  # DELETE /trial_attendances/1.xml
  def destroy
    @trial_attendance = TrialAttendance.find(params[:id])
    @trial_attendance.destroy

    respond_to do |format|
      format.html do
        if (request.xhr?)
          render :text => ''
        else
          redirect_to(trial_attendances_url)
        end
      end
      format.xml  { head :ok }
    end
  end
end
