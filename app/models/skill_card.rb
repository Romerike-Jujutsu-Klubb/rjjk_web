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
            image "#{Rails::root}/app/views/graduations/logo_RJJK_notext.jpg",
                :width => logo_width, :position => :center, :vposition => :center
          end
        end
      end
      repeat(:all) { stamp 'watermark' }

      ranks.each do |rank|
        if rank.basic_techniques.any?
          rows = [['', "Grunnteknikker #{rank.name}".upcase, 'G', 'F', 'A', 'I']]

          rank.basic_techniques.group_by { |bt| bt.waza.name }.each do |waza_name, techs|
            rows << [{content: UnicodeUtils.upcase(waza_name), rowspan: techs.size, rotate: 90},
                UnicodeUtils.upcase(techs[0].name), nil, nil, nil, nil]
            rows += techs[1..-1].sort_by { |bt| bt.name }.map do |bt|
              [UnicodeUtils.upcase(bt.name), nil, nil, nil, nil]
            end
          end
          bt_table = make_table(rows, width: bounds.width, header: true,
              cell_style: {size: FONT_SIZE}, row_colors: %w(F8F8F8 FFFFFF),
              column_widths: {0 => 20, 2..-1 => 20},
          ) do
            row(0).font_style = :bold
            columns(2..-1).align = :center
          end
          start_new_page if cursor < bounds.height
          bt_table.draw
        end

        if rank.applications.any?
          app_table = make_table([["Applikasjoner #{rank.name}".upcase, 'G', 'F', 'A', 'I']] +
              rank.applications.sort_by { |a| ['goho/juho/kata', a.name] }.
                  map { |a| [UnicodeUtils.upcase(a.name), nil, nil, nil, nil] },
              width: bounds.width,
              header: true, cell_style: {size: FONT_SIZE}, row_colors: %w(F8F8F8 FFFFFF),
              column_widths: {1..-1 => 20},
          ) do
            row(0).font_style = :bold
            columns(1..-1).align = :center
          end

          if cursor < bounds.height
            if app_table.height <= bounds.height && cursor - app_table.height < 0
              start_new_page
            else
              move_down FONT_SIZE
            end
          end

          app_table.draw
        end
      end

    end.render
  end

end
