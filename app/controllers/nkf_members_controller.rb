# frozen_string_literal: true

class NkfMembersController < ApplicationController
  before_action :admin_required

  def index
    @nkf_members = NkfMember.order(:fornavn, :etternavn).to_a
  end

  RELATED_USER_SYMS = { contact_user: :member, guardian_1: :member, guardian_2: :member,
                        billing_user: :member, payees: :member, primary_wards: :member,
                        secondary_wards: :member, contactees: :member }.freeze

  def sync_errors
    @errors = NkfMember.includes(member: [{ user: RELATED_USER_SYMS }, :groups])
        .references(:members).order('members.left_on': :desc, updated_at: :desc)
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
