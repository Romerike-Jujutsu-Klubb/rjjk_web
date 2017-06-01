# frozen_string_literal: true

class NkfAgent
  def initialize
    @agent = Mechanize.new
  end

  # Returns the front page
  def login
    token_page = @agent.get('http://nkfwww.kampsport.no/portal/pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038&p_cancel=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpage%2Fportal%2Fks_utv%2Fst_login')
    token = token_page.form('freshTokenForm').field_with(name: 'site2pstoretoken').value
    login_page = @agent.get('http://nkfwww.kampsport.no/portal/page/portal/ks_utv/st_login')
    login_form = login_page.form('st_login')
    login_form.ssousername = '40001062'
    login_form.password = ENV['NKF_PASSWORD']
    login_form.site2pstoretoken = token
    @agent.submit(login_form)
  end

  def get(url)
    @agent.get(url)
  end

  def submit(form)
    @agent.submit(form)
  end
end
