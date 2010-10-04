class NkfMemberTrialsController < ApplicationController
  # GET /nkf_member_trials
  # GET /nkf_member_trials.xml
  def index
    @nkf_member_trials = NkfMemberTrial.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nkf_member_trials }
    end
  end

  # GET /nkf_member_trials/1
  # GET /nkf_member_trials/1.xml
  def show
    @nkf_member_trial = NkfMemberTrial.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nkf_member_trial }
    end
  end

  # GET /nkf_member_trials/new
  # GET /nkf_member_trials/new.xml
  def new
    @nkf_member_trial = NkfMemberTrial.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nkf_member_trial }
    end
  end

  # GET /nkf_member_trials/1/edit
  def edit
    @nkf_member_trial = NkfMemberTrial.find(params[:id])
  end

  # POST /nkf_member_trials
  # POST /nkf_member_trials.xml
  def create
    @nkf_member_trial = NkfMemberTrial.new(params[:nkf_member_trial])

    respond_to do |format|
      if @nkf_member_trial.save
        flash[:notice] = 'NkfMemberTrial was successfully created.'
        format.html { redirect_to(@nkf_member_trial) }
        format.xml  { render :xml => @nkf_member_trial, :status => :created, :location => @nkf_member_trial }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nkf_member_trial.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nkf_member_trials/1
  # PUT /nkf_member_trials/1.xml
  def update
    @nkf_member_trial = NkfMemberTrial.find(params[:id])

    respond_to do |format|
      if @nkf_member_trial.update_attributes(params[:nkf_member_trial])
        flash[:notice] = 'NkfMemberTrial was successfully updated.'
        format.html { redirect_to(@nkf_member_trial) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nkf_member_trial.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /nkf_member_trials/1
  # DELETE /nkf_member_trials/1.xml
  def destroy
    @nkf_member_trial = NkfMemberTrial.find(params[:id])
    @nkf_member_trial.destroy

    respond_to do |format|
      format.html { redirect_to(nkf_member_trials_url) }
      format.xml  { head :ok }
    end
  end
end
