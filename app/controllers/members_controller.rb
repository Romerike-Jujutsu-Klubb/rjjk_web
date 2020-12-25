# frozen_string_literal: true

class MembersController < ApplicationController
  before_action :admin_required

  def index
    @members = Member.all.sort_by(&:name)
  end

  def list_active
    @members = Member.active.sort_by(&:name)
    render :index
  end

  def list_inactive
    @members = Member.includes(:user).where.not(left_on: nil).order('users.last_name').to_a
    render :index
  end

  def excel_export
    @members = Member.active.to_a
    render layout: false
  end

  def new
    @member ||= Member.new
    @groups = Group.includes(:martial_art).order('martial_arts.name, groups.name').to_a
    render :new
  end

  def create
    @member = Member.new(params[:member])
    update_memberships
    if @member.save
      flash[:notice] = 'Medlem opprettet.'
      redirect_to action: :edit, id: @member.id
    else
      new
    end
  end

  def show
    edit
  end

  def edit
    @member ||= Member.find(params[:id])
    redirect_to user_path(@member.user_id, anchor: "tab_membership_#{@member.id}_tab")
  end

  def update
    @member = Member.find(params[:id])
    update_memberships
    if @member.update(params[:member])
      flash[:notice] = 'Medlemmet oppdatert.'
      NkfMemberSyncJob.perform_later @member unless Rails.env.development?
      back_or_redirect_to action: :edit, id: @member
    else
      edit
    end
  end

  def destroy
    member = Member.find(params[:id])
    member.destroy!
    redirect_to member.user
  end

  def telephone_list
    @groups = Group.active(Date.current).includes(:members).to_a
  end

  def email_list
    @groups = Group.active(Date.current).includes(:members).to_a
    @former_members = Member.where.not(left_on: nil).to_a
    @administrators = User.find_administrators
    @administrator_emails = @administrators.map(&:email).compact.uniq
    @missing_administrator_emails = @administrators.size - @administrator_emails.size
  end

  def missing_contract
    member = Member.find(params[:id])
    @name = "#{member.first_name} #{member.last_name}"
    @email = member.invoice_email
    render layout: 'print'
  end

  def trial_missing_contract
    @trial = NkfMemberTrial.find(params[:id])
    @name = "#{@trial.fornavn} #{@trial.etternavn}"
    @email = @trial.epost_faktura || @trial.epost
    render :missing_contract, layout: 'print'
  end

  def map
    @json = Member.active(Date.current).to_gmaps4rails
  end

  def my_media
    @images = Image
  end

  private

  def year_end(offset = 0)
    Date.parse("#{Date.current.year - offset}-12-31").strftime('%Y-%m-%d')
  end

  def year_start(offset = 0)
    Date.parse("#{Date.current.year - offset}-01-01").strftime('%Y-%m-%d')
  end

  def update_memberships
    @member.martial_arts = MartialArt.find(params[:martial_art_ids]) if params[:martial_art_ids]
    # FIXME(uwe): Allow removing for all groups
    @member.groups = Group.find(params[:member_group_ids].keys) if params[:member_group_ids]
  end
end
