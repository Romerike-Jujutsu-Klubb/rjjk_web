# frozen_string_literal: true

class Certificates < Prawn::Document
  include ApplicationHelper

  SENSOR_Y = 139
  CENSOR_TITLE_X = 275
  CENSOR_NAME_X = 350
  SIGNATURE_DIMENSIONS = [640, 34].freeze
  PAGE_WIDTH = PDF::Core::PageGeometry::SIZES['A4'][1]
  PAGE_HEIGHT = PDF::Core::PageGeometry::SIZES['A4'][0]

  def self.pdf(date, content, layout = 3)
    new page_size: 'A4', page_layout: :landscape, margin: 0 do
      org_name_width = 100
      name_width = 430
      org_right_center = PAGE_WIDTH - 140
      labels_x = 143
      graduate_name_y = 250
      rank_y = 213
      date_y = 176

      create_stamp('border') do
        case layout
        when 1
          rotate 0.5 do
            image "#{Rails.root}/app/views/certificates/Sertifikat_Kei_Wa_Ryu.jpg",
                at: [1, PAGE_HEIGHT - 4],
                width: PAGE_WIDTH,
                height: PAGE_HEIGHT
          end
          logo_width = 120

          fill_color 'ffffff'
          fill_rectangle [(PAGE_WIDTH - logo_width) / 2 - 5, PAGE_HEIGHT - 1], logo_width + 5,
              logo_width
          fill_color '000000'

          image "#{Rails.root}/app/views/certificates/logo_RJJK_notext.jpg",
              at: [(PAGE_WIDTH - logo_width) / 2, PAGE_HEIGHT - 5],
              width: logo_width
          # Mask old labels
          fill_color 'ffffff'
          fill_rectangle [95, 255], 55, 140
          fill_rectangle [CENSOR_TITLE_X - 10, graduate_name_y],
              PAGE_WIDTH - CENSOR_TITLE_X * 2 + 25,
              graduate_name_y - SENSOR_Y + 60
          fill_color '000000'
        when 2
          scale = -0.05
          image "#{Rails.root}/app/views/certificates/Style_of_Phoenix_border_A4_Landscape.jpg",
              at: [PAGE_WIDTH * (0 - scale) - 1, PAGE_HEIGHT * (1 + scale / 2) - 1],
              width: PAGE_WIDTH * (1 + scale),
              height: PAGE_HEIGHT * (1 + scale)
          logo_width = 85 * (1 + scale)

          image "#{Rails.root}/app/views/certificates/logo_RJJK_notext.jpg",
              at: [(PAGE_WIDTH - logo_width) / 2, PAGE_HEIGHT - 5],
              width: logo_width
        when 3
          scale = -0.025
          logo_width = 120
          image "#{Rails.root}/app/views/certificates/logo_RJJK_notext.jpg",
              at: [(PAGE_WIDTH - logo_width) / 2 - 2, PAGE_HEIGHT - 1],
              width: logo_width
          image "#{Rails.root}/app/views/certificates/custome_rank_certificate.png",
              at: [0, PAGE_HEIGHT * (1 + scale) - 1],
              width: PAGE_WIDTH,
              height: PAGE_HEIGHT * (1 + scale)
          kanji_scale = 2.5
          kanji_width = 126 / kanji_scale
          kanji_height = 674 / kanji_scale
          image "#{Rails.root}/app/views/certificates/KeiWaRyuKanji.png",
              at: [org_right_center - kanji_width / 2, (PAGE_HEIGHT * 0.4) + kanji_height / 2],
              width: kanji_width, height: kanji_height
        end
        name_y = 455

        fill_color 'ffffff'
        fill_rectangle [90, name_y], org_name_width, 40
        fill_color '000000'

        bounding_box [90, name_y - 4.5], width: org_name_width, height: 40 do
          font 'Helvetica'
          text 'Norges Kampsportforbund', align: :center
        end

        fill_color 'ffffff'
        fill_rectangle [(PAGE_WIDTH - name_width) / 2, name_y], name_width, 40
        fill_color '000000'

        bounding_box [(PAGE_WIDTH - name_width) / 2, name_y], width: name_width, height: 40 do
          fill_color 'E20816'
          stroke_color '000000'
          font 'Times-Roman'
          text 'Romerike Jujutsu Klubb', align: :center, size: 40, mode: :fill_stroke,
                                         character_spacing: 1
        end

        fill_color 'ffffff'
        fill_rectangle [org_right_center - org_name_width / 2, name_y], org_name_width, 40
        fill_color '000000'

        bounding_box [org_right_center - org_name_width / 2, name_y - 4.5],
            width: org_name_width, height: 40 do
          font 'Helvetica'
          text 'International Bujutsu University', align: :center
        end

        fill_color 'ffffff'
        fill_rectangle [(PAGE_WIDTH - name_width) / 2, 410], name_width, 70
        fill_color '000000'

        bounding_box [(PAGE_WIDTH - name_width) / 2, 397], width: name_width, height: 60 do
          font 'Times-Roman', style: :italic
          text 'Sertifikat', align: :center, size: 54, mode: :fill_stroke, character_spacing: 2
        end

        fill_color 'ffffff'
        fill_rectangle [(PAGE_WIDTH - name_width) / 2, 327], name_width, 40
        fill_color '000000'

        bounding_box [(PAGE_WIDTH - name_width) / 2, 327], width: name_width, height: 40 do
          fill_color 'E20816'
          stroke_color '000000'
          font 'Times-Roman'
          text 'Kei Wa Ryu', align: :center, size: 36, mode: :fill_stroke, character_spacing: 1
        end

        font 'Helvetica'
        fill_color '000000'
        bounding_box [labels_x, graduate_name_y], width: 80, height: 20 do
          text 'Navn', size: 18, align: :center, style: :italic
        end
        stroke do
          line [CENSOR_TITLE_X, graduate_name_y - 18],
              [PAGE_WIDTH - CENSOR_TITLE_X, graduate_name_y - 18]
        end

        bounding_box [labels_x, rank_y], width: 80, height: 20 do
          text 'Grad', size: 18, align: :center, style: :italic
        end
        stroke { line [CENSOR_TITLE_X, rank_y - 18], [PAGE_WIDTH - CENSOR_TITLE_X, rank_y - 18] }

        bounding_box [labels_x, date_y], width: 80, height: 20 do
          text 'Dato', size: 18, align: :center, style: :italic
        end
        stroke { line [CENSOR_TITLE_X, date_y - 18], [PAGE_WIDTH - CENSOR_TITLE_X, date_y - 18] }

        bounding_box [labels_x, SENSOR_Y], width: 80, height: 20 do
          text 'Sensor', size: 18, align: :center, style: :italic
        end
        stroke do
          line [CENSOR_TITLE_X, SENSOR_Y - 18], [PAGE_WIDTH - CENSOR_TITLE_X, SENSOR_Y - 18]
        end
        stroke do
          line [CENSOR_TITLE_X, SENSOR_Y - 53], [PAGE_WIDTH - CENSOR_TITLE_X, SENSOR_Y - 53]
        end
      end
      stamp 'border'
      content.each do |c|
        bounding_box [(PAGE_WIDTH - name_width) / 2, graduate_name_y], width: name_width, height: 20 do
          text c[:name], size: 18, align: :center, valign: :bottom
        end
        bounding_box [(PAGE_WIDTH - name_width) / 2, rank_y], width: name_width, height: 20 do
          text c[:rank], size: 18, align: :center
        end
        bounding_box [(PAGE_WIDTH - name_width) / 2, date_y], width: name_width, height: 20 do
          text "#{date.day}. #{month_name(date.month)} #{date.year}",
              size: 18, align: :center
        end
        write_censor(c[:censor1], 0)
        write_censor(c[:censor2], 35)
        write_censor(c[:censor3], 65, 8)
        draw_text c[:group], at: [120 + 36, 300 + 36], size: 18 unless c[:group] == 'Grizzly'
        start_new_page
        stamp 'border'
      end
    end.render
  end

  private

  def write_censor(sensor, offset, signature_offset = 0)
    return unless sensor

    text_box sensor[:title], at: [CENSOR_TITLE_X, SENSOR_Y - offset], size: 18, align: :left
    if sensor[:signature]
      image StringIO.new(sensor[:signature]),
          fit: SIGNATURE_DIMENSIONS, at: [CENSOR_NAME_X, SENSOR_Y + 18 - offset - signature_offset]
    else
      text_box sensor[:name], at: [CENSOR_NAME_X, SENSOR_Y - offset], size: 18, align: :left
    end
  end
end
