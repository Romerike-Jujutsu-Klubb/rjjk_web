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
    @graduation = Graduation.find(params[:id]) if params[:id]
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method      => :post, :only => [:destroy, :create, :update],
         :redirect_to => {:action => :list}

  def list
    @graduations  = Graduation.find(:all, :order => 'held_on DESC', :conditions => ["martial_art_id = 1"])
    @martial_arts = MartialArt.find(:all)

    @grad_pages, @grad = Hash.new()
    @martial_arts.collect { |c|
      tmp = Graduation.find(:all, :order => 'held_on DESC', :conditions => ["martial_art_id = #{c.id}"])
    }
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
      redirect_to :action => 'list'
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
        unless graduate.member.groups[0].name == 'Grizzly'
          draw_text graduate.member.groups[0].name, :at => [120, 300], :size => 18
        end
        start_new_page :template => template
      end
    end

    send_data pdf.render, :type => "text/pdf", :filename => filename, :disposition => 'attachment'
  end

end
