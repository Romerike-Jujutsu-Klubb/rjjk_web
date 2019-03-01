# frozen_string_literal: true

class PageAliasesController < ApplicationController
  before_action :admin_required

  def index
    @page_aliases = PageAlias.order(:old_path, :new_path).to_a
  end

  def show
    edit
  end

  def new
    @page_alias = PageAlias.new
  end

  def edit
    @page_alias = PageAlias.find(params[:id])
    render :edit
  end

  def create
    @page_alias = PageAlias.new(params[:page_alias])
    if @page_alias.save
      redirect_to page_aliases_path, notice: 'Page alias was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @page_alias = PageAlias.find(params[:id])
    if @page_alias.update(params[:page_alias])
      redirect_to page_aliases_path, notice: 'Page alias was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @page_alias = PageAlias.find(params[:id])
    @page_alias.destroy
    redirect_to page_aliases_url
  end
end
