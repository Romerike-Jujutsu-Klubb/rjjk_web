class GroupSchedulesController < ApplicationController
  before_filter :admin_required
  # GET /group_schedules
  # GET /group_schedules.xml
  def index
    @group_schedules = GroupSchedule.find(:all).sort_by{|gs| [gs.weekday == 0 ? 7 : gs.weekday, gs.start_at, gs.end_at]}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @group_schedules }
    end
  end

  # GET /group_schedules/yaml
  def yaml
    @group_schedules = GroupSchedule.all
    render :text => @group_schedules.map{|gs| gs.attributes}.to_yaml, :content_type => 'text/yaml', :layout => false
  end

  # GET /group_schedules/1
  # GET /group_schedules/1.xml
  def show
    @group_schedule = GroupSchedule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group_schedule }
    end
  end

  # GET /group_schedules/new
  # GET /group_schedules/new.xml
  def new
    @group_schedule = GroupSchedule.new
    @groups = Group.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group_schedule }
    end
  end

  # GET /group_schedules/1/edit
  def edit
    @group_schedule = GroupSchedule.find(params[:id])
    @groups = Group.find(:all)
  end

  # POST /group_schedules
  # POST /group_schedules.xml
  def create
    @group_schedule = GroupSchedule.new(params[:group_schedule])

    respond_to do |format|
      if @group_schedule.save
        flash[:notice] = 'GroupSchedule was successfully created.'
        format.html { redirect_to(@group_schedule) }
        format.xml  { render :xml => @group_schedule, :status => :created, :location => @group_schedule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group_schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /group_schedules/1
  # PUT /group_schedules/1.xml
  def update
    @group_schedule = GroupSchedule.find(params[:id])

    respond_to do |format|
      if @group_schedule.update_attributes(params[:group_schedule])
        flash[:notice] = 'GroupSchedule was successfully updated.'
        format.html { redirect_to(@group_schedule) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group_schedule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /group_schedules/1
  # DELETE /group_schedules/1.xml
  def destroy
    @group_schedule = GroupSchedule.find(params[:id])
    @group_schedule.destroy

    respond_to do |format|
      format.html { redirect_to(group_schedules_url) }
      format.xml  { head :ok }
    end
  end
end
