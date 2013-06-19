class GroupsController < ApplicationController
  before_filter :admin_required, :except => :show

  def index
    @groups = Group.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @groups }
      format.yaml { render :text => @groups.to_yaml, :content_type => 'text/yaml' }
    end
  end

  def yaml
    @groups = Group.all
    @groups.each { |g| g['members'] = g.members.map { |m| m.id } }
    render :text => @groups.map { |g| g.attributes }.to_yaml, :content_type => 'text/yaml', :layout => false
  end

  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @group }
    end
  end

  def new
    @group ||= Group.new
    @martial_arts ||= MartialArt.all
    @contracts = NkfMember.all.group_by(&:kontraktstype).keys.sort
  end

  def edit
    @group = Group.find(params[:id])
    @martial_arts = MartialArt.all
    @contracts = NkfMember.all.group_by(&:kontraktstype).keys.sort
  end

  def create
    @group = Group.new(params[:group])
    @group.update_prices
    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to(@group)
    else
      new
      render :action => "new"
    end
  end

  def update
    @group = Group.find(params[:id])
    @group.attributes = params[:group]
    @group.update_prices

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml { head :ok }
    end
  end
end
