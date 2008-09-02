class MembersController < ApplicationController
  before_filter :store_location
  before_filter :admin_required
  before_filter :find_incomplete
  
  #  add_to_sortable_columns('listing', 
  #    :model => Member, 
  #    :field => 'first_name', 
  #    :alias => 'fornavn') 
  #  add_to_sortable_columns('listing', 
  #    :model => Member, 
  #    :field => 'last_name', 
  #    :alias => 'etternavn') 
  
  def import
    @new_members, @updated_members = CmsImport.import
  end
  
  def search
    @title = "Søk i medlemsregisteret"
    if params[:q]
      query = params[:q]
      begin
        @members = Member.find_by_contents(query, :limit => :all)
        # Sort by last name (requires a spec for each user).
        @members = @members.sort_by { |member| member.last_name }
      rescue Ferret::QueryParser::QueryParseException
        @invalid = true
      end
    end
  end
  
  def index
    list
    render :action => 'list'
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }
  
  def list_active
    @members = Member.paginate_active(params[:page])
    @member_count = Member.count_active
    render :action => :list
  end
  
  def history_graph
    g = Member.history_graph
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => "RJJK_Medlemshistorikk.png")
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
  
  def attendance_form_index
    @groups = []
    MartialArt.find(:all, :order => :family).each do |ma| 
      ma.groups.each do |group|
        @groups << group
      end
    end
  end
  
  def attendance_form
    if params[:group_id]
      if params[:group_id] == 'others'
        @members = Member.find(:all, :conditions => 'id NOT in (SELECT DISTINCT member_id FROM groups_members)')
      else
        @group = Group.find(params[:group_id])
        @members = @group.members
      end
    else
      @members = []
    end
    @members = @members.sort_by {|m| [m.first_name, m.last_name]}
    render :layout => :print
  end
  
  def new
    @member = Member.new
    @groups = Group.find(:all, :include => :martial_art, :order => 'martial_arts.name, groups.name')
  end
  
  def create
    @member = Member.new(params[:member])
    @member.martial_arts = MartialArt.find(params[:martial_art_ids]) if params[:martial_art_ids]
    @member.groups = Group.find(params[:group_ids]) if params[:group_ids]
    if @member.save
      flash[:notice] = 'Medlem opprettet.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @member = Member.find(params[:id])
    @groups = Group.find(:all, :include => :martial_art, :order => 'martial_arts.name, groups.name')
  end
  
  def update
    @member = Member.find(params[:id])
    @member.martial_arts = MartialArt.find(params[:martial_art_ids]) if params[:martial_art_ids]
    @member.groups = Group.find(params[:group_ids]) if params[:group_ids]
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Medlemmet oppdatert.'
      redirect_to :action => :edit, :id => @member
    else
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
  end
  
  def telephone_list
    @groups = Group.find(:all, :include => :members)
  end
  
  def email_list
    @groups = Group.find(:all, :include => :members)
    @former_members = Member.find(:all, :conditions => 'left_on IS NOT NULL')
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
  
  def active_contracts
    @members = Member.find_active
  end
  
  def income
    @members = Member.find_active  
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
  
  def find_incomplete
    @incomplete_members = Member.find_active.select {|m| m.birthdate.nil?}
  end
end
