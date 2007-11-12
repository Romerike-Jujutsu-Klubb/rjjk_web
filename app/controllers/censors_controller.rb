class CensorsController < ApplicationController
  before_filter :admin_required

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @censor_pages, @censors = paginate :censors, :per_page => 10
  end
  
  def list_instructors
    @instructors = Member.find(:all, :conditions => "left_on IS NULL AND instructor = true", :order => 'last_name, first_name')
    rstr =<<EOH
    <table STYLE="border-top: 1px solid #000000;" CELLPADDING="0" CELLSPACING="0" width="100%">
      <tr STYLE="background: #e3e3e3;"><td STYLE="border-bottom: 1px solid #000000;" colspan="2"><B>Instrukt&oslash;rer</B></td><tr>
EOH
    for instr in @instructors
      rstr = rstr << "<tr>" <<
             "<td><a href='#' onClick='add_censor(" + instr.cms_contract_id.to_s + ");'>" <<
             instr.first_name << " " << instr.last_name << "</a></td>" <<
             "<td>" << instr.department << "</td>"
             "</tr>"
    end
    render_text rstr << "</table>\n"
  end

  def show
    @censor = Censor.find(params[:id])
  end

  def new
    @censor = Censor.new
  end

  def add_new_censor
    gid = params[:graduation_id].to_i
    mid = params[:member_id].to_i
    Censor.create!(:graduation_id => gid, :member_id => mid)
    render_text "Added new sensor to graduation #{gid} #{mid}" 
  end

  def create
    @censor = Censor.new(params[:censor])
    if @censor.save
      flash[:notice] = 'Censor was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @censor = Censor.find(params[:id])
  end

  def update
    @censor = Censor.find(params[:id])
    if @censor.update_attributes(params[:censor])
      flash[:notice] = 'Censor was successfully updated.'
      redirect_to :action => 'show', :id => @censor
    else
      render :action => 'edit'
    end
  end

  def destroy
    Censor.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
