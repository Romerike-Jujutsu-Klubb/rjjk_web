# frozen_string_literal: true

class PageAliasesController < ApplicationController
  before_action :admin_required

  def index
    @page_aliases = PageAlias.order(:old_path, :new_path).to_a

    respond_to do |format|
      format.html
      format.json { render json: @page_aliases }
    end
  end

  def show
    @page_alias = PageAlias.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @page_alias }
    end
  end

  def new
    @page_alias = PageAlias.new

    respond_to do |format|
      format.html
      format.json { render json: @page_alias }
    end
  end

  def edit
    @page_alias = PageAlias.find(params[:id])
  end

  def create
    @page_alias = PageAlias.new(params[:page_alias])

    respond_to do |format|
      if @page_alias.save
        format.html { redirect_to @page_alias, notice: 'Page alias was successfully created.' }
        format.json { render json: @page_alias, status: :created, location: @page_alias }
      else
        format.html { render action: 'new' }
        format.json { render json: @page_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @page_alias = PageAlias.find(params[:id])

    respond_to do |format|
      if @page_alias.update(params[:page_alias])
        format.html { redirect_to @page_alias, notice: 'Page alias was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @page_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @page_alias = PageAlias.find(params[:id])
    @page_alias.destroy

    respond_to do |format|
      format.html { redirect_to page_aliases_url }
      format.json { head :no_content }
    end
  end
end
