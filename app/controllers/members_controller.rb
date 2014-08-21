class MembersController < ApplicationController
  before_filter :admin_required

  # FIXME(uwe):  Verify caching
  caches_page :age_chart, :image, :thumbnail, :history_graph, :grade_history_graph,
      :grade_history_graph_percentage
  cache_sweeper :member_sweeper, :only => [:add_group, :create, :update, :destroy]
  # FIXME(uwe):  Verify caching

  def search
    @title = 'Søk i medlemsregisteret'
    if params[:q]
      query = params[:q]
      @members = Member.search(query)
      @members = @members.sort_by { |member| member.last_name }
    end
  end

  def index
    @members = Member.order('first_name, last_name').
        paginate(page: params[:page], per_page: Member::MEMBERS_PER_PAGE)
    @member_count = Member.count
  end

  def yaml
    @members = Member.find_active
    @members.each { |m| m['image'] = nil }
    render :text => @members.map { |m| m.attributes }.to_yaml, :content_type => 'text/yaml', :layout => false
  end

  def list_active
    @members = Member.paginate_active(params[:page])
    @member_count = Member.count_active
    render :index
  end

  def history_graph
    if params[:id] && params[:id].to_i <= 1280
      if params[:id] =~ /^\d+x\d+$/
        g = MemberHistoryGraph.history_graph params[:id]
      else
        g = MemberHistoryGraph.history_graph params[:id].to_i
      end
    else
      g = MemberHistoryGraph.history_graph
    end
    send_data(g, disposition: 'inline', type: 'image/png', filename: 'RJJK_Medlemshistorikk.png')
  end

  def grade_history_graph
    if params[:id] && params[:id].to_i <= 1280
      g = MemberGradeHistoryGraph.history_graph :size => params[:id].to_i,
          :interval => params[:interval].try(:to_i).try(:days),
          :step => params[:step].try(:to_i).try(:days),
          :percentage => params[:percentage].try(:to_i)
    else
      g = MemberGradeHistoryGraph.history_graph
    end
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => 'RJJK_MedlemsGradsHistorikk.png')
  end

  def grade_history_graph_percentage
    grade_history_graph
  end

  def age_chart
    if params[:id] && params[:id].to_i <= 1280
      g = MemberAgeChart.chart params[:id].to_i
    else
      g = MemberAgeChart.chart
    end
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => 'RJJK_Aldersfordeling.png')
  end

  def list_inactive
    @members = Member.where('left_on IS NOT NULL').order('last_name').
        paginate(page: params[:page], per_page: Member::MEMBERS_PER_PAGE)
    @member_count = Member.count(:conditions => 'left_on IS NOT NULL')
    render :action => :index
  end

  def excel_export
    @members = Member.find_active
    render :layout => false
  end

  def new
    @member ||= Member.new
    @groups = Group.includes(:martial_art).order('martial_arts.name, groups.name').all
  end

  def create
    @member = Member.new(params[:member])
    update_memberships
    if @member.save
      flash[:notice] = 'Medlem opprettet.'
      redirect_to :action => :edit, :id => @member.id
    else
      new
      render :action => 'new'
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
      redirect_to :action => :edit, :id => @member.id
    else
      new
      render :action => 'new'
    end
  end

  def show
    edit
    render :action => :edit
  end

  def edit
    @member = Member.find(params[:id])
    @groups = Group.includes(:martial_art).order('martial_arts.name, groups.name').where(:closed_on => nil).all
    @groups |= @member.groups
  end

  def update
    @member = Member.find(params[:id])
    update_memberships
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Medlemmet oppdatert.'
      redirect_to :action => :edit, :id => @member
    else
      @groups = Group.all(:include => :martial_art, :order => 'martial_arts.name, groups.name')
      render :action => 'edit'
    end
  end

  def destroy
    # FIXME(uwe): Remove when moved to Rails 4.2
    # https://github.com/rails/rails/issues/12380
    # https://github.com/rails/rails/pull/12450
    Member.transaction do

      member = Member.find(params[:id])
      if (user = member.user)
        member.user_id = nil
        member.save(validate: false)
        user.destroy
      end
      # EMXIF

      Member.find(params[:id]).destroy

      # FIXME(uwe): Remove when moved to Rails 4.2
    end
    # EMXIF

    redirect_to :action => 'index'
  end

  def NKF_report
    @male_six_twelve = member_count(true, 6, 12)
    @female_six_twelve = member_count(false, 6, 12)
    @male_thirteen_nineteen = member_count(true, 13, 19)
    @female_thirteen_nineteen = member_count(false, 13, 19)
    @male_twenty_twentyfive = member_count(true, 20, 25)
    @female_twenty_twentyfive= member_count(false, 20, 25)
    @male_twentysix_and_over = member_count(true, 26, 100)
    @female_twentysix_and_over= member_count(false, 26, 100)
    @incomplete_members = Member.find_active.select { |m| m.birthdate.nil? }
  end

  def telephone_list
    @groups = Group.active(Date.today).includes(:members).all
  end

  def email_list
    @groups = Group.active(Date.today).includes(:members).all
    @former_members = Member.where('left_on IS NOT NULL').all
    @administrators = User.find_administrators
    @administrator_emails = @administrators.map { |m| m.email }.compact.uniq
    @missing_administrator_emails = @administrators.size - @administrator_emails.size
  end

  def export_emails
    content_type = if request.user_agent =~ /windows/i
                     'application/vnd.ms-excel'
                   else
                     'text/csv'
                   end

    CSV::Writer.generate(output = '') do |csv|
      @Params.find(:all).each do |param|
        csv << [param]
      end
    end
    send_data(output,
        :type => content_type,
        :filename => 'Epostliste.csv')
  end

  def income
    @members = CmsMember.find_active
  end

  def image
    @member = Member.find(params[:id])
    if @member.image?
      send_data(@member.image.data,
          :disposition => 'inline',
          :type => @member.image.content_type,
          :filename => @member.image.filename)
    else
      render :text => 'Bilde mangler'
    end
  end

  def thumbnail
    @member = Member.find(params[:id])
    if thumbnail = @member.thumbnail
      send_data(thumbnail,
          :disposition => 'inline',
          :type => @member.image.content_type,
          :filename => @member.image.name)
    else
      render :text => 'Bilde mangler'
    end
  end

  def cms_comparison
    @cms_members = CmsMember.find_active
    @members = Member.find_active
    @inactive_cms_members = CmsMember.find_inactive

    @new_cms_members = @cms_members.select { |cmsm| @members.find { |m| m.cms_contract_id == cmsm.cms_contract_id }.nil? }
    @new_inactive_members = @members.select { |m| cmsm = @inactive_cms_members.find { |cmsm| cmsm.cms_contract_id == m.cms_contract_id } && m.left_on == cmsm.left_on }
    @members_not_in_cms = @members.select { |m| @cms_members.find { |cmsm| cmsm.cms_contract_id == m.cms_contract_id }.nil? }
  end

  def missing_contract
    member = Member.find(params[:id])
    @name = "#{member.first_name} #{member.last_name}"
    @email = member.invoice_email
    render :layout => 'print'
  end

  def trial_missing_contract
    @trial = NkfMemberTrial.find(params[:id])
    @name = "#{@trial.fornavn} #{@trial.etternavn}"
    @email = @trial.epost_faktura || @trial.epost
    render :missing_contract, :layout => 'print'
  end

  def add_group
    @member = Member.find(params[:id])
    @member.groups << Group.find(params[:group_id])
    redirect_to :controller => :nkf_members, :action => :comparison, :id => 0
  end

  def remove_group
    @member = Member.find(params[:id])
    @member.groups.delete(Group.find(params[:group_id]))
    redirect_to :controller => :nkf_members, :action => :comparison, :id => 0
  end

  def map
    @json = Member.active(Date.today).to_gmaps4rails
  end

  def my_media
    @images = Image
  end

  def report
    @date = (params[:year] && params[:month] && Date.new(params[:year].to_i, params[:month].to_i, 1)) || Date.today.beginning_of_month
    @year = @date.year
    @month = @date.month
    @first_date = @date.beginning_of_month - 1
    @last_date = @date.end_of_month
    @members_before = Member.active(@first_date).all
    @members_after = Member.active(@last_date).all
    @members_in = @members_after - @members_before
    @members_out = @members_before - @members_after
  end

  private

  def year_end(offset=0)
    Date.parse((Date.today.year - offset).to_s + '-12-31').strftime('%Y-%m-%d')
  end

  def year_start(offset=0)
    Date.parse((Date.today.year - offset).to_s + '-01-01').strftime('%Y-%m-%d')
  end

  def member_count(male, from_age, to_age)
    Member.count(:conditions => "left_on IS NULL AND male = #{male} AND birthdate <= '#{year_end(from_age)}' AND birthdate >= '#{year_start(to_age)}'")
  end

  def update_memberships
    @member.martial_arts = MartialArt.find(params[:martial_art_ids]) if params[:martial_art_ids]
    if params[:member_group_ids]
      @member.groups = Group.find(params[:member_group_ids].keys)
    else
      @member.groups = []
    end
  end

end
