# encoding: utf-8
class NkfAppointmentsScraper
  def self.import_appointments
    agent = Mechanize.new
    front_page = login(agent)

    admin_form = front_page.form('ks_reg_medladm')
    admin_form.field_with(name: 'frm_27_v13').options[3].select
    board_admin_front_page = agent.submit(admin_form)
    board_admin_page = board_admin_front_page.link_with(text: 'Vis administrator').click

    tables = board_admin_page.search('table')
    rows = tables[4].search('tr')[1..-1].map { |tr| tr.search('td').map(&:text).map(&:strip) }

    # FIXME(uwe):  Download CSV instead of scraping.

    appointments = rows.map do |r|
      role_name = {
          'Barne og ungdomsrepresentant' => 'Foreldrerepresentant',

          # FIXME(uwe): Fjern når importert i produksjon
          'Medlem' => 'Foreldrerepresentant',
          # EMXIF

      }[r[1]] || r[1]
      role = Role.where(name: role_name).first_or_create!
      member_name = r[0]
      m = Member.
          where("(members.last_name || ' ' || members.first_name) = ?",
          member_name).
          first
      next "Ukjent medlem: #{member_name}" if m.nil?
      if role.on_the_board?
        annual_meeting = AnnualMeeting.
            where('DATE(start_at) = ?', Date.strptime(r[5], '%d.%m.%Y')).first
        next "Ukjent årsmøtedato: #{r[5]} (#{r[0]} #{role_name})" if annual_meeting.nil?
        Election.includes(:member, :role).
            where(annual_meeting_id: annual_meeting.id, role_id: role.id, years: role.years_on_the_board, member_id: m.id).
            first_or_initialize
      else
        Appointment.includes(:member, :role).
            where(role_id: role.id, member_id: m.id, from: Date.strptime(r[5], '%d.%m.%Y')).
            first_or_initialize(to: r[6].blank? ? nil : Date.strptime(r[6], '%d.%m.%Y'))
      end
    end
    appointments.select(&:changed?).each(&:save!).sort_by(&:from)
  end

  def self.login(agent)
    token_page = agent.get('http://www.kampsport.no/portal/pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=http%3A%2F%2Fwww.kampsport.no%2Fportal%2Fpls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038&p_cancel=http%3A%2F%2Fwww.kampsport.no%2Fportal%2Fpage%2Fportal%2Fks_utv%2Fst_login')
    token = token_page.form('freshTokenForm').field_with(:name => 'site2pstoretoken').value
    login_page = agent.get('http://www.kampsport.no/portal/page/portal/ks_utv/st_login')
    login_form = login_page.form('st_login')
    login_form.ssousername = '40001062'
    login_form.password = 'CokaBrus42'
    login_form.site2pstoretoken = token
    agent.submit(login_form)
  end
end

