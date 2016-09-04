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
      data = graduation.graduates.sort_by { |g| [-g.rank.position, g.member.name] }.map do |graduate|
        member_current_rank = graduate.member.current_rank(graduate.graduation.martial_art, graduate.graduation.held_on)
        [
            "<font size='18'>" + graduate.member.first_name + '</font> ' +
                graduate.member.last_name +
                (graduate.member.birthdate && " (#{graduate.member.age} år)" || '') + "\n" +
                (member_current_rank && "#{member_current_rank.name} #{member_current_rank.colour}" || 'Ugradert') +
                "\n" \
                "Treninger: #{graduate.member.attendances_since_graduation(graduation.held_on).count}" \
                ' (' + graduate.current_rank_age + ")\n" \
                "#{graduate.rank.name} #{graduate.rank.colour}",
            '',
            '',
        ]
      end
      table([['Utøver', 'Bra', 'Kan bli bedre']] + data, header: true,
          cell_style: { inline_format: true, width: 180, padding: 8 })
      start_new_page
    end
  end
end
