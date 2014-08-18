class Role < ActiveRecord::Base
  has_many :appointments
  has_many :elections

  after_update do
    if years_on_the_board_changed?
      if years_on_the_board.nil?
        elections.current.each do |a|
          am = a.annual_meeting
          a.destroy
          appointments.create! member_id: a.member_id, from: am.start_at.try(:to_date),
              to: am.next.try(:start_at).try(:to_date)
        end
      else
        appointments.current.each do |a|
          if (am = AnnualMeeting.where('DATE(start_at) = ?', a.from).first)
            a.destroy
            elections.create! member_id: a.member_id, annual_meeting_id: am.id,
                years: years_on_the_board
          end
        end
      end
    end
  end

  def on_the_board?
    !!years_on_the_board
  end
end
