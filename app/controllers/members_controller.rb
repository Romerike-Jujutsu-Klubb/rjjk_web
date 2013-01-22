# encoding: UTF-8
class MembersController < ApplicationController
  before_filter :store_location
  before_filter :admin_required

  caches_page :image, :thumbnail, :history_graph, :grade_history_graph
  cache_sweeper :member_sweeper, :only => [:add_group, :create, :update, :destroy]

  def search
    @title = "Søk i medlemsregisteret"
    if params[:q]
      query = params[:q]
      @members = Member.find_by_contents(query)
      @members = @members.sort_by { |member| member.last_name }
    end
  end
  
  def index
    list
    render :action => 'list'
  end
  
  # GET /members/yaml
  def yaml
    @members = Member.find_active
    @members.each{|m| m['image'] = nil}
    render :text => @members.map{|m| m.attributes}.to_yaml, :content_type => 'text/yaml', :layout => false
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #:redirect_to => { :action => :list }
  
  def list_active
    @members = Member.paginate_active(params[:page])
    @member_count = Member.count_active
    render :action => :list
  end
  
  def history_graph
    if params[:id] && params[:id].to_i <= 1280
      g = MemberHistoryGraph.history_graph params[:id].to_i
    else
      g = MemberHistoryGraph.history_graph
    end
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => "RJJK_Medlemshistorikk.png")
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
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => "RJJK_MedlemsGradsHistorikk.png")
  end

  def list_inactive
    @members = Member.paginate :page => params[:page], :per_page => Member::MEMBERS_PER_PAGE, :conditions => 'left_on IS NOT NULL', :order => 'last_name'
    @member_count = Member.count(:conditions => 'left_on IS NOT NULL')
    render :action => :list
  end
  
  def list
    @members = Member.paginate :page => params[:page], :per_page => Member::MEMBERS_PER_PAGE, :order => 'first_name, last_name'
    @member_count = Member.count
  end
  
  def excel_export
    @members = Member.find_active
    render :layout => false
  end
  
  def attendance_form_index
    @groups = Group.active(Date.today).order :from_age
  end
  
  def attendance_form
    if params[:date]
      @date = Date.parse(params[:date])
    end
    @date ||= Date.today
    if params[:group_id]
      if params[:group_id] == 'others'
        @instructors = []
        @members = Member.all(:conditions => ['id NOT in (SELECT DISTINCT member_id FROM groups_members) AND (left_on IS NULL OR left_on > ?)', @date])
        @trials = []
      else
        @group = Group.find(params[:group_id])
        @instructors = Member.active(@date).find_all_by_instructor(true).select{|m| m.groups.any?{|g| g.martial_art_id == @group.martial_art_id}}
        @instructors = @instructors.sort_by{|m| [m.current_rank(@group.martial_art) ? -m.current_rank(@group.martial_art).position : 99, m.first_name, m.last_name]}
        @members = @group.members.active(@date).includes({:graduates => :rank}, {:groups => :group_schedules}, :nkf_member).sort_by {|m| [m.current_rank(@group.martial_art) ? -m.current_rank(@group.martial_art).position : 99, m.first_name, m.last_name]}
        @trials = NkfMemberTrial.all(:conditions => ['alder BETWEEN ? AND ?', @group.from_age, @group.to_age], :order => 'fornavn, etternavn')
      end
    else
      @instructors = []
      @members = []
      @trials = []
    end
    @instructors -= @members
    @passive_members = @members.select{|m| m.nkf_member.medlemsstatus == 'P' || m.attendances.select{|a| (@group.nil? || a.group_schedule.group_id == @group.id) && a.date <= (@date + 31) && a.date > (@date - 92)}.empty?}
    @members -= @passive_members
    render :layout => 'print'
  end
  
  def new
    @member ||= Member.new
    @groups = Group.all(:include => :martial_art, :order => 'martial_arts.name, groups.name')
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
  
  def edit
    @member = Member.find(params[:id])
    @groups = Group.all(:include => :martial_art, :order => 'martial_arts.name, groups.name')
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
    Member.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def NKF_report
    @male_six_twelve   = member_count(true, 6, 12)
    @female_six_twelve = member_count(false, 6, 12)
    @male_thirteen_nineteen   = member_count(true, 13, 19)
    @female_thirteen_nineteen = member_count(false, 13, 19)
    @male_twenty_twentyfive   = member_count(true, 20, 25)
    @female_twenty_twentyfive= member_count(false, 20, 25)
    @male_twentysix_and_over   = member_count(true, 26, 100)
    @female_twentysix_and_over= member_count(false, 26, 100)
    @incomplete_members = Member.find_active.select {|m| m.birthdate.nil?}
  end
  
  def telephone_list
    @groups = Group.all(:include => :members)
  end
  
  def email_list
    @groups = Group.all(:include => :members)
    @former_members = Member.all(:conditions => 'left_on IS NOT NULL')
    @administrators = User.find_administrators
    @administrator_emails = @administrators.map{|m|m.email}.compact.uniq
    @missing_administrator_emails = @administrators.size - @administrator_emails.size
  end
  
  def export_emails
    content_type = if request.user_agent =~ /windows/i
                     'application/vnd.ms-excel'
    else
                     'text/csv'
    end
    
    CSV::Writer.generate(output = "") do |csv|
      @Params.find(:all).each do |param|
        csv << [param]
      end
    end
    send_data(output, 
              :type => content_type, 
              :filename => "Epostliste.csv")
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
    
    @new_cms_members = @cms_members.select{|cmsm| @members.find{|m| m.cms_contract_id == cmsm.cms_contract_id}.nil?}
    @new_inactive_members = @members.select{|m| cmsm = @inactive_cms_members.find{|cmsm| cmsm.cms_contract_id == m.cms_contract_id} && m.left_on == cmsm.left_on}
    @members_not_in_cms = @members.select{|m| @cms_members.find{|cmsm| cmsm.cms_contract_id == m.cms_contract_id}.nil?}
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
