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
    redirect_to :action => :index, :id => nil
  end

  def certificates
    graduation = Graduation.find(params[:id])
    date = graduation.held_on
    content = graduation.graduates.sort_by { |g| -g.rank.position }.map{|g| {:name => g.member.name, :rank => "#{g.rank.name} #{g.rank.colour}", :group => g.rank.group.name}}
    filename   = "Certificates_#{graduation.martial_art.name}_#{graduation.held_on}.pdf"
    send_data certificates_pdf(date, content), :type => "text/pdf", :filename => filename, :disposition => 'attachment'
  end

  def birthday_certificates
    date     = Date.parse('2012-06-17')
    content  = ['Oskar Flesland', 'Peter Flesland', 'Jørgen Daland Bjørnsen', 'Ulvar Jensen Fresvig', 'Nicolai Hagen',
                'Ismael Iturrieta-Ismail', 'Leander Mathisen', 'Jesper Skogly', 'Selmer Solland', 'Oskar Strand',
                'Benjamin westby', 'Haben'].map do |n|
      {
          :name    => n, :rank => "Innføring i Jujutsu", :group => "",
          :censor1 => {:title => 'Sensei', :name => 'Uwe Kubosch'},
          :censor2 => {:title => 'Sempai', :name => 'Tuan Le'},
          :censor3 => {:title => 'Sempai', :name => 'Svein Robert Rolijordet'},
      }
    end
    filename = "Certificates_birthday_#{date}.pdf"
    send_data certificates_pdf(date, content), :type => "text/pdf", :filename => filename, :disposition => 'attachment'
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
    @graduation = Graduation.includes(:martial_art => {:ranks => :group}).find(params[:id])
    @censors    = Censor.includes(:member).where(:graduation_id => @graduation.id).all
    @graduates  = Graduate.where("graduates.graduation_id = ? AND graduates.member_id != 0", params[:id]).
        #includes({:graduation => :martial_art}, {:member => [{:attendances => :group_schedule}, {:graduates => [:graduation, :rank]}]}, {:rank => :group}).
        includes({:graduation => :martial_art}, :member, {:rank => :group}).
        #order('ranks_graduates.position DESC, members.first_name, members.last_name').all
        order('ranks.position DESC, members.first_name, members.last_name').all
  end

  def certificates_pdf(date, content)
    Prawn::Document.new :page_size => 'A4', :page_layout => :landscape, :margin    => 0 do
      page_width = Prawn::Document::PageGeometry::SIZES["A4"][1]
      page_height = Prawn::Document::PageGeometry::SIZES["A4"][0]
      name_width = 440
      create_stamp('border') do
        rotate 0.5 do
        image "#{Rails::root}/app/views/graduations/Sertifikat_Kei_Wa_Ryu.jpg",
              :at     => [1, page_height - 4],
              :width  => page_width,
              :height => page_height,
        end
        logo_width = 120

        fill_color "ffffff"
        fill_rectangle [(page_width - logo_width) / 2 - 5, page_height], logo_width + 5, logo_width
        fill_color "000000"

        image "#{Rails::root}/app/views/graduations/logo_RJJK_notext.jpg",
              :at     => [(page_width - logo_width) / 2, page_height - 5],
              :width  => logo_width

        name_y = 455

        fill_color "ffffff"
        fill_rectangle [90, name_y], 100, 40
        fill_color "000000"

        bounding_box [90, name_y - 4.5], :width => 100, :height => 40 do
          font 'Helvetica'
          text 'Norges Kampsportforbund', :align => :center
        end

        fill_color "ffffff"
        name_width = 440
        fill_rectangle [(page_width - name_width) / 2, name_y], name_width, 40
        fill_color "000000"

        bounding_box [(page_width - name_width) / 2, name_y], :width => name_width, :height => 40 do
          fill_color "E20816"
          stroke_color "000000"
          font 'Times-Roman'
          text 'Romerike Jujutsu Klubb', :align => :center, :size => 40, :mode => :fill_stroke, :character_spacing => 1
        end

        fill_color "ffffff"
        fill_rectangle [page_width - 90 - 100, name_y], 100, 40
        fill_color "000000"

        bounding_box [page_width - 90 - 100, name_y - 4.5], :width => 100, :height => 40 do
          font 'Helvetica'
          text 'Scandinavian Budo Association', :align => :center
        end

        fill_color "ffffff"
        fill_rectangle [(page_width - name_width) / 2, 410], name_width, 70
        fill_color "000000"

        bounding_box [(page_width - name_width) / 2, 397], :width => name_width, :height => 60 do
          # fill_color "E20816"
          # stroke_color "000000"
          font 'Times-Roman', :style => :italic
          text 'Sertifikat', :align => :center, :size => 54, :mode => :fill_stroke, :character_spacing => 2
        end

        #bounding_box [670, 370], :width => 60, :height => 280 do
        #  stroke_bounds
        #  fill_color "000000"
        #  stroke_color "000000"
        #  font 'Times-Roman'
        #  font("#{Rails.root}/app/views/graduations/japanese.ttf") do
        #    text '啓 和 流 柔 術', :align => :center, :size => 36
        #  end
        #end

        fill_color "ffffff"
        fill_rectangle [(page_width - name_width) / 2, 327], name_width, 40
        fill_color "000000"

        bounding_box [(page_width - name_width) / 2, 327], :width => name_width, :height => 40 do
          fill_color "E20816"
          stroke_color "000000"
          font 'Times-Roman'
          text 'Kei Wa Ryu', :align => :center, :size => 36, :mode => :fill_stroke, :character_spacing => 1
        end

      end
      stamp 'border'
      content.each do |c|
        labels_x = 143

        fill_color "ffffff"
        fill_rectangle [95, 255], 55, 140
        fill_color "000000"

        font 'Helvetica'
        name_y = 250
        bounding_box [labels_x, name_y], :width => 80, :height => 20 do
          text 'Navn', :size => 18, :align => :center, :style => :italic
        end
        bounding_box [(page_width - name_width) / 2, name_y], :width => name_width, :height => 20 do
          text c[:name], :size => 18, :align => :center, :valign => :bottom
        end
        move_down 17
        rank_y = cursor
        bounding_box [labels_x, rank_y], :width => 80, :height => 20 do
          text 'Grad', :size => 18, :align => :center, :style => :italic
        end
        bounding_box [(page_width - name_width) / 2, rank_y], :width => name_width, :height => 20 do
          text c[:rank], :size => 18, :align => :center
        end
        move_down 17
        date_y = cursor
        bounding_box [labels_x, date_y], :width => 80, :height => 20 do
          text 'Dato', :size => 18, :align => :center, :style => :italic
        end
        bounding_box [(page_width - name_width) / 2, date_y], :width => name_width, :height => 20 do
          text "#{date.day}. #{I18n.t(Date::MONTHNAMES[date.month]).downcase} #{date.year}", :size => 18, :align => :center
        end
        move_down 17
        sensor_y = cursor
        bounding_box [labels_x, sensor_y], :width => 80, :height => 20 do
          text 'Sensor', :size => 18, :align => :center, :style => :italic
        end
        title_x = 275
        name_x = 350
        if c[:censor1]
          text_box c[:censor1][:title], :at => [title_x, sensor_y], :size => 18, :align => :left
          text_box c[:censor1][:name],  :at => [name_x, sensor_y], :size => 18, :align => :left
        end
        if c[:censor2]
          text_box c[:censor2][:title], :at => [title_x, sensor_y - 35], :size => 18, :align => :left
          text_box c[:censor2][:name],  :at => [name_x, sensor_y - 35], :size => 18, :align => :left
        end
        if c[:censor3]
          text_box c[:censor3][:title], :at => [title_x, sensor_y - 60], :size => 18, :align => :left
          text_box c[:censor3][:name],  :at => [name_x, sensor_y - 60], :size => 18, :align => :left
        end
        unless c[:group] == 'Grizzly'
          draw_text c[:group], :at => [120 + 36, 300 + 36], :size => 18
        end
        start_new_page
        stamp 'border'
      end
    end.render
  end

end
