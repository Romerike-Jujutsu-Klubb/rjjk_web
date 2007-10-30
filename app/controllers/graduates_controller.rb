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
      @graduate_pages, @graduates = paginate :graduates, :per_page => MEMBERS_PER_PAGE
    else
      @graduate_pages, @graduates = paginate :graduates, :per_page => MEMBERS_PER_PAGE, :conditions => "member_id = #{params[:id]}", :order => 'rank_id'
    end
  end

  def list_graduates
    @graduate_pages, @graduates = paginate :graduates, :conditions => "graduation_id = #{params[:id]}"                              
    render :action => 'list'
  end
  
  def list_graduations_by_member
    @graduates = Graduate.find(:all, :conditions => "graduation_id = #{params[:id]}")
    rstr =<<EOH
<table width="100%" STYLE="border: 1px solid #000000;" cellspacing="0" cellpadding="0">
  <tr STYLE=" background: #e3e3e3;">
  <th STYLE="text-align: left; border-bottom: 1px solid #000000;">Medlem</th>
  <th STYLE="border-bottom: 1px solid #000000;">Dato</th>
  <th STYLE="border-bottom: 1px solid #000000;">Grad</th>
  <th STYLE="border-bottom: 1px solid #000000;">Bestått</th>
  <th STYLE="border-bottom: 1px solid #000000;">Bet.Grad</th>
  <th STYLE="border-bottom: 1px solid #000000;">Bet.Belte</th>
  <th STYLE="border-bottom: 1px solid #000000;" COLSPAN="2">&nbsp;</th>
</tr>
EOH

    for gr in @graduates
      rstr = rstr << "<tr>\n" <<
                     "  <td>#{gr.member.first_name} #{gr.member.last_name}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.graduation.held_on}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.rank.name}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.passed ? 'Ja' : 'Nei'}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.paid_graduation ? 'Ja' : 'Nei'}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\">#{gr.paid_belt ? 'Ja' : 'Nei'}</td>\n" <<
                     "  <td STYLE=\"text-align: center;\"><A HREF='/graduates/list/" << gr.member.id.to_s << "'>Graderingsoversikt</A></td>\n" <<
                     "</tr>\n" 
    end
    render_text rstr << "</table>\n"
  end

  def show
    @graduate = Graduate.find(params[:id])
  end

  def new
    @graduate = Graduate.new
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
