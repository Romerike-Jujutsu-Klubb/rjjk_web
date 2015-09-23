class GroupsController < ApplicationController
  before_filter :admin_required, :except => :show

  def index
    @groups = Group.active(Date.today).order('to_age, from_age DESC').to_a
    @closed_groups = Group.inactive(Date.today).to_a
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @groups }
      format.yaml { render text: @groups.to_yaml, content_type: 'text/yaml' }
    end
  end

  def yaml
    @groups = Group.active.to_a
    attrs = @groups.map { |g| g.attributes }
    @groups.each { |g| attrs.find { |g2| g2['id'] == g.id }['members'] = g.members.map { |m| m.id } }
    render text: attrs.to_yaml, content_type: 'text/yaml', layout: false
  end

  def show
    @group = Group.includes(members: [:recent_attendances, :nkf_member]).find(params[:id])
    @instructors = @group.instructors

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
    @group ||= Group.find(params[:id])
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
      render :action => :new
    end
  end

  def update
    @group = Group.find(params[:id])
    @group.attributes = params[:group]
    @group.update_prices

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully updated.'

        if @group.school_breaks
          if (current_semester = Semester.current) && !@group.current_semester
            @group.create_current_semester(:semester_id => current_semester.id)
          end

          if (next_semester = Semester.next) && !@group.next_semester
            @group.create_next_semester(:semester_id => next_semester.id)
          end
        end

        format.html { back_or_redirect_to(@group) }
        format.xml { head :ok }
      else
        format.html { edit; render :action => :edit }
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
