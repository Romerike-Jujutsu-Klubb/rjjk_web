# frozen_string_literal: true

class MembersController < ApplicationController
  before_action :admin_required

  caches_page :image, :thumbnail
  cache_sweeper :member_sweeper, only: %i[create update destroy]

  def index
    @members = Member.all.sort_by(&:name)
  end

  def yaml
    @members = Member.active.to_a
    records = @members.map do |m|
      m.attributes.update(
          'rank_pos' => m.current_rank.try(:position),
          'rank_name' => m.current_rank.try(:name),
          'active' => m.active?
        )
    end
    render body: records.to_yaml, content_type: 'text/yaml', layout: false
  end

  def list_active
    @members = Member.active.sort_by(&:name)
    render :index
  end

  def list_inactive
    @members = Member.includes(:user).where('left_on IS NOT NULL').order('users.last_name').to_a
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
    redirect_to user_path(@member.user_id)
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
    Member.find(params[:id]).destroy
    redirect_to action: :index
  end

  def telephone_list
    @groups = Group.active(Date.current).includes(:members).to_a
  end

  def email_list
    @groups = Group.active(Date.current).includes(:members).to_a
    @former_members = Member.where('left_on IS NOT NULL').to_a
    @administrators = User.find_administrators
    @administrator_emails = @administrators.map(&:email).compact.uniq
    @missing_administrator_emails = @administrators.size - @administrator_emails.size
  end

  def photo
    @member = Member.find(params[:id])
  end

  def save_image
    @member = Member.find(params[:id])
    params.require(:imgBase64) =~ /^data:([^;]+);base64,(.*)$/
    content = Base64.decode64(Regexp.last_match(2))
    content_type = Regexp.last_match(1)
    MemberImage.transaction do
      image = Image.create! user_id: @member.user_id, name: "Foto #{Date.current}",
          content_type: content_type, content_data: content
      @member.member_images.create! image: image
    end
    render plain: content.hash
  end

  def image
    @member = Member.find(params[:id])
    if @member.image?
      send_data(@member.image.content_data,
          disposition: 'inline',
          type: @member.image.content_type,
          filename: @member.image.name)
    else
      render text: 'Bilde mangler'
    end
  end

  def thumbnail
    @member = Member.find(params[:id])
    if (thumbnail = @member.thumbnail)
      send_data(thumbnail,
          disposition: 'inline',
          type: @member.image.content_type,
          filename: @member.image.name)
    else
      render text: 'Bilde mangler'
    end
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
    Date.parse((Date.current.year - offset).to_s + '-12-31').strftime('%Y-%m-%d')
  end

  def year_start(offset = 0)
    Date.parse((Date.current.year - offset).to_s + '-01-01').strftime('%Y-%m-%d')
  end

  def update_memberships
    @member.martial_arts = MartialArt.find(params[:martial_art_ids]) if params[:martial_art_ids]
    # FIXME(uwe): Allow removing for all groups
    @member.groups = Group.find(params[:member_group_ids].keys) if params[:member_group_ids]
  end
end
