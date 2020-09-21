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

  def initialize(key)
    raise 'NKF PASSWORD required!' if NKF_PASSWORD.blank?

    super()
    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @thread_key = :"nkf_agent_#{key}"
    Thread.current[@thread_key] = @agent
  end

  # Returns the front page
  def login
    with_retries(label: 'agent login',
        exceptions: [Mechanize::ResponseCodeError, Net::HTTP::Persistent::Error, SocketError]) do
      prefix = 'http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2F'
      next_url =
          "#{prefix}pls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038"
      cancel_url = "#{prefix}page%2Fportal%2Fks_utv%2Fst_login"
      token_page = get(<<~URL)
        #{APP_PATH}/pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=#{next_url}&p_cancel=#{cancel_url}
      URL
      token = token_page.form('freshTokenForm').field_with(name: 'site2pstoretoken').value
      login_page = get("#{APP_PATH}/page/portal/ks_utv/st_login")
      login_form = login_page.form('st_login')
      login_form.ssousername = NKF_USERNAME
      login_form.password = NKF_PASSWORD
      login_form.site2pstoretoken = token
      submit(login_form)
    end
  end

  def search_members(nkf_member_id = nil)
    logger.debug "search members: nkf_member_id: #{nkf_member_id.inspect}"
    start = Time.zone.now
    search_url = "#{APP_PATH}/page/portal/ks_utv/ks_reg_medladm?f_informasjon=skjul&f_utvalg=vis" \
        "&frm_27_v04=#{NkfAgent::NKF_USERNAME}&frm_27_v05=1&frm_27_v06=1&frm_27_v07=1034&frm_27_v10=162" \
        '&frm_27_v12=O&frm_27_v15=Romerike%20Jujutsu%20Klubb&frm_27_v16=Stasjonsvn.%2017' \
        '&frm_27_v17=P.b.%20157&frm_27_v18=2011&frm_27_v20=47326154&frm_27_v22=post%40jujutsu.no' \
        '&frm_27_v23=70350537706&frm_27_v25=http%3A%2F%2Fjujutsu.no%2F&frm_27_v27=N&frm_27_v29=0' \
        "&frm_27_v34=%3D&frm_27_v37=-1#{"&frm_27_v40=#{nkf_member_id}" if nkf_member_id}&frm_27_v44=%3D" \
        '&frm_27_v45=%3D&frm_27_v46=11&frm_27_v47=11&frm_27_v49=N&frm_27_v50=134002.PNG&frm_27_v53=-1' \
        '&p_ks_reg_medladm_action=SEARCH&p_page_search='
    search_result_page = get(search_url)
    search_result_body = search_result_page.body
    more_pages = ['1'] + search_result_body
        .scan(%r{<a class="aPagenr" href="javascript:window.next_page27\('(\d+)'\)">(\d+)</a>})
        .map(&:first)
    logger.debug("more_pages: #{more_pages.inspect}")
    in_parallel(more_pages - ['1']) do |page_number, queue|
      logger.debug page_number
      page_body = get(search_url + page_number).body
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
    logger.debug "search members: nkf_member_id: #{nkf_member_id.inspect}: #{Time.zone.now - start}s"
    search_result_body
  end

  def get(url)
    with_retries do
      url = "#{APP_PATH}/#{url}" unless url.start_with?(APP_PATH)
      request_start = Time.zone.now
      response = thread_local_agent.get(url)
      logger.debug("NkfAgent.get(#{url.inspect}) took #{Time.zone.now - request_start}s")
      if response.body == <<~BAD_BODY
        An error occurred while processing the request. Try refreshing your browser. If the problem persists contact the site administrator'
      BAD_BODY
        raise Mechanize::ResponseReadError
      end

      response
    end
  end

  def with_retries(label: 'agent GET', attempts: nil,
      exceptions: [Errno::ECONNREFUSED, Mechanize::ChunkedTerminationError, Mechanize::ResponseReadError],
      backoff: 1.second, backoff_factor: 2, backoff_limit: BACKOFF_LIMIT)
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

  delegate :submit, to: :thread_local_agent

  private

  def thread_local_agent
    (Thread.current[@thread_key] ||= @agent.clone)
  end
end
