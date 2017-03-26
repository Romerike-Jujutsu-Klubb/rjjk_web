# frozen_string_literal: true
class MembersController < ApplicationController
  before_action :admin_required

  # FIXME(uwe):  Verify caching
  caches_page :age_chart, :image, :thumbnail, :history_graph, :grade_history_graph,
      :grade_history_graph_percentage
  cache_sweeper :member_sweeper, only: [:add_group, :create, :update, :destroy]
  # FIXME(uwe):  Verify caching

  def search
    @title = 'Søk i medlemsregisteret'
    return unless params[:q]
    query = params[:q]
    @members = Member.search(query)
    @members = @members.sort_by(&:last_name)
  end

  def index
    @members = Member.order('first_name, last_name')
        .paginate(page: params[:page], per_page: Member::MEMBERS_PER_PAGE)
    @member_count = Member.count
  end

  def yaml
    @members = Member.active.without_image.to_a
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
    @members = Member.paginate_active(params[:page])
    @member_count = Member.active.count
    render :index
  end

  def history_graph
    g = if params[:id] && params[:id].to_i <= 1280
          if params[:id] =~ /^\d+x\d+$/
            MemberHistoryGraph.history_graph params[:id]
          else
            MemberHistoryGraph.history_graph params[:id].to_i
          end
        else
          MemberHistoryGraph.history_graph
        end
    send_data(g, disposition: 'inline', type: 'image/png', filename: 'RJJK_Medlemshistorikk.png')
  end

  def grade_history_graph
    g = if params[:id] && params[:id].to_i <= 1280
          MemberGradeHistoryGraph.new.history_graph size: params[:id].to_i,
              interval: params[:interval].try(:to_i).try(:days),
              step: params[:step].try(:to_i).try(:days),
              percentage: params[:percentage].try(:to_i)
        else
          MemberGradeHistoryGraph.new.history_graph
        end
    send_data(g, disposition: 'inline', type: 'image/png',
        filename: 'RJJK_MedlemsGradsHistorikk.png')
  end

  def grade_history_graph_percentage
    grade_history_graph
  end

  def age_chart
    g = if params[:id] && params[:id].to_i <= 1280
          MemberAgeChart.chart params[:id].to_i
        else
          MemberAgeChart.chart
        end
    send_data(g, disposition: 'inline', type: 'image/png', filename: 'RJJK_Aldersfordeling.png')
  end

  def list_inactive
    @members = Member.where('left_on IS NOT NULL').order('last_name')
        .paginate(page: params[:page], per_page: Member::MEMBERS_PER_PAGE)
    @member_count = Member.where('left_on IS NOT NULL').count
    render action: :index
  end

  def excel_export
    @members = Member.active.to_a
    render layout: false
  end

  def new
    @member ||= Member.new
    @groups = Group.includes(:martial_art).order('martial_arts.name, groups.name').to_a
  end

  def create
    @member = Member.new(params[:member])
    update_memberships
    if @member.save
      flash[:notice] = 'Medlem opprettet.'
      redirect_to action: :edit, id: @member.id
    else
      new
      render action: 'new'
    end
  end

  def create_from_cms_member
    cms_member = CmsMember.find(params[:cms_member_id])
    attributes = cms_member.attributes
    attributes.delete('created_at')
    attributes.delete('updated_at')
    @member = Member.new(attributes)
    if @member.save
      flash[:notice] = 'Medlem opprettet.'
      redirect_to action: :edit, id: @member.id
    else
      new
      render action: 'new'
    end
  end

  def show
    edit
    render action: :edit
  end

  def edit
    @member = Member.find(params[:id])
    @groups = Group.includes(:martial_art).order('martial_arts.name, groups.name')
        .where(closed_on: nil).to_a
    @groups |= @member.groups
  end

  def update
    @member = Member.find(params[:id])
    update_memberships
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Medlemmet oppdatert.'
      redirect_to action: :edit, id: @member
    else
      @groups = Group.includes(:martial_art).order('martial_arts.name, groups.name').to_a
      render action: 'edit'
    end
  end

  def destroy
    Member.find(params[:id]).destroy
    redirect_to action: 'index'
  end

  def nkf_report
    @male_six_twelve = member_count(true, 6, 12)
    @female_six_twelve = member_count(false, 6, 12)
    @male_thirteen_nineteen = member_count(true, 13, 19)
    @female_thirteen_nineteen = member_count(false, 13, 19)
    @male_twenty_twentyfive = member_count(true, 20, 25)
    @female_twenty_twentyfive = member_count(false, 20, 25)
    @male_twentysix_and_over = member_count(true, 26, 100)
    @female_twentysix_and_over = member_count(false, 26, 100)
    @incomplete_members = Member.active.to_a.select { |m| m.birthdate.nil? }
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

  def export_emails
    content_type =
        if request.user_agent =~ /windows/i
          'application/vnd.ms-excel'
        else
          'text/csv'
        end

    CSV::Writer.generate(output = '') do |csv|
      @Params.all.each do |param|
        csv << [param]
      end
    end
    send_data(output,
        type: content_type,
        filename: 'Epostliste.csv')
  end

  def income
    @members = CmsMember.find_active
  end

  def image
    @member = Member.find(params[:id])
    if @member.image?
      send_data(@member.image.data,
          disposition: 'inline',
          type: @member.image.content_type,
          filename: @member.image.filename)
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

  def cms_comparison
    @cms_members = CmsMember.find_active
    @members = Member.active.to_a
    @inactive_cms_members = CmsMember.find_inactive

    @new_cms_members = @cms_members
        .select { |cmsm| @members.find { |m| m.cms_contract_id == cmsm.cms_contract_id }.nil? }
    @new_inactive_members = @members.select do |m|
      (cmsm = @inactive_cms_members.find do |cmsm2|
        cmsm2.cms_contract_id == m.cms_contract_id
      end) && m.left_on == cmsm.left_on
    end
    @members_not_in_cms = @members.select do |m|
      @cms_members.find { |cmsm| cmsm.cms_contract_id == m.cms_contract_id }.nil?
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

  def add_group
    @member = Member.find(params[:id])
    @member.groups << Group.find(params[:group_id])
    redirect_to controller: :nkf_members, action: :comparison, id: 0
  end

  def remove_group
    @member = Member.find(params[:id])
    @member.groups.delete(Group.find(params[:group_id]))
    redirect_to controller: :nkf_members, action: :comparison, id: 0
  end

  def map
    @json = Member.active(Date.current).to_gmaps4rails
  end

  def my_media
    @images = Image
  end

  def report
    @date = if params[:year] && params[:month]
              Date.new(params[:year].to_i, params[:month].to_i, 1)
            else
              Date.current.beginning_of_month
            end
    @year = @date.year
    @month = @date.month
    @first_date = @date.beginning_of_month - 1
    @last_date = @date.end_of_month
    @members_before = Member.active(@first_date).to_a
    @members_after = Member.active(@last_date).to_a
    @members_in = @members_after - @members_before
    @members_out = @members_before - @members_after
  end

  private

  def year_end(offset = 0)
    Date.parse((Date.current.year - offset).to_s + '-12-31').strftime('%Y-%m-%d')
  end

  def year_start(offset = 0)
    Date.parse((Date.current.year - offset).to_s + '-01-01').strftime('%Y-%m-%d')
  end

  def member_count(male, from_age, to_age)
    Member
        .where('left_on IS NULL AND male = ? AND birthdate <= ? AND birthdate >= ?',
            male, year_end(from_age), year_start(to_age))
        .count
  end

  def update_memberships
    @member.martial_arts = MartialArt.find(params[:martial_art_ids]) if params[:martial_art_ids]
    @member.groups = if params[:member_group_ids]
                       Group.find(params[:member_group_ids].keys)
                     else
                       []
                     end
  end
end
