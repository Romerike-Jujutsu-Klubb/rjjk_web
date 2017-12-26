# frozen_string_literal: true

class NkfAgent
  NKF_USERNAME = '40001062'
  NKF_PASSWORD_KEY = 'NKF_PASSWORD'
  BACKOFF_LIMIT = 15.minutes

  def initialize
    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  # Returns the front page
  def login
    backoff ||= 1
    token_page = @agent.get('http://nkfwww.kampsport.no/portal/pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038&p_cancel=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpage%2Fportal%2Fks_utv%2Fst_login')
    token = token_page.form('freshTokenForm').field_with(name: 'site2pstoretoken').value
    login_page = @agent.get('http://nkfwww.kampsport.no/portal/page/portal/ks_utv/st_login')
    login_form = login_page.form('st_login')
    login_form.ssousername = NKF_USERNAME
    login_form.password = ENV[NKF_PASSWORD_KEY]
    login_form.site2pstoretoken = token
    @agent.submit(login_form)
  rescue Mechanize::ResponseCodeError, SocketError => e
    raise e if backoff > BACKOFF_LIMIT
    logger.info "Retrying agent login #{backoff}"
    sleep backoff
    backoff *= 2
    retry
  end

  def get(url)
    @agent.get(url)
  end

  def submit(form)
    @agent.submit(form)
  end
end
