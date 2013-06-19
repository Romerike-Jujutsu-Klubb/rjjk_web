class GroupsController < ApplicationController
  before_filter :admin_required, :except => :show

  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
      format.yaml  { render :text => @groups.to_yaml, :content_type => 'text/yaml' }
    end
  end

  # GET /groups/yaml
  def yaml
    @groups = Group.all
    @groups.each{|g| g['members'] = g.members.map{|m| m.id}}
    render :text => @groups.map{|g| g.attributes}.to_yaml, :content_type => 'text/yaml', :layout => false
  end
  
  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  def new
    @group ||= Group.new
    @martial_arts ||= MartialArt.all
  end

  def edit
    @group = Group.find(params[:id])
    @martial_arts = MartialArt.all
  end

  def create
    @group = Group.new(params[:group])

      if @group.save
        flash[:notice] = 'Group was successfully created.'
        redirect_to(@group)
      else
        new
        render :action => "new"
      end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
