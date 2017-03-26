# frozen_string_literal: true
class NkfMemberTrialsController < ApplicationController
  before_action :admin_required

  def index
    @nkf_member_trials = NkfMemberTrial.order(:fornavn, :etternavn).to_a

    respond_to do |format|
      format.html
      format.xml { render xml: @nkf_member_trials }
    end
  end

  def show
    @nkf_member_trial = NkfMemberTrial.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render xml: @nkf_member_trial }
    end
  end

  def new
    @nkf_member_trial = NkfMemberTrial.new

    respond_to do |format|
      format.html
      format.xml { render xml: @nkf_member_trial }
    end
  end

  def edit
    @nkf_member_trial = NkfMemberTrial.find(params[:id])
  end

  def create
    @nkf_member_trial = NkfMemberTrial.new(params[:nkf_member_trial])

    if @nkf_member_trial.save
      flash[:notice] = 'NkfMemberTrial was successfully created.'
      redirect_to(@nkf_member_trial)
    else
      render action: 'new'
    end
  end

  def update
    @nkf_member_trial = NkfMemberTrial.find(params[:id])

    respond_to do |format|
      if @nkf_member_trial.update_attributes(params[:nkf_member_trial])
        flash[:notice] = 'NkfMemberTrial was successfully updated.'
        format.html { redirect_to(@nkf_member_trial) }
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  { render xml: @nkf_member_trial.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @nkf_member_trial = NkfMemberTrial.find(params[:id])
    @nkf_member_trial.destroy

    respond_to do |format|
      format.html { redirect_to(nkf_member_trials_url) }
      format.xml  { head :ok }
    end
  end
end
