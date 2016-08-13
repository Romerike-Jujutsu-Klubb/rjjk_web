require 'prawn/measurement_extensions'

class SkillCard
  FONT_SIZE = 9.0
  MARGIN = 1.0.cm
  PAGE_SIZE = 'A6'

  def self.pdf(ranks)
    Prawn::Document.new page_size: PAGE_SIZE, top_margin: MARGIN,
        bottom_margin: MARGIN, left_margin: MARGIN, right_margin: MARGIN do

      create_stamp('watermark') do
        logo_width = 180
        float do
          transparent(0.05) do
            image "#{Rails.root}/app/views/graduations/logo_RJJK_notext.jpg",
                :width => logo_width, :position => :center, :vposition => :center
          end
        end
      end
      repeat(:all) { stamp 'watermark' }

      ranks.each do |rank|
        if rank.basic_techniques.any?
          rows = [['', "Grunnteknikker #{rank.name}".upcase, 'G', 'F', 'A', 'I']]

          rank.basic_techniques.group_by { |bt| bt.waza.name }.each do |waza_name, techs|
            rows << [{ content: UnicodeUtils.upcase(waza_name), rowspan: techs.size, rotate: 90 },
                UnicodeUtils.upcase(techs[0].name), nil, nil, nil, nil]
            rows += techs[1..-1].sort_by { |bt| bt.name }.map do |bt|
              [UnicodeUtils.upcase(bt.name), nil, nil, nil, nil]
            end
          end
          bt_table = make_table(rows, width: bounds.width, header: true,
              cell_style: { size: FONT_SIZE }, row_colors: %w(F8F8F8 FFFFFF),
              column_widths: { 0 => 20, 2..-1 => 20 },
          ) do
            row(0).font_style = :bold
            columns(2..-1).align = :center
          end
          move_down(FONT_SIZE) if cursor < bounds.height
          bt_table.draw
        end

        if rank.technique_applications.any?
          rows = [['', "Applikasjoner #{rank.name}".upcase, 'G', 'F', 'A', 'I']]
          rank.technique_applications.group_by(&:system).each do |system_name, apps|
            apps.each_slice(14) do |app_slice|
              rows << [{ content: UnicodeUtils.upcase(system_name), rowspan: app_slice.size, rotate: 90 },
                  UnicodeUtils.upcase(app_slice[0].name), nil, nil, nil, nil]
              rows += app_slice[1..-1].sort_by(&:name).map do |ta|
                [UnicodeUtils.upcase(ta.name), nil, nil, nil, nil]
              end
            end
          end

          app_table = make_table(rows, width: bounds.width, header: true,
              cell_style: { size: FONT_SIZE }, row_colors: %w(F8F8F8 FFFFFF),
              column_widths: { 0 => 20, 2..-1 => 20 },
          ) do
            row(0).font_style = :bold
            columns(2..-1).align = :center
          end

          move_down(FONT_SIZE) if cursor < bounds.height
          app_table.draw
        end
      end
    end.render
  end
end
