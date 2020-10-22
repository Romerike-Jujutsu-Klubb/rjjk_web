# frozen_string_literal: true

require 'prawn/measurement_extensions'

class SkillCard
  FONT_SIZE = 9.0
  MARGIN = 1.0.cm
  PAGE_SIZE = 'A4'
  PAGE_WIDTH = PDF::Core::PageGeometry::SIZES['A4'][0]
  PAGE_HEIGHT = PDF::Core::PageGeometry::SIZES['A4'][1]

  def self.pdf(ranks)
    Prawn::Document.new page_size: PAGE_SIZE, top_margin: MARGIN,
                        bottom_margin: MARGIN, left_margin: MARGIN, right_margin: MARGIN do
      logo_width = 180
      create_stamp('watermark') do
        float do
          transparent(0.05) do
            image "#{Rails.root}/app/views/certificates/logo_RJJK_notext.jpg",
                width: logo_width, position: :center, vposition: :center
          end
        end
      end
      repeat(:all) { stamp 'watermark' }

      add_front_page = ranks.size > 2

      if add_front_page
        bounding_box [0, 2 * PAGE_HEIGHT / 3], width: PAGE_WIDTH, height: PAGE_HEIGHT / 6 do
          font 'Times-Roman', style: :italic do
            text "Ferdighetskort til #{ranks.last}", align: :center, size: 40, mode: :fill_stroke,
                character_spacing: 2
          end
        end
        image "#{Rails.root}/app/views/certificates/logo_RJJK_notext.jpg",
            width: logo_width, position: :center, vposition: :center
      end

      ranks.each do |rank|
        start_new_page unless rank == ranks[0] && !add_front_page
        if rank.basic_techniques.any?
          rows = [['', "Grunnteknikker #{rank.name}".upcase, 'G', 'F', 'A', 'I']]

          rank.basic_techniques.group_by { |bt| bt.waza.name }.each do |waza_name, techs|
            rows << [{ content: waza_name.upcase, rowspan: techs.size, rotate: 90 },
                     techs[0].name.upcase, nil, nil, nil, nil]
            rows += techs[1..].sort_by(&:name).map do |bt|
              [bt.name.upcase, nil, nil, nil, nil]
            end
          end
          bt_table = make_table(rows,
              width: bounds.width, header: true, cell_style: { size: FONT_SIZE },
              row_colors: %w[F8F8F8 FFFFFF], column_widths: { 0 => 20, 2..-1 => 20 }) do
            row(0).font_style = :bold
            columns(2..-1).align = :center
          end
          move_down(FONT_SIZE) if cursor < bounds.height
          bt_table.draw
        end

        next unless rank.technique_applications.any?

        rows = [['', "Applikasjoner #{rank.name}".upcase, 'G', 'F', 'A', 'I']]
        rank.technique_applications.sort_by(&:position).group_by(&:system).each do |system_name, apps|
          apps.each_slice(14) do |app_slice|
            rows << [
              { content: system_name.upcase, rowspan: app_slice.size, rotate: 90 },
              app_slice[0].name.upcase, nil, nil, nil, nil
            ]
            rows += app_slice[1..].map { |ta| [ta.name.upcase, nil, nil, nil, nil] }
          end
        end

        app_table = make_table(rows, width: bounds.width, header: true,
                                     cell_style: { size: FONT_SIZE }, row_colors: %w[F8F8F8 FFFFFF],
                                     column_widths: { 0 => 20, 2..-1 => 20 }) do
          row(0).font_style = :bold
          columns(2..-1).align = :center
        end

        move_down(FONT_SIZE) if cursor < bounds.height
        app_table.draw
      end
    end.render
  end
end
