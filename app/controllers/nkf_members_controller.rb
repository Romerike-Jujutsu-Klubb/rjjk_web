# frozen_string_literal: true

class NkfMembersController < ApplicationController
  before_action :admin_required

  def index
    @nkf_members = NkfMember.order(:fornavn, :etternavn).to_a
  end

  def show
    if params[:id] && respond_to?(params[:id])
      send params[:id]
      render action: params[:id] unless response_body
      return
    end
    @nkf_member = NkfMember.find(params[:id])
  end

  def new
    @nkf_member = NkfMember.new
  end

  def edit
    @nkf_member = NkfMember.find(params[:id])
  end

  def create
    @nkf_member = NkfMember.new(params[:nkf_member])
    if @nkf_member.save
      flash[:notice] = 'NkfMember was successfully created.'
      redirect_to(@nkf_member)
    else
      render action: 'new'
    end
  end

  def update
    @nkf_member = NkfMember.find(params[:id])
    if @nkf_member.update_attributes(params[:nkf_member])
      flash[:notice] = 'NkfMember was successfully updated.'
      redirect_to(@nkf_member)
    else
      render action: 'edit'
    end
  end

  def destroy
    @nkf_member = NkfMember.find(params[:id])
    @nkf_member.destroy
    redirect_to(nkf_members_url)
  end
end
