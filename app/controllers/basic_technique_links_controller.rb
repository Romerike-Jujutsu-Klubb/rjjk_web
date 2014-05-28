class BasicTechniqueLinksController < ApplicationController
  before_filter :admin_required

  def index
    @basic_technique_links = BasicTechniqueLink.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @basic_technique_links }
    end
  end

  def show
    @basic_technique_link = BasicTechniqueLink.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @basic_technique_link }
    end
  end

  def new
    @basic_technique_link = BasicTechniqueLink.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @basic_technique_link }
    end
  end

  def edit
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
  end

  def create
    @basic_technique_link = BasicTechniqueLink.new(params[:basic_technique_link])

    respond_to do |format|
      if @basic_technique_link.save
        format.html { redirect_to @basic_technique_link, notice: 'Basic technique link was successfully created.' }
        format.json { render json: @basic_technique_link, status: :created, location: @basic_technique_link }
      else
        format.html { render action: "new" }
        format.json { render json: @basic_technique_link.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @basic_technique_link = BasicTechniqueLink.find(params[:id])

    respond_to do |format|
      if @basic_technique_link.update_attributes(params[:basic_technique_link])
        format.html { redirect_to @basic_technique_link, notice: 'Basic technique link was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @basic_technique_link.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @basic_technique_link = BasicTechniqueLink.find(params[:id])
    @basic_technique_link.destroy

    respond_to do |format|
      format.html { redirect_to basic_technique_links_url }
      format.json { head :no_content }
    end
  end
end
