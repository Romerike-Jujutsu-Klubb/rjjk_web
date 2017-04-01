# frozen_string_literal: true

class NkfMembersController < ApplicationController
  before_action :admin_required

  # FIXME(uwe):  Verify caching
  cache_sweeper :member_sweeper, only: %i(create_member update_member)

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
      # redirect_to(@nkf_member)
      # redirect_to nkf_members_path
      redirect_to action: :comparison, id: 0
    else
      render action: 'edit'
    end
  end

  def destroy
    @nkf_member = NkfMember.find(params[:id])
    @nkf_member.destroy
    redirect_to(nkf_members_url)
  end

  def comparison
    c = NkfMemberComparison.new
    @orphan_nkf_members = c.orphan_nkf_members
    @orphan_members = c.orphan_members
    @groups = Group.order('from_age DESC, to_age DESC').to_a
    @members = c.members
  end

  def create_member
    nkf_member = NkfMember.find(params[:id])
    flash[:notice] = if nkf_member.create_corresponding_member!
                       t(:member_created)
                     else
                       'Member creation failed.'
                     end
    redirect_to action: :comparison, id: 0
  end

  def update_member
    @member = Member.find(params[:id])
    flash[:notice] = if @member.update_attributes(params[:member])
                       'Member was successfully updated.'
                     else
                       'Member update failed.'
                     end
    redirect_to action: :comparison, id: 0
  end

  def import
    import = NkfMemberImport.new
    error_records = import.error_records
    records_size = error_records.size
    flash[:notice] = "#{import.changes.size} records imported, #{records_size} failed, " \
        "#{import.import_rows&.size.to_i - import.changes&.size.to_i - records_size} skipped"
    if error_records.any?
      error_messages = error_records.map { |r| [r, r.errors.full_messages] }
      flash[:notice] += "<br>#{html_escape(error_messages.inspect)}"
    end

    redirect_to action: :comparison
  end
end
