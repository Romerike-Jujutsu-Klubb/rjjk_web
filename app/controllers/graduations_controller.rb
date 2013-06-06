# encoding: UTF-8
class GraduationsController < ApplicationController
  MEMBERS_PER_PAGE = 30

  before_filter :admin_required

  def import
    @imported, @unknown = GraduationsImport.import
    STDERR.puts @imported.size
    lines = String.new()
    @imported.each { |k, v|
      v.each { |x, y|
        lines << k.to_s << " " << x << " " << y << "<br>"
      }
    }
    render :text => lines
  end

  def index
    if params[:id].blank?
      redirect_to(:id => Graduation.last(:order => :held_on))
      return
    end
    @graduation   = Graduation.find(params[:id])
    @graduations  = Graduation.includes(:group).all(:order => 'held_on DESC', :conditions => ["groups.martial_art_id = 1"])
    @martial_arts = MartialArt.all

    @grad_pages, @grad = Hash.new()
    load_graduates
  end

  def show
    @graduation = Graduation.find(params[:id])
  end

  def new
    @graduation ||= Graduation.new
    @groups = Group.all
  end

  def create
    @graduation = Graduation.new(params[:graduation])
    if @graduation.save
      flash[:notice] = 'Graduation was successfully created.'
      redirect_to :action => :index
    else
      new
      render :action => 'new'
    end
  end

  def edit
    @graduation = Graduation.find(params[:id])
    @groups = Group.all
  end

  def update
    @graduation = Graduation.find(params[:id])
    if @graduation.update_attributes(params[:graduation])
      flash[:notice] = 'Graduation was successfully updated.'
      redirect_to :action => 'show', :id => @graduation
    else
      render :action => 'edit'
    end
  end

  def destroy
    Graduation.find(params[:id]).destroy
    redirect_to :action => :index, :id => nil
  end

  def certificates
    graduation = Graduation.find(params[:id])
    date = graduation.held_on
    content = graduation.graduates.sort_by { |g| -g.rank.position }.map{|g| {:name => g.member.name, :rank => "#{g.rank.name} #{g.rank.colour}", :group => g.rank.group.name}}
    filename   = "Certificates_#{graduation.group.martial_art.name}_#{graduation.held_on}.pdf"
    send_data Certificates.pdf(date, content), :type => 'text/pdf',
              :filename => filename, :disposition => 'attachment'
  end

  def list_graduates
    load_graduates
    render :partial => 'list_graduates'
  end

  def censor_form
    @graduation = Graduation.includes(:graduates => [:member, :rank]).find params[:id]
    render :layout => 'print'
  end

  def censor_form_pdf
    graduation = Graduation.find(params[:id])
    filename   = "Sensorskjema_#{graduation.held_on}.pdf"

    pdf = Prawn::Document.new do
      date = graduation.held_on
      text "Gradering #{date.day}. #{I18n.t(Date::MONTHNAMES[date.month]).downcase} #{date.year}",
           :size => 18, :align => :center
      move_down 16
      data = graduation.graduates.sort_by { |g| [-g.rank.position, g.member.name] }.map.with_index do |graduate, i|
        member_current_rank = graduate.member.current_rank(graduate.graduation.martial_art, graduate.graduation.held_on)
        [
            "<font size='18'>" + graduate.member.first_name + '</font> ' + graduate.member.last_name + (graduate.member.birthdate && " (#{graduate.member.age} år)" || '') + "\n" +
                (member_current_rank && "#{member_current_rank.name} #{member_current_rank.colour}" || 'Ugradert') + "\n" +
                "Treninger: #{graduate.member.attendances_since_graduation(graduation.held_on).count}" + ' (' + graduate.current_rank_age + ")\n" +
                "#{graduate.rank.name} #{graduate.rank.colour}",
            '',
            '',
        ]
      end
      table([['Utøver', 'Bra', 'Kan bli bedre']] + data, :header => true, :cell_style => {:inline_format => true, :width => 180, :padding => 8})
      start_new_page
    end

    send_data pdf.render, :type => "text/pdf", :filename => filename, :disposition => 'attachment'
  end

  private

  def load_graduates

    @graduation = Graduation.includes(:group => {:martial_art => {:ranks => :group}}).find(params[:id])

    @censors    = Censor.includes(:member).where(:graduation_id => @graduation.id).all

    @graduates  = Graduate.where("graduates.graduation_id = ? AND graduates.member_id != 0", params[:id]).
        #includes({:graduation => :martial_art}, {:member => [{:attendances => :group_schedule}, {:graduates => [:graduation, :rank]}]}, {:rank => :group}).
        includes({:graduation => {:group => :martial_art}}, :member, {:rank => :group}).
        #order('ranks_graduates.position DESC, members.first_name, members.last_name').all
        order('ranks.position DESC, members.first_name, members.last_name').all
  end

end
