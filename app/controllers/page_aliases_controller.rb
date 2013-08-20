class PageAliasesController < ApplicationController
  before_filter :admin_required

  # GET /page_aliases
  # GET /page_aliases.json
  def index
    @page_aliases = PageAlias.order(:old_path, :new_path).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @page_aliases }
    end
  end

  # GET /page_aliases/1
  # GET /page_aliases/1.json
  def show
    @page_alias = PageAlias.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page_alias }
    end
  end

  # GET /page_aliases/new
  # GET /page_aliases/new.json
  def new
    @page_alias = PageAlias.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page_alias }
    end
  end

  # GET /page_aliases/1/edit
  def edit
    @page_alias = PageAlias.find(params[:id])
  end

  # POST /page_aliases
  # POST /page_aliases.json
  def create
    @page_alias = PageAlias.new(params[:page_alias])

    respond_to do |format|
      if @page_alias.save
        format.html { redirect_to @page_alias, notice: 'Page alias was successfully created.' }
        format.json { render json: @page_alias, status: :created, location: @page_alias }
      else
        format.html { render action: "new" }
        format.json { render json: @page_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /page_aliases/1
  # PUT /page_aliases/1.json
  def update
    @page_alias = PageAlias.find(params[:id])

    respond_to do |format|
      if @page_alias.update_attributes(params[:page_alias])
        format.html { redirect_to @page_alias, notice: 'Page alias was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @page_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_aliases/1
  # DELETE /page_aliases/1.json
  def destroy
    @page_alias = PageAlias.find(params[:id])
    @page_alias.destroy

    respond_to do |format|
      format.html { redirect_to page_aliases_url }
      format.json { head :no_content }
    end
  end
end
