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
    @graduation = Graduation.find(params[:id])
    @graduations  = Graduation.all(:order => 'held_on DESC', :conditions => ["martial_art_id = 1"])
    @martial_arts = MartialArt.all

    @grad_pages, @grad = Hash.new()
    @martial_arts.collect { |c|
      tmp = Graduation.all(:order => 'held_on DESC', :conditions => ["martial_art_id = #{c.id}"])
    }
    load_graduates
  end

  def show
    @graduation = Graduation.find(params[:id])
  end

  def new
    @graduation = Graduation.new
  end

  def create
    @graduation = Graduation.new(params[:graduation])
    if @graduation.save
      flash[:notice] = 'Graduation was successfully created.'
      redirect_to :action => :index
    else
      render :action => 'new'
    end
  end

  def edit
    @graduation = Graduation.find(params[:id])
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
    redirect_to :action => 'list'
  end

  def certificates
    graduation = Graduation.find(params[:id])
    template   = "#{Rails::root.to_s}/app/views/graduations/Sertifikat_Kei_Wa_Ryu.pdf"
    filename   = "Certificates_#{graduation.martial_art.name}_#{graduation.held_on}.pdf"

    pdf = Prawn::Document.new :template => template do
      date = graduation.held_on
      graduation.graduates.sort_by{|g| -g.rank.position}.each do |graduate|
        move_down 300
        text graduate.member.name, :size => 18, :align => :center
        move_down 16
        text "#{graduate.rank.name} #{graduate.rank.colour}", :size => 18, :align => :center
        move_down 16
        text "#{date.day}. #{I18n.t(Date::MONTHNAMES[date.month]).downcase} #{date.year}", :size => 18, :align => :center
        unless graduate.rank.group.name == 'Grizzly'
          draw_text graduate.rank.group.name, :at => [120, 300], :size => 18
        end
        start_new_page :template => template
      end
    end

    send_data pdf.render, :type => "text/pdf", :filename => filename, :disposition => 'attachment'
  end

  def list_graduates
    load_graduates
    render :partial => 'list_graduates'
  end

  private

  def load_graduates
    @graduation = Graduation.find(params[:id])
    @censors   = Censor.all(:conditions => "graduation_id = #{@graduation.id}")
    @graduates = Graduate.all(:conditions => ["graduation_id = ? AND member_id != 0", params[:id]],
                               :order            => 'ranks.position DESC, members.first_name, members.last_name',
                               :include          => [:graduation, :member, :rank])
  end

end
