class GraduatesController < ApplicationController
  MEMBERS_PER_PAGE = 30

  before_filter :admin_required

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def show_last_grade
    @members = Member.find(:all)
    @all_grades = @members.map {|m| m.current_grade}
    @grade_counts = {}
    @all_grades.each {|g|
      @grade_counts[g] ||= 0
      @grade_counts[g] += 1
    }
  end
  
  def list
    if !params[:id]
      @graduate_pages = paginate :graduates, :conditions => "member_id > 0", :order => 'member_id, rank_id DESC'
      @graduates = Graduate.find(:all, :conditions => "member_id > 0", :order => 'member_id, rank_id DESC')
    else
      @graduate_pages = paginate :graduates, :conditions => "member_id = #{params[:id]}", :order => 'rank_id'
      @graduates = Graduate.find(:all, :conditions => "member_id = #{params[:id]}", :order => 'rank_id')
    end
  end

  def list_graduates
    if params[:id]
      @graduate_pages, @graduates = paginate :graduates, :per_page => MEMBERS_PER_PAGE, :conditions => "graduation_id = #{params[:id]}", :order => "rank_id,passed"
    else
      @graduate_pages = paginate :graduates, :conditions => "member_id > 0", :order => "member_id,rank_id,passed"
      @graduates = Graduate.find(:all, :conditions => "member_id > 0", :order => "member_id,rank_id,passed")
    end
    render :action => 'list'
  end

  def rank_select(ma_id, member_id, row_id)
    rstr = rsel = String.new()
    @mranks = Rank.find(:all, :conditions => "martial_art_id = #{ma_id}")
    rstr << "\n<SELECT STYLE='width: 72px; height: 18px;' NAME='rank_row_#{member_id}' ID='rank_row_#{member_id}'>\n"
    for rank in @mranks
      rsel = row_id == rank.id ? "SELECTED" : "" 
      rstr << "<OPTION #{rsel} VALUE='#{rank.id}'>#{rank.name}</OPTION>\n"
    end
    rstr << "</SELECT>\n"
  end
  
  def yes_no_select(cid, sid, member_id)
    rstr = String.new()
    nsel = !sid ? "SELECTED" : ""
    ysel = sid ? "SELECTED" : ""
    rstr << "\n<SELECT NAME='#{cid}_row_#{member_id}' STYLE='width: 56px; height: 18px;' ID='#{cid}_row_#{member_id}'>\n"
    rstr << "<OPTION #{nsel} VALUE='0'>Nei</OPTION>\n"
    rstr << "<OPTION #{ysel} VALUE='1'>Ja</OPTION>\n"
    rstr << "</SELECT>\n"
  end

  def list_graduations_by_member
    @censors = Censor.find(:all, :conditions => "graduation_id = #{params[:id]}")
    @graduates = Graduate.find(:all, :conditions => ["graduation_id = ? AND member_id != 0", params[:id]],
                               :order => 'rank_id, passed, paid_graduation, paid_belt asc')

    ccnt = 0
    cmax = 4
    rstr =<<EOC
<table width="100%" STYLE="border: 1px solid #000000;" cellspacing="0" cellpadding="0">
  <tr STYLE=" background: #e3e3e3;">
    <th STYLE="text-align: left; border-bottom: 1px solid #000000;" COLSPAN="#{cmax*2}">Sensor</th>
  </tr>
EOC
    for cen in @censors
      mbr = Member.find(:first, :conditions => ["cms_contract_id = ?", cen.member_id])
      nm = "<td width=23%>#{mbr.first_name} #{mbr.last_name}</td>" <<
           "<td width=2%><a href=# onClick='removeCensor(#{cen.id}, " <<
           "\"#{mbr.first_name} #{mbr.last_name}\");'>" <<
           "<IMG SRC=\"/images/button-delete-16x16.png\" STYLE=\"border: 0;\" ALT=\"Slett sensor\"></a></td>\n"
      if ccnt == 0
        rstr << "<tr>" << nm
      elsif ccnt == (cmax - 1)
        rstr << nm << "</tr>\n"
        ccnt = -1
      else
        rstr << nm
      end
      ccnt = ccnt + 1
    end
    if ccnt != (cmax - 1)
      while ccnt < cmax
        rstr << "<td colspan=2>&nbsp;</td>\n"
        ccnt = ccnt + 1
      end
      rstr << "</tr>\n"
    end
    rstr << "</table>\n"
    
    if @censors.size < 1
      rstr = ""
    else
      rstr << "<br>"
    end

    rstr << <<EOH
<table width="100%" STYLE="border: 1px solid #000000;" cellspacing="0" cellpadding="0">
  <tr STYLE=" background: #e3e3e3;">
  <th STYLE="text-align: left; border-bottom: 1px solid #000000;">Medlem</th>
  <th STYLE="border-bottom: 1px solid #000000;">Grad</th>
  <th STYLE="border-bottom: 1px solid #000000;">Bestått</th>
  <th STYLE="border-bottom: 1px solid #000000;">Bet.Grad</th>
  <th STYLE="border-bottom: 1px solid #000000;">Bet.Belte</th>
  <th STYLE="border-bottom: 1px solid #000000;" COLSPAN="4">&nbsp;</th>
</tr>
EOH
    for gr in @graduates
      mbr = Member.find(:first, :conditions => [ "cms_contract_id = ?", gr.member_id])
      rstr = rstr << "<tr id='#{gr.member_id}_#{gr.graduation.id}_view'>\n" <<
                     "  <td>#{mbr.first_name} #{mbr.last_name}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.rank.name}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.passed ? 'Ja' : 'Nei'}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.paid_graduation ? 'Ja' : 'Nei'}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.paid_belt ? 'Ja' : 'Nei'}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\"><A HREF='/graduates/list/" << gr.member_id.to_s << "'>" <<
                     "<IMG SRC=\"/images/button-view-16x16.png\" STYLE=\"border: 0;\" ALT=\"Oversikt\"></A></td>\n" <<
                     "  <td STYLE=\"text-align: center;\"><A HREF='#' onClick='saveGraduateInfo(#{gr.member_id},#{gr.graduation.id})'>" <<
                     "<IMG SRC=\"/images/button-edit-16x16.png\" STYLE=\"border: 0;\" ALT=\"Endre\"></A></td>\n" <<
                     "  <td STYLE=\"text-align: center;\"><A HREF='#' onClick='removeGraduate(#{gr.id},\"#{mbr.first_name} #{mbr.last_name}\")'>" <<
                     "<IMG SRC=\"/images/button-delete-16x16.png\" STYLE=\"border: 0;\" ALT=\"Slett\"></A></td>\n" <<
                     "</tr>\n" 
      rstr = rstr << "<tr id='#{gr.member_id}_#{gr.graduation.id}_edit' STYLE='display: none;'>\n" <<
                     "  <td>#{mbr.first_name} #{mbr.last_name}</td>\n" <<
                     #"  <td STYLE=\"text-align: center;\">#{gr.graduation.held_on}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{rank_select(gr.graduation.martial_art_id,gr.member_id,gr.rank.id)}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{yes_no_select('passed', gr.passed, gr.member_id)}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{yes_no_select('paid_grad', gr.paid_graduation, gr.member_id)}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{yes_no_select('paid_belt', gr.paid_belt, gr.member_id)}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">&nbsp;</td>\n" <<
                     "  <td STYLE=\"text-align: center;\"><A HREF='#' onClick='saveGraduateInfo(#{gr.member_id},#{gr.graduation.id})'>" <<
                     "<IMG SRC=\"/images/button-ok-16x16.png\" STYLE=\"border: 0;\" ALT=\"Lagre\"></A></td>\n" <<
                     "  <td STYLE=\"text-align: center;\"><A HREF='#' onClick='cancelSaveGraduateInfo(#{gr.member_id},#{gr.graduation.id})'>" <<
                     "<IMG SRC=\"/images/button-cancel-16x16.png\" STYLE=\"border: 0;\" ALT=\"Avbryt\"></A></td>\n" <<
                     "</tr>\n" 
    end
    render_text rstr << "</table>\n"
  end

  def list_potential_graduates
    @instructors = Member.find(:all, :conditions => "left_on IS NULL", :order => 'last_name, first_name')
    rstr =<<EOH
    <div style="height:256px; width:350px; overflow:auto; overflow-x:hidden;">
    <table STYLE="height: 128px;" width="100%" CELLPADDING="0" CELLSPACING="0">
      <tr>
        <td STYLE="background: #e3e3e3;border-top: 1px solid #000000;border-bottom: 1px solid #000000;"><B>Medlemmer</B></td>
        <td STYLE="background: #e3e3e3;border-top: 1px solid #000000;border-bottom: 1px solid #000000;" ALIGN="right"><A HREF="#" onClick="hide_glist();">X</A></td>
        <td width=20>&nbsp;</td>
      </td><tr>
EOH
    for instr in @instructors
      rstr = rstr << "<tr>" <<
             "<td align=left><a href='#' onClick='add_graduate(" + instr.cms_contract_id.to_s + ");'>" <<
             instr.last_name << ", " << instr.first_name << "</a></td>" <<
             "<td ALIGN='right'>" << instr.department << "</td>"
             "<td>&nbsp;</td></tr>\n"
    end
    render_text rstr << "</table>\n</div>\n"
  end

  def update_graduate
    member_id = params[:member_id].to_i
    rank_id = params[:rank_id].to_i 
    graduate_id = params[:grad_id].to_i
    passed = params[:passed].to_i 
    paid = params[:paid].to_i
    paid_belt = params[:paid_belt].to_i
    
    begin
      @graduate = Graduate.find(:first, :conditions => [ "graduation_id = ? AND member_id = ?", graduate_id, member_id])
      @graduate.update_attributes!(:rank_id => rank_id, :passed => passed, :paid_graduation => paid,
                                  :paid_belt => paid_belt )
      render_text "Endret graderingsinfo for medlems #{member_id}"
    rescue StandardError
      render_text "Det oppstod en feil ved endring av medlem #{member_id}:<P>" + $! + "</P>"
    end
  end
  
  def show
    @graduate = Graduate.find(params[:id])
  end

  def new
    @graduate = Graduate.new
  end
  
  def add_new_graduate
    gid = params[:graduation_id].to_i
    mid = params[:member_id].to_i
    aid = params[:martial_arts_id].to_i
    
    rank = Rank.find(:first, :conditions => [ "martial_art_id = ?", aid])
    Graduate.create!(:graduation_id => gid, :member_id => mid, :passed => false,
                     :rank_id => rank.id, :paid_graduation => false, :paid_belt => false)
    render_text " " 
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
