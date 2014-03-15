class ApplicationStepsController < ApplicationController
  # GET /application_steps
  # GET /application_steps.json
  def index
    @application_steps = ApplicationStep.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @application_steps }
    end
  end

  # GET /application_steps/1
  # GET /application_steps/1.json
  def show
    @application_step = ApplicationStep.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @application_step }
    end
  end

  # GET /application_steps/new
  # GET /application_steps/new.json
  def new
    @application_step = ApplicationStep.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @application_step }
    end
  end

  # GET /application_steps/1/edit
  def edit
    @application_step = ApplicationStep.find(params[:id])
  end

  # POST /application_steps
  # POST /application_steps.json
  def create
    @application_step = ApplicationStep.new(params[:application_step])

    respond_to do |format|
      if @application_step.save
        format.html { redirect_to @application_step, notice: 'Application step was successfully created.' }
        format.json { render json: @application_step, status: :created, location: @application_step }
      else
        format.html { render action: "new" }
        format.json { render json: @application_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /application_steps/1
  # PUT /application_steps/1.json
  def update
    @application_step = ApplicationStep.find(params[:id])

    respond_to do |format|
      if @application_step.update_attributes(params[:application_step])
        format.html { redirect_to @application_step, notice: 'Application step was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @application_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /application_steps/1
  # DELETE /application_steps/1.json
  def destroy
    @application_step = ApplicationStep.find(params[:id])
    @application_step.destroy

    respond_to do |format|
      format.html { redirect_to application_steps_url }
      format.json { head :no_content }
    end
  end
end
