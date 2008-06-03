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
    @censors = Censor.paginate :page => params[:page], :per_page => 10
  end
  
  def list_instructors
    @instructors = Member.find(:all, :conditions => "left_on IS NULL AND instructor = true", :order => 'last_name, first_name')
    rstr =<<EOH
    <div style="height:256px; width:284px; overflow: auto; overflow-x: hidden;">
    <table STYLE="height: 128px;" CELLPADDING="0" CELLSPACING="0" width="100%">
      <tr>
        <td STYLE="border-top: 1px solid #000000;background: #e3e3e3;border-bottom: 1px solid #000000;"><B>Instrukt&oslash;rer</B></td>
        <td ALIGN="right" STYLE="border-top: 1px solid #000000;background: #e3e3e3;border-bottom: 1px solid #000000;"><A HREF="#" onClick="hide_glist();">X</A></td>
        <td width=20>&nbsp;</td>
      </tr>
EOH
    for instr in @instructors
      #ln = instr.last_name.index(/\s+/) ? instr.last_name.split(/\s+/).each { |x| x.capitalize!}.join(' ') : instr.last_name.capitalize 
      #fn = instr.first_name.index(/\s+/) ? instr.first_name.split(/\s+/).each { |x| x.capitalize!}.join(' ') : instr.first_name.capitalize
      fn = instr.first_name.split(/\s+/).each { |x| x.capitalize!}.join(' ')
      ln = instr.last_name.split(/\s+/).each { |x| x.capitalize!}.join(' ') 
      nm = fn << " " << ln
      rstr = rstr << "<tr>" <<
             "<td><a href='#' onClick='add_censor(" + instr.cms_contract_id.to_s + ",\"" + nm + "\");'>" <<
             nm << "</a></td>" << "<td ALIGN=right>" << instr.department << "</td>"
             "</tr>"
    end
    render_text rstr << "</table>\n</div>\n"
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
    name = params[:name]
    if Censor.find(:first, :conditions => "member_id = #{mid} AND graduation_id = #{gid}")
      render_text "Censor already exists"
    else
      Censor.create!(:graduation_id => gid, :member_id => mid)
      render_text "Added #{name} as new sensor to graduation"
    end
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
