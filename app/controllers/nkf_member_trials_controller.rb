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

  def create
    @nkf_member_trial = NkfMemberTrial.new(params[:nkf_member_trial])

    if @nkf_member_trial.save
      flash[:notice] = 'NkfMemberTrial was successfully created.'
      redirect_to(@nkf_member_trial)
    else
      render action: 'new'
    end
  end
end
