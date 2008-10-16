class AttendancesController < ApplicationController
  before_filter :admin_required

  # GET /attendances
  # GET /attendances.xml
  def index
    @attendances = Attendance.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @attendances }
    end
  end
  
  # GET /attendances/1
  # GET /attendances/1.xml
  def show
    @attendance = Attendance.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @attendance }
    end
  end
  
  # GET /attendances/new
  # GET /attendances/new.xml
  def new
    @attendance = Attendance.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attendance }
    end
  end
  
  # GET /attendances/1/edit
  def edit
    @attendance = Attendance.find(params[:id])
  end
  
  # POST /attendances
  # POST /attendances.xml
  def create
    @attendance = Attendance.new(params[:attendance])
    
    respond_to do |format|
      if @attendance.save
        flash[:notice] = 'Attendance was successfully created.'
        format.html do 
          if (request.xhr?)
            render :text => 'V'
          else
            redirect_to(@attendance) 
          end
          format.xml  { render :xml => @attendance, :status => :created, :location => @attendance }
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attendance.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /attendances/1
  # PUT /attendances/1.xml
  def update
    @attendance = Attendance.find(params[:id])
    
    respond_to do |format|
      if @attendance.update_attributes(params[:attendance])
        flash[:notice] = 'Attendance was successfully updated.'
        format.html { redirect_to(@attendance) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attendance.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /attendances/1
  # DELETE /attendances/1.xml
  def destroy
    @attendance = Attendance.find(params[:id])
    @attendance.destroy
    
    respond_to do |format|
      format.html do 
        if (request.xhr?)
          render :text => ''
        else
          redirect_to(attendances_url) 
        end
      end
      format.xml  { head :ok }
    end
  end
end
