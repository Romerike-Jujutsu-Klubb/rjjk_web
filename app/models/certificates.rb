class Certificates
  def self.pdf(date, content)
    Prawn::Document.new :page_size => 'A4', :page_layout => :landscape, :margin => 0 do
      page_width = Prawn::Document::PageGeometry::SIZES['A4'][1]
      page_height = Prawn::Document::PageGeometry::SIZES['A4'][0]
      name_width = 440
      labels_x = 143
      graduate_name_y = 250
      rank_y = 213
      date_y = 176
      sensor_y = 139

      create_stamp('border') do
        if false # old design
          rotate 0.5 do
            image "#{Rails::root}/app/views/graduations/Sertifikat_Kei_Wa_Ryu.jpg",
                  :at => [1, page_height - 4],
                  :width => page_width,
                  :height => page_height
          end
          logo_width = 120

          fill_color 'ffffff'
          fill_rectangle [(page_width - logo_width) / 2 - 5, page_height], logo_width + 5, logo_width
          fill_color '000000'

          image "#{Rails::root}/app/views/graduations/logo_RJJK_notext.jpg",
                :at => [(page_width - logo_width) / 2, page_height - 5],
                :width => logo_width
        else
          scale = -0.05
          image "#{Rails::root}/app/views/graduations/Style_of_Phoenix_border_A4_Landscape.jpg",
                :at => [page_height * (0 - scale / 1.44), page_height * (1 + scale / 2)],
                :width => page_width * (1 + scale),
                :height => page_height * (1 + scale)
          logo_width = 85 * (1 + scale)

          image "#{Rails::root}/app/views/graduations/logo_RJJK_notext.jpg",
                :at => [(page_width - logo_width) / 2, page_height - 5],
                :width => logo_width
        end
        name_y = 455

        fill_color 'ffffff'
        fill_rectangle [90, name_y], 100, 40
        fill_color '000000'

        bounding_box [90, name_y - 4.5], :width => 100, :height => 40 do
          font 'Helvetica'
          text 'Norges Kampsportforbund', :align => :center
        end

        fill_color 'ffffff'
        name_width = 440
        fill_rectangle [(page_width - name_width) / 2, name_y], name_width, 40
        fill_color '000000'

        bounding_box [(page_width - name_width) / 2, name_y], :width => name_width, :height => 40 do
          fill_color 'E20816'
          stroke_color '000000'
          font 'Times-Roman'
          text 'Romerike Jujutsu Klubb', :align => :center, :size => 40, :mode => :fill_stroke, :character_spacing => 1
        end

        fill_color 'ffffff'
        fill_rectangle [page_width - 90 - 100, name_y], 100, 40
        fill_color '000000'

        bounding_box [page_width - 90 - 100, name_y - 4.5], :width => 100, :height => 40 do
          font 'Helvetica'
          text 'Scandinavian Budo Association', :align => :center
        end

        fill_color 'ffffff'
        fill_rectangle [(page_width - name_width) / 2, 410], name_width, 70
        fill_color '000000'

        bounding_box [(page_width - name_width) / 2, 397], :width => name_width, :height => 60 do
          font 'Times-Roman', :style => :italic
          text 'Sertifikat', :align => :center, :size => 54, :mode => :fill_stroke, :character_spacing => 2
        end

        fill_color 'ffffff'
        fill_rectangle [(page_width - name_width) / 2, 327], name_width, 40
        fill_color '000000'

        bounding_box [(page_width - name_width) / 2, 327], :width => name_width, :height => 40 do
          fill_color 'E20816'
          stroke_color '000000'
          font 'Times-Roman'
          text 'Kei Wa Ryu', :align => :center, :size => 36, :mode => :fill_stroke, :character_spacing => 1
        end

        # Mask old labels
        fill_color 'ffffff'
        fill_rectangle [95, 255], 55, 140
        fill_color '000000'

        font 'Helvetica'
        bounding_box [labels_x, graduate_name_y], :width => 80, :height => 20 do
          text 'Navn', :size => 18, :align => :center, :style => :italic
        end
        bounding_box [labels_x, rank_y], :width => 80, :height => 20 do
          text 'Grad', :size => 18, :align => :center, :style => :italic
        end
        bounding_box [labels_x, date_y], :width => 80, :height => 20 do
          text 'Dato', :size => 18, :align => :center, :style => :italic
        end
        bounding_box [labels_x, sensor_y], :width => 80, :height => 20 do
          text 'Sensor', :size => 18, :align => :center, :style => :italic
        end
      end
      stamp 'border'
      content.each do |c|
        bounding_box [(page_width - name_width) / 2, graduate_name_y], :width => name_width, :height => 20 do
          text c[:name], :size => 18, :align => :center, :valign => :bottom
        end
        bounding_box [(page_width - name_width) / 2, rank_y], :width => name_width, :height => 20 do
          text c[:rank], :size => 18, :align => :center
        end
        bounding_box [(page_width - name_width) / 2, date_y], :width => name_width, :height => 20 do
          text "#{date.day}. #{I18n.t(Date::MONTHNAMES[date.month]).downcase} #{date.year}", :size => 18, :align => :center
        end
        censor_title_x = 275
        censor_name_x = 350
        if c[:censor1]
          text_box c[:censor1][:title], :at => [censor_title_x, sensor_y], :size => 18, :align => :left
          if c[:censor1][:signature]
            image StringIO.new(c[:censor1][:signature]),
                  :at => [censor_name_x, sensor_y + 18], :fit => [640, 34]
          else
            text_box c[:censor1][:name], :at => [censor_name_x, sensor_y], :size => 18, :align => :left
          end
        end
        if c[:censor2]
          text_box c[:censor2][:title], :at => [censor_title_x, sensor_y - 35], :size => 18, :align => :left
          text_box c[:censor2][:name], :at => [censor_name_x, sensor_y - 35], :size => 18, :align => :left
        end
        if c[:censor3]
          text_box c[:censor3][:title], :at => [censor_title_x, sensor_y - 60], :size => 18, :align => :left
          text_box c[:censor3][:name], :at => [censor_name_x, sensor_y - 60], :size => 18, :align => :left
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
