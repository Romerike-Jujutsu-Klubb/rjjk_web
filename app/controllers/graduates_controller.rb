class GraduatesController < ApplicationController
  MEMBERS_PER_PAGE = 30

  before_filter :admin_required
  cache_sweeper :grade_history_image_sweeper, :only => [:create, :update, :destroy]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method      => :post, :only => [:destroy, :create, :update],
         :redirect_to => {:action => :list}

  def show_last_grade
    @members      = Member.find(:all)
    @all_grades   = @members.map { |m| m.current_grade }
    @grade_counts = {}
    @all_grades.each do |g|
      @grade_counts[g] ||= 0
      @grade_counts[g] += 1
    end
  end

  def list
    if !params[:id]
      @graduates = Graduate.find(:all, :conditions => "member_id > 0", :order => 'member_id, rank_id DESC')
    else
      @graduates = Graduate.find(:all, :conditions => "member_id = #{params[:id]}", :order => 'rank_id')
    end
  end

  def list_graduates
    if params[:id]
      @graduate_pages, @graduates = paginate :graduates, :per_page => MEMBERS_PER_PAGE, :conditions => "graduation_id = #{params[:id]}", :order => "rank_id,passed"
    else
      @graduate_pages = paginate :graduates, :conditions => "member_id > 0", :order => "member_id,rank_id,passed"
      @graduates      = Graduate.find(:all, :conditions => "member_id > 0", :order => "member_id,rank_id,passed")
    end
    render :action => 'list'
  end

  def yes_no_select(cid, sid, graduate_id)
    rstr = String.new()
    nsel = !sid ? "SELECTED" : ""
    ysel = sid ? "SELECTED" : ""
    rstr << "\n<SELECT NAME='#{cid}_row_#{graduate_id}' STYLE='width: 56px; height: 18px;' ID='#{cid}_row_#{graduate_id}'>\n"
    rstr << "<OPTION #{nsel} VALUE='0'>Nei</OPTION>\n"
    rstr << "<OPTION #{ysel} VALUE='1'>Ja</OPTION>\n"
    rstr << "</SELECT>\n"
  end

  def list_graduations_by_member
    @graduation = Graduation.find(params[:id])
    @censors   = Censor.find(:all, :conditions => "graduation_id = #{@graduation.id}")
    @graduates = Graduate.find(:all, :conditions => ["graduation_id = ? AND member_id != 0", params[:id]],
                               :order            => 'ranks.position DESC, passed, paid_graduation, paid_belt asc',
                               :include          => :rank)
    render :layout => false
  end

  def list_potential_graduates
    graduation = Graduation.find(params[:graduation_id])
    @grads = Member.find(:all, :conditions => ["joined_on <= ? AND left_on IS NULL OR left_on >= ?", graduation.held_on, graduation.held_on], :order => 'first_name, last_name',
                         :select => 'first_name, last_name, id')
    @grads.delete_if { |g| graduation.graduates.map(&:member).include? g }
    rstr =<<EOH
<div style="height:512px; width:256px; overflow:auto; overflow-x:hidden;">
	<table WIDTH="256" CELLPADDING="0" CELLSPACING="0">
	<tr>
		<td STYLE="background: #e3e3e3;border-top: 1px solid #000000;border-bottom: 1px solid #000000;"<B>Medlemmer</B></td>
		<td STYLE="background: #e3e3e3;border-top: 1px solid #000000;border-bottom: 1px solid #000000;" ALIGN="right"><A HREF="#" onClick="hide_glist();">X</A></td>
		<td width=20>&nbsp;</td>
	</td><tr>
EOH
    Group.all(:order => :from_age).each do |group|
      members = @grads.select{|m| m.groups.include? group}
      next if members.empty?
      rstr << "<tr id='group_#{group.id}'>" <<
          "<th align=left><a href='#' onClick='#{members.map{|m| "add_graduate(#{m.id});"}}'>" <<
          "#{group.name}</a></th>" <<
          "<th ALIGN='right'>&nbsp;" <<
          "<th>&nbsp;</th></tr>\n"
      for grad in members
        ln = grad.last_name.split(/\s+/).each { |x| x.capitalize! }.join(' ')
        fn = grad.first_name.split(/\s+/).each { |x| x.capitalize! }.join(' ')
        rstr << "<tr id='potential_graduate_#{grad.id}'>" <<
            "<td align=left><a href='#' onClick='add_graduate(#{grad.id});'>" <<
            "#{fn} #{ln}</a></td>" <<
            "<td ALIGN='right'>&nbsp;" <<
            "<td>&nbsp;</td></tr>\n"
      end
    end
    rstr << "</table>\n</div>\n"
    render :text => rstr
  end

  def update_graduate
    graduate_id = params[:graduate_id].to_i
    rank_id     = params[:rank_id].to_i
    #passed      = params[:passed].to_i
    #paid        = params[:paid].to_i
    #paid_belt   = params[:paid_belt].to_i

    begin
      @graduate = Graduate.find(graduate_id)
      #@graduate.update_attributes!(:rank_id   => rank_id, :passed => passed, :paid_graduation => paid,
      #                             :paid_belt => paid_belt)
      @graduate.update_attributes!(:rank_id   => rank_id)
      render :text => "Endret graderingsinfo for medlem. <!-- #{@graduate.member_id} -->"
    rescue StandardError
      render :text => "Det oppstod en feil ved endring av medlem #{@graduate.member_id}:<P>" + $! + "</P>"
    end
  end

  def show
    @graduate = Graduate.find(params[:id])
  end

  def new
    @graduate = Graduate.new
  end

  def add_new_graduate
    gid    = params[:graduation_id]
    mid    = params[:member_id]
    aid    = params[:martial_arts_id]

    graduation = Graduation.find(gid)
    ma     = MartialArt.find(aid)
    member = Member.find(mid)
    next_rank = member.next_rank(ma, graduation)
    raise "Unable to find rank for martial art with id = #{aid}" unless next_rank

    Graduate.create!(:graduation_id => gid, :member_id => mid, :passed => true,
                     :rank_id       => next_rank.id, :paid_graduation => true, :paid_belt => true)
    render :text =>" "
  end


  def create
    @graduate = Graduate.new(params[:graduate])
    if @graduate.save
      flash[:notice] = 'Graduate was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @graduate = Graduate.find(params[:id])
  end

  def update
    @graduate = Graduate.find(params[:id])
    if @graduate.update_attributes(params[:graduate])
      flash[:notice] = 'Graduate was successfully updated.'
      redirect_to :action => 'show', :id => @graduate
    else
      render :action => 'edit'
    end
  end

  def destroy
    Graduate.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
