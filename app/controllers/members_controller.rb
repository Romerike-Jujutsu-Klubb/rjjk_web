class MembersController < ApplicationController
  MEMBERS_PER_PAGE = 30
  
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
  
  def index
    list
    render :action => 'list'
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }
  
  def list_active
    @member_pages, @members = paginate :members, :per_page => MEMBERS_PER_PAGE,
    :conditions => 'left_on IS NULL',
    :order => 'last_name'
    render :action => :list
  end

  def history_graph
    g = Member.history_graph
    send_data(g, :disposition => 'inline', :type => 'image/png', :filename => "RJJK_Medlemshistorikk.png")
  end
  
  def list_inactive
    @member_pages, @members = paginate :members, :per_page => MEMBERS_PER_PAGE,
    :conditions => 'left_on IS NOT NULL',
    :order => 'last_name'
    render :action => :list
  end
  
  def list
    @member_pages, @members = paginate :members, :per_page => MEMBERS_PER_PAGE,
    :order => 'last_name'
  end
  
  def new
    @member = Member.new
  end
  
  def create
    @member = Member.new(params[:member])
    if @member.save
      flash[:notice] = 'Medlem opprettet.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @member = Member.find(params[:id])
  end
  
  def update
    @member = Member.find(params[:id])
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
    @senior_tels = Member.find(:all, :conditions => 'left_on IS NULL AND senior = true')
    @junior_tels = Member.find(:all, :conditions => 'left_on IS NULL AND senior = false')
  end
  
  def email_list
    @senior_emails = Member.find(:all, :conditions => 'left_on IS NULL AND senior = true')
    @junior_emails = Member.find(:all, :conditions => 'left_on IS NULL AND senior = false')
    @old_emails    = Member.find(:all, :conditions => 'left_on IS NOT NULL')
    
    seniors = Member.find(:all,  :conditions => 'left_on IS NULL AND senior = true')
    juniors = Member.find(:all, :conditions => 'left_on IS NULL AND senior = false')
    old = Member.find(:all, :conditions => 'left_on IS NOT NULL')
    
    @export_senior_emails = seniors.map {|member| member.email}.compact
    @export_junior_emails = juniors.map {|member| member.email}.compact
    @export_old_emails = old.map {|member| member.email}.compact
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
    Date.parse((Date.today.year - offset).to_s + '-12-31').strftime('%Y-%M-%D')    
  end
  
  def year_start(offset=0)
    Date.parse((Date.today.year - offset).to_s + '-01-01').strftime('%Y-%M-%D')    
  end  
  
  def member_count(male, from_age, to_age)
    Member.count(:conditions => "left_on IS NULL AND male = #{male} AND birtdate <= #{year_end(from_age)} AND birtdate >= #{year_start(to_age)}")
  end

  def find_incomplete
    @incomplete_members = Member.find(:all, :conditions => 'birtdate IS NULL', :order => 'last_name, first_name')
  end
end
