# frozen_string_literal: true

class GraduatesController < ApplicationController
  include GraduationAccess

  before_action :admin_required, except: %i[confirm create decline destroy show update]

  cache_sweeper :grade_history_image_sweeper, only: %i[create update destroy]

  def index
    @graduates =
        if params[:id]
          Graduate.where("member_id = #{params[:id]}").order(:rank_id).to_a
        else
          Graduate.where('member_id > 0').order('member_id, rank_id DESC').to_a
        end
  end

  def show
    @graduate = Graduate.find(params[:id])
    return unless admin_or_graduate_required(@graduate)
  end

  def new
    @graduate ||= Graduate.new
    load_form_data
  end

  def create
    @graduate = Graduate.new(params[:graduate])
    if @graduate.member_id.blank?
      flash.notice = 'Velg en deltaker'
      back_or_redirect_to @graduate.graduation
      return
    end
    @graduate.populate_defaults!
    return unless admin_or_censor_required(@graduate.graduation)

    if @graduate.save
      flash[:notice] = 'Graduate was successfully created.'
      back_or_redirect_to action: :index
    else
      new
      render action: :new, layout: !request.xhr?
    end
  end

  def edit
    @graduate ||= Graduate.find(params[:id])
    load_form_data
  end

  def update
    @graduate = Graduate.includes(:graduation, :member, :rank).find(params[:id])
    return unless admin_or_censor_required(@graduate.graduation)

    respond_to do |format|
      if @graduate.update(params[:graduate])
        format.html do
          flash[:notice] = 'Graduate was successfully updated.'
          redirect_to action: :show, id: @graduate
        end
        format.json { head :no_content }
      else
        format.html do
          edit
          render action: :edit, layout: !request.xhr?
        end
        format.json { render json: @graduate.errors, status: :unprocessable_entity }
      end
      format.js { edit }
    end
  end

  # From email link
  def confirm
    @graduate = Graduate.find(params[:id])
    return unless admin_or_graduate_required(@graduate)

    if @graduate.update(confirmed_at: Time.zone.now, declined: false)
      flash[:notice] = 'Din deltakelse på gradering er bekreftet.'
    else
      flash[:error] = 'Beklager, men noe gikk galt under registreringen av din bekreftelse.'
    end
    redirect_to @graduate
  end

  # From email link
  def decline
    @graduate = Graduate.find(params[:id])
    return unless admin_or_graduate_required(@graduate)

    if @graduate.update(confirmed_at: Time.zone.now, declined: true)
      flash[:notice] = 'Ditt avslag på gradering er bekreftet.'
    else
      flash[:error] = 'Beklager, men noe gikk galt under registreringen av ditt avslag.'
    end
    redirect_to @graduate
  end

  def destroy
    @graduate = Graduate.find(params[:id])
    return unless admin_or_censor_required(@graduate.graduation)

    @graduate.destroy
    respond_to do |format|
      format.html { back_or_redirect_to edit_graduation_path(@graduate.graduation) }
      format.js
    end
  end

  private

  def load_form_data
    query = Rank.order(:position)
    query = query.where(martial_art_id: @graduate.graduation.group.martial_art_id) if @graduate.graduation
    @ranks = query.to_a
  end
end
