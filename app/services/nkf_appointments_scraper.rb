# frozen_string_literal: true

class NkfAppointmentsScraper
  def self.import_appointments
    tries ||= 1
    logger.info 'Import appointments'
    agent = NkfAgent.new(:appointments)
    front_page = agent.login

    admin_form = front_page.form('ks_reg_medladm')
    admin_form.field_with(name: 'frm_27_v13').options[3].select
    board_admin_front_page = agent.submit(admin_form)
    board_admin_page = board_admin_front_page.link_with(text: 'Vis administrator').click

    tables = board_admin_page.search('table')
    rows = tables[4].search('tr')[1..].map { |tr| tr.search('td').map(&:text).map(&:strip) }

    # FIXME(uwe):  Download CSV instead of scraping.

    appointments = rows.map do |r|
      role_name = { 'Barne og ungdomsrepresentant' => 'Foreldrerepresentant' }[r[1]] || r[1]
      role = Role.by_name(role_name).first_or_create!
      member_name = r[0]
      m = User.where("(last_name || ' ' || first_name) = ?", member_name)
          .flat_map(&:memberships).compact.first
      next "Ukjent medlem: #{member_name}" if m.nil?

      date = Date.strptime(r[5], '%d.%m.%Y')
      if role.on_the_board?
        annual_meeting = AnnualMeeting
            .find_by("DATE((start_at AT TIME ZONE 'UTC') AT TIME ZONE 'CET') = ?", date)
        next "Ukjent årsmøtedato: #{r[5]} (#{r[0]} #{role_name})" if annual_meeting.nil?

        Election.includes(:member, :role)
            .where(annual_meeting_id: annual_meeting.id, role_id: role.id,
                   years: role.years_on_the_board, member_id: m.id)
            .first_or_initialize
      else
        Appointment.includes(:member, :role).where(role_id: role.id, member_id: m.id, from: date)
            .first_or_initialize(to: r[6].blank? ? nil : Date.strptime(r[6], '%d.%m.%Y'))
      end
    end
    appointments.select { |a| a.is_a?(String) } +
        appointments.select { |a| !a.is_a?(String) && a.changed? }
        .each(&:save!).sort_by(&:from)
  rescue => e
    logger.warn "Exception scraping appointments (#{tries}): #{e}"
    if (tries += 1) <= 3
      backoff = 2**tries
      logger.debug "backoff: #{backoff}s"
      sleep backoff
      retry
    end
    raise
  end
end
