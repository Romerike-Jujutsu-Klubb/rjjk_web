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
      text "Gradering #{date.day}. #{I18n.t('date.month_names')[date.month].downcase} #{date.year}",
          size: 18, align: :center
      move_down 16
      data = graduation.graduates.sort_by { |g| [-g.rank.position, g.member.name] }
          .map do |graduate|
        member = graduate.member
        member_current_rank = member
            .current_rank(graduate.graduation.martial_art.id, graduate.graduation.held_on)
        from_rank =
            if member_current_rank
              member_current_rank.name
            else
              'Ugradert'
            end
        [
          <<~TXT.chomp,
            <font size='16'>#{member.first_name}</font> #{member.last_name}#{member.birthdate && " (#{member.age} år)" || ''}
            #{from_rank} > <b>#{graduate.rank.name} #{graduate.rank.colour}</b>
            Treninger: <b>#{member.attendances_since_graduation(graduation.held_on).count}</b> (#{graduate.current_rank_age})
          TXT
          graduate.member.image&.content_type&.match(%r{image/(jpe?g|png)}) ? { image: graduate.member.image&.content_data_io, fit: [80, 160] } : '',
          '',
        ]
      end
      table([['Utøver', 'Bra', 'Kan bli bedre']] + data,
          header: true, cell_style: { inline_format: true, width: 180, padding: 8 })
      start_new_page
    end
  end
end
