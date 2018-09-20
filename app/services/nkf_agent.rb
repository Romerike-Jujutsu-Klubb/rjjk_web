# frozen_string_literal: true

class Mechanize
  def clone
    Mechanize.new do |a|
      a.cookie_jar = cookie_jar
      a.max_history = max_history
      a.read_timeout = read_timeout
      a.agent.http.verify_mode = agent.http.verify_mode
    end
  end
end

class NkfAgent
  include ParallelRunner
  include MonitorMixin

  APP_PATH = 'https://nkfwww.kampsport.no/portal'
  NKF_USERNAME = '40001062'
  NKF_PASSWORD = Rails.application.credentials.nkf_password
  BACKOFF_LIMIT = 15.minutes

  def initialize
    raise 'NKF PASSWORD required!' if NKF_PASSWORD.blank?

    super
    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  # Returns the front page
  def login
    backoff ||= 1
    # rubocop: disable Metrics/LineLength
    token_page = @agent.get("#{APP_PATH}/pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038&p_cancel=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpage%2Fportal%2Fks_utv%2Fst_login")
    # rubocop: enable Metrics/LineLength
    token = token_page.form('freshTokenForm').field_with(name: 'site2pstoretoken').value
    login_page = @agent.get("#{APP_PATH}/page/portal/ks_utv/st_login")
    login_form = login_page.form('st_login')
    login_form.ssousername = NKF_USERNAME
    login_form.password = NKF_PASSWORD
    login_form.site2pstoretoken = token
    @agent.submit(login_form)
  rescue Mechanize::ResponseCodeError, SocketError => e
    raise e if backoff > BACKOFF_LIMIT

    logger.info "Retrying agent login #{backoff} #{e}"
    sleep backoff
    backoff *= 2
    retry
  end

  def search_members(nkf_member_id = nil)
    logger.debug "search members: nkf_member_id: #{nkf_member_id.inspect}"
    search_url = "#{APP_PATH}/page/portal/ks_utv/ks_reg_medladm?f_informasjon=skjul&f_utvalg=vis" \
        "&frm_27_v04=#{NkfAgent::NKF_USERNAME}&frm_27_v05=1&frm_27_v06=1&frm_27_v07=1034&frm_27_v10=162" \
        '&frm_27_v12=O&frm_27_v15=Romerike%20Jujutsu%20Klubb&frm_27_v16=Stasjonsvn.%2017' \
        '&frm_27_v17=P.b.%20157&frm_27_v18=2011&frm_27_v20=47326154&frm_27_v22=post%40jujutsu.no' \
        '&frm_27_v23=70350537706&frm_27_v25=http%3A%2F%2Fjujutsu.no%2F&frm_27_v27=N&frm_27_v29=0' \
        "&frm_27_v34=%3D&frm_27_v37=-1#{"&frm_27_v40=#{nkf_member_id}" if nkf_member_id}&frm_27_v44=%3D" \
        '&frm_27_v45=%3D&frm_27_v46=11&frm_27_v47=11&frm_27_v49=N&frm_27_v50=134002.PNG&frm_27_v53=-1' \
        '&p_ks_reg_medladm_action=SEARCH&p_page_search='
    search_result_page = @agent.get(search_url)
    search_result_body = search_result_page.body
    more_pages = ['1'] + search_result_body
        .scan(%r{<a class="aPagenr" href="javascript:window.next_page27\('(\d+)'\)">(\d+)</a>})
        .map(&:first)
    logger.debug("more_pages: #{more_pages.inspect}")
    in_parallel(more_pages - ['1']) do |page_number, queue|
      logger.debug page_number
      page_body = with_retries(exceptions: Mechanize::ChunkedTerminationError) do
        @agent.clone.get(search_url + page_number).body
      end
      even_more_pages = page_body
          .scan(%r{<a class="aPagenr" href="javascript:window.next_page27\('(\d+)'\)">(\d+)</a>})
          .map(&:first)
      synchronize do
        (even_more_pages - more_pages).each do |page_no|
          logger.debug "Add page: #{page_no}"
          more_pages << page_no
          queue << page_no
        end
        search_result_body << page_body
      end
    end
    logger.debug("more_pages: #{more_pages.inspect}")
    search_result_body
  end

  def get(url)
    with_retries do
      url = "#{APP_PATH}/#{url}" unless url.start_with?(APP_PATH)
      @agent.get(url)
    end
  end

  def with_retries(label: 'agent GET', attempts: nil, exceptions: Errno::ECONNREFUSED, backoff: 1.second,
      backoff_factor: 2, backoff_limit: BACKOFF_LIMIT)
    attempt ||= 1
    yield
  rescue *exceptions => e
    raise e if (attempts && attempt >= attempts) || backoff > backoff_limit

    attempt += 1
    logger.info "Retrying #{label} #{attempt} #{backoff} #{e}"
    sleep backoff
    backoff *= backoff_factor
    retry
  end

  def submit(form)
    @agent.submit(form)
  end
end
