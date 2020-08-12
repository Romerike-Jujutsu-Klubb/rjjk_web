# frozen_string_literal: true

class GraduationCensorForm
  def initialize(graduation)
    @graduation = graduation
  end

  def binary
    pdf.render
  end

  def pdf
    graduation = @graduation
    Prawn::Document.new do
      date = graduation.held_on
      text "Gradering #{date.day}. #{I18n.t(Date::MONTHNAMES[date.month]).downcase} #{date.year}",
          size: 18, align: :center
      move_down 16
      data = graduation.graduates.sort_by { |g| [-g.rank.position, g.member.name] }
          .map do |graduate|
        member = graduate.member
        member_current_rank = member
            .current_rank(graduate.graduation.martial_art, graduate.graduation.held_on)
        rank_color =
            if member_current_rank
              "Fra: #{member_current_rank.name} #{member_current_rank.colour}"
            else
              'Ugradert'
            end
        [
          <<~TXT,
            <font size='18'>#{member.first_name}</font> #{member.last_name}#{(member.birthdate && " (#{member.age} år)" || '')}
            #{rank_color}
            Treninger: #{member.attendances_since_graduation(graduation.held_on).count} (#{graduate.current_rank_age})
            Til: #{graduate.rank.name} #{graduate.rank.colour}
          TXT
          '',
          '',
        ]
      end
      table([['Utøver', 'Bra', 'Kan bli bedre']] + data,
          header: true, cell_style: { inline_format: true, width: 180, padding: 8 })
      start_new_page
    end
  end
end
