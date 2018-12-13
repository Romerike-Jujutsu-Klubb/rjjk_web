# frozen_string_literal: true

require 'prawn/measurement_extensions'

class CurriculumBook < Prawn::Document
  SENSOR_Y = 139
  CENSOR_TITLE_X = 275
  CENSOR_NAME_X = 350
  SIGNATURE_DIMENSIONS = [640, 34].freeze

  def self.pdf(rank)
    new page_size: 'A4', page_layout: :portrait, margin: 0.5.cm do
      page_width = PDF::Core::PageGeometry::SIZES['A4'][1] - 1.cm
      # page_height = PDF::Core::PageGeometry::SIZES['A4'][0] - 1.cm

      text 'Grunnteknikker', size: 18

      rank.basic_techniques.group_by(&:waza).each do |waza, techniques|
        group do |g|
          g.move_down 0.5.cm
          g.text waza.name
          g.move_down 0.5.cm
          techniques.each do |bt|
            g.text bt.name
          end
        end
      end

      start_new_page
      text 'Applikasjoner', size: 18
      rank.technique_applications.group_by(&:system).each do |system, applications|
        move_down 0.5.cm
        text system
        move_down 0.5.cm
        applications.each do |ta|
          text ta.name
        end
      end

      start_new_page
      text 'Applikasjoner', size: 18
      rank.technique_applications.group_by(&:system).each do |system, applications|
        move_down 0.5.cm
        text system
        move_down 0.5.cm
        applications[0..0].each do |ta|
          start_new_page
          text ta.name, size: 30
          ta.application_steps[0..2].each do |as|
            move_down 0.5.cm
            # image as.image.content_data_io, fit: [page_width * 0.45, page_width * 0.45]
            # text_box as.description, width: page_width * 0.45, position: :right
            table([[
              { image: as.image.content_data_io, width: page_width * 0.35,
                fit: [page_width * 0.33, page_width * 0.45] },
              { content: as.description, width: page_width * 0.34 },
            ]], cell_style: { border_width: 0 })
          end
        end
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
