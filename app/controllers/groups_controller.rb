# frozen_string_literal: true

class GroupsController < ApplicationController
  before_action :admin_required, except: :show

  def index
    @groups = Group.active(Date.current).order('to_age, from_age DESC').to_a
    @closed_groups = Group.inactive(Date.current).to_a
    respond_to do |format|
      format.html
      format.xml { render xml: @groups }
      format.yaml { render text: @groups.to_yaml, content_type: 'text/yaml' }
    end
  end

  def show
    @group = Group.includes(users: [:recent_attendances, { member: :nkf_member }]).find(params[:id])
    chief_instructor = @group.current_semester&.chief_instructor
    @instructors = ([chief_instructor] + @group.instructors).compact.uniq

    respond_to do |format|
      format.html
      format.xml { render xml: @group }
    end
  end

  def new
    @group ||= Group.new
    load_form_data
  end

  def edit
    @group ||= Group.find(params[:id])
    load_form_data
  end

  def create
    @group = Group.new(params[:group])
    @group.update_prices
    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to(@group)
    else
      new
      render action: :new
    end
  end

  def update
    @group = Group.find(params[:id])
    @group.attributes = params[:group]
    @group.update_prices
    if @group.save
      flash[:notice] = 'Group was successfully updated.'

      if @group.school_breaks
        if (current_semester = Semester.current) && !@group.current_semester
          @group.create_current_semester(semester_id: current_semester.id)
        end

        if (next_semester = Semester.next) && !@group.next_semester
          @group.create_next_semester(semester_id: next_semester.id)
        end
      end
      back_or_redirect_to(@group)
    else
      flash.alert = "Kunne ikke lagre gruppen: #{@group.errors.full_messages.join(', ')}"
      edit
      render action: :edit
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

  private

  def load_form_data
    @curriculum_groups = CurriculumGroup.includes(:martial_art).references(:martial_arts)
        .merge(MartialArt.originals).order(:martial_art_id, :position).to_a
    @contracts = NkfMember.distinct.pluck(:kontraktstype).compact.sort
  end
end
