# frozen_string_literal: true

class NkfMembersController < ApplicationController
  before_action :admin_required

  def index
    @nkf_members = NkfMember.order(:fornavn, :etternavn).to_a
  end

  RELATED_USER_SYMS = %i[contact_user guardian_1 guardian_2 billing_user payees primary_wards
                         secondary_wards contactees].freeze

  def sync_errors
    @errors = NkfMember.includes(member: { user: RELATED_USER_SYMS }).references(:members)
        .order(left_on: :desc, updated_at: :desc)
        .map { |nkfm| [nkfm.member, nkfm.mapping_changes] }.reject { |m| m[1].empty? }
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
    if @nkf_member.update(params[:nkf_member])
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
