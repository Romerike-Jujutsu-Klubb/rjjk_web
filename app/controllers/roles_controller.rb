# frozen_string_literal: true

class RolesController < ApplicationController
  before_action :admin_required

  def index
    @roles = Role.order('years_on_the_board DESC NULLS LAST, position NULLS LAST, name').to_a

    respond_to do |format|
      format.html
      format.json { render json: @roles }
    end
  end

  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @role }
    end
  end

  def new
    @role = Role.new

    respond_to do |format|
      format.html
      format.json { render json: @role }
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        format.html { redirect_to roles_path, notice: 'Job position was successfully created.' }
        format.json { render json: @role, status: :created, location: @role }
      else
        format.html { render action: 'new' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @role.update(params[:role])
        format.html { redirect_to @role, notice: 'Job position was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def move_up
    role = Role.find(params[:id])
    if role.in_list?
      role.move_higher
    else
      role.insert_at(1)
      role.move_to_bottom
    end
    redirect_back fallback_location: roles_path
  end

  def move_down
    role = Role.find(params[:id])
    if role.in_list?
      role.move_lower
    else
      role.insert_at(1)
      role.move_to_bottom
    end
    redirect_back fallback_location: roles_path
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to roles_url }
      format.json { head :no_content }
    end
  end
end
