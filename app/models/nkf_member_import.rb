# encoding: UTF-8
require 'net/http'
require 'uri'
require 'erb'
require 'pp'
require 'iconv'

class NkfMemberImport
  CONCURRENT_REQUESTS = 8
  include MonitorMixin
  attr_reader :changes, :error_records, :import_rows

  def size
    changes.try(:size).to_i + error_records.try(:size).to_i
  end

  def any?
    size > 0
  end

  def initialize
    super
    @changes       = []
    @error_records = []

    @iconv = Iconv.new('UTF8', 'ISO-8859-1')

    front_page_url   = login
    url              = URI.parse(front_page_url)
    html_search_body = nil

    search_url = '/portal/page/portal/ks_utv/ks_reg_medladm?f_informasjon=skjul&f_utvalg=vis&frm_27_v04=40001062&frm_27_v05=1&frm_27_v06=1&frm_27_v07=1034&frm_27_v10=162&frm_27_v12=O&frm_27_v15=Romerike%20Jujutsu%20Klubb&frm_27_v16=Stasjonsvn.%2017&frm_27_v17=P.b.%20157&frm_27_v18=2011&frm_27_v20=47326154&frm_27_v22=post%40jujutsu.no&frm_27_v23=70350537706&frm_27_v25=http%3A%2F%2Fjujutsu.no%2F&frm_27_v27=N&frm_27_v29=0&frm_27_v34=%3D&frm_27_v37=-1&frm_27_v44=%3D&frm_27_v45=%3D&frm_27_v46=11&frm_27_v47=11&frm_27_v49=N&frm_27_v50=134002.PNG&frm_27_v53=-1&p_ks_reg_medladm_action=SEARCH&p_page_search='
    logger.debug "Fetching #{search_url}"
    Net::HTTP.start(url.host, url.port) do |http|
      html_search_response = http.get(search_url, cookie_header.update('Content-Type' => 'application/octet-stream'))
      html_search_body     = html_search_response.body
      process_response 'html search', html_search_response
    end
    extra_function_codes = html_search_body.scan(/start_tilleggsfunk27\('(.*?)'\)/)
    raise html_search_body if extra_function_codes.empty?
    extra_function_code = extra_function_codes[0][0]
    session_id          = html_search_body.scan(/Download27\('(.*?)'\)/)[0][0]
    detail_codes        = html_search_body.scan(/edit_click27\('(.*?)'\)/).map { |dc| dc[0] }
    more_pages          = html_search_body.scan(/<a class="aPagenr" href="javascript:window.next_page27\('(\d+)'\)">(\d+)<\/a>/).map { |r| r[0] }
    more_pages.each_slice(CONCURRENT_REQUESTS) do |page_numbers|
      threads = page_numbers.map do |p|
        Thread.start do
          more_search_url = search_url + p
          logger.debug "Fetching #{more_search_url}"
          more_search_body = nil
          Net::HTTP.start(url.host, url.port) do |http|
            begin
              more_search_response = http.get(more_search_url, cookie_header.update('Content-Type' => 'application/octet-stream'))
            rescue Timeout::Error
              logger.error $!
              retry
            end
            more_search_body     = more_search_response.body
            process_response 'more search', more_search_response
          end
          synchronize do
            detail_codes += more_search_body.scan(/edit_click27\('(.*?)'\)/).map { |dc| dc[0] }
          end
        end
      end
      threads.each(&:join)
    end

    raise "Could not find session id" unless session_id

    @import_rows       = get_member_rows(url, session_id, detail_codes)
    member_trial_rows = get_member_trial_rows(url, session_id, extra_function_code)

    import_member_rows(@import_rows)
    import_member_trials(member_trial_rows)
  end

  private

  def get_member_rows(url, session_id, detail_codes)
    import_rows = nil
    Net::HTTP.start(url.host, url.port) do |http|
      members_url = 'http://nkfwww.kampsport.no/portal/pls/portal/myports.ks_reg_medladm_proc.download?p_cr_par=' + session_id
      logger.debug "Getting #{members_url}"
      members_response = http.get(members_url, cookie_header)
      members_body     = members_response.body
      process_response 'members', members_response
      import_rows = members_body.split("\n").map { |line| @iconv.iconv(line.chomp).split(';', -1)[0..-2] }
    end

    import_rows[0] << 'ventekid'

    detail_codes.each_slice(CONCURRENT_REQUESTS) do |detail_code_slice|
      threads = detail_code_slice.map do |dc|
        Thread.start do
          Net::HTTP.start(url.host, url.port) do |http|
            logger.debug "Getting details #{dc}"
            details_url = "http://nkfwww.kampsport.no/portal/page/portal/ks_utv/ks_medlprofil?p_cr_par=" + dc
            logger.debug "Getting #{details_url}"
            begin
              details_response = http.get(details_url, cookie_header)
              details_body = details_response.body
              process_response 'details', details_response
              raise Timeout::Error if details_body =~ /ks_medlprofil timed out/
            rescue EOFError, SystemCallError, Timeout::Error
              logger.error $!.message
              logger.info 'Retrying'
              retry
            end

            if details_body =~ /<input readonly tabindex="-1" class="inputTextFullRO" id="frm_48_v02" name="frm_48_v02" value="(\d+?)"/
              member_id = $1
              if details_body =~ /<input type="text" class="displayTextFull" value="Aktiv ">/
                active = true
              else
                active = false
              end
              if details_body =~ /<span class="kid_1">(\d+)<\/span><span class="kid_2">(\d+)<\/span>/
                waiting_kid = "#$1#$2"
              end
              raise "Both Active status and waiting kid was found" if active && waiting_kid
              raise "Neither active status nor waiting kid was found" if !active && !waiting_kid
              import_rows.find { |ir| ir[0] == member_id } << waiting_kid
            else
              raise "Could not find member id:\n#{details_body}"
            end
          end
        end
      end
      threads.each { |t| t.join }
    end
    import_rows
  end

  def get_member_trial_rows(url, session_id, extra_function_code)
    trial_csv_url = 'http://nkfwww.kampsport.no/portal/pls/portal/myports.ks_godkjenn_medlem_proc.exceleksport?p_cr_par=' + session_id
    logger.debug "Getting #{trial_csv_url}"
    member_trials_csv_body = nil
    Net::HTTP.start(url.host, url.port) do |http|
      member_trials_csv_response = http.get(trial_csv_url, cookie_header)
      member_trials_csv_body     = member_trials_csv_response.body
      process_response 'member trials csv', member_trials_csv_response
    end
    member_trial_rows = member_trials_csv_body.split("\n").map { |line| @iconv.iconv(line.chomp).split(';') }

    member_trials_body = nil
    Net::HTTP.start(url.host, url.port) do |http|
      trial_url = 'http://nkfwww.kampsport.no/portal/page/portal/ks_utv/vedl_portlets/ks_godkjenn_medlem?p_cr_par=' + extra_function_code
      logger.debug "Getting #{trial_url}"
      member_trials_response = http.get(trial_url, cookie_header)
      member_trials_body     = member_trials_response.body
      process_response 'member trials', member_trials_response
    end

    trial_ids = member_trials_body.scan(/edit_click28\('(.*?)'\)/).map { |tid| tid[0] }

    member_trial_rows[0] << 'tid'
    member_trial_rows[0] << 'epost_faktura'
    member_trial_rows[0] << 'stilart'

    trial_ids.each_slice(CONCURRENT_REQUESTS) do |trial_ids_slice|
      threads = trial_ids_slice.each.with_index.map do |tid, i|
        Thread.start do
          logger.debug "Getting details #{tid}"
          trial_details_url = "http://nkfwww.kampsport.no/portal/page/portal/ks_utv/vedl_portlets/ks_godkjenn_medlem?p_ks_godkjenn_medlem_action=UPDATE&frm_28_v04=#{tid}&p_cr_par=" + extra_function_code
          logger.debug "Getting #{trial_details_url}"
          trial_details_body = nil
          Net::HTTP.start(url.host, url.port) do |http|
            begin
              trial_details_response = http.get(trial_details_url, cookie_header)
            rescue EOFError, SystemCallError
              logger.error $!.message
              retry
            end
            trial_details_body = @iconv.iconv(trial_details_response.body)
            process_response 'trial details', trial_details_response
          end
          if trial_details_body =~ /name="frm_28_v08" value="(.*?)"/
            first_name = $1
            if trial_details_body =~ /name="frm_28_v09" value="(.*?)"/
              last_name = $1
              if trial_details_body =~ /name="frm_28_v25" value="(.*?)"/
                invoice_email = $1
                if trial_details_body =~ /<select class="inputTextFull" name="frm_28_v28" id="frm_28_v28"><option value="-1">- Velg gren\/stilart -<\/option>.*?<option selected value="\d+">([^<]*)<\/option>.*<\/select>/
                  martial_art = $1
                  trial_row   = member_trial_rows.find { |ir| ir.size < member_trial_rows[0].size && ir[1] == last_name && ir[2] == first_name }
                  trial_row << tid
                  trial_row << (invoice_email.blank? ? nil : invoice_email)
                  trial_row << martial_art
                else
                  raise "Could not find martial art"
                end
              else
                raise "Could not find first name"
              end
            else
              logger.error trial_details_body
              raise "Could not find last name"
            end
          else
            raise "Could not find invoice email"
          end
        end
      end
      threads.each(&:join)
    end
    member_trial_rows
  end

  def import_member_rows(import_rows)
    raise "Unknown format: #{import_rows && import_rows[0] && import_rows[0][0]}" unless import_rows && import_rows[0] && import_rows[0][0] == 'Medlemsnummer'
    header_fields = import_rows.shift
    columns       = header_fields.map { |f| field2column(f) }
    logger.debug "Found #{import_rows.size} active members"
    import_rows.each do |row|
      attributes = {}
      columns.each_with_index do |column, i|
        next if ['aktivitetsomrade_id', 'aktivitetsomrade_navn', 'alder', 'avtalegiro', 'dan_graderingsserifikat', 'forbundskontingent', 'foresatte'].include? column
        attributes[column] = row[i]
      end
      record = NkfMember.find_by_medlemsnummer(row[0]) || NkfMember.new
      if record.member_id.nil?
        member = Member.all(:conditions => ['UPPER(first_name) = ? AND UPPER(last_name) = ?', attributes['fornavn'].upcase, attributes['etternavn'].upcase]).find{|m| m.nkf_member.nil?}
        if member
          attributes['member_id'] = member.id
        end
      end
      begin
        record.attributes = attributes
      rescue ActiveRecord::UnknownAttributeError
        logger.error attributes.inspect
        raise
      end
      if record.changed?
        if record.save
          @changes << record.changes
        else
          logger.error "ERROR: #{record.errors.to_a.join(', ')}"
          @error_records << record
        end
      end
    end
  end

  def import_member_trials(member_trial_rows)
    header_fields = member_trial_rows.shift
    columns       = header_fields.map { |f| field2column(f) }
    logger.debug "Found #{member_trial_rows.size} member trials"
    logger.debug "Columns: #{columns.inspect}"
    tid_col_idx    = header_fields.index 'tid'
    email_col_idx  = header_fields.index 'epost'
    missing_trials = NkfMemberTrial.all :conditions => ['tid NOT IN (?)', member_trial_rows.map { |t| t[tid_col_idx] }]
    missing_trials.each do |t|
      m = Member.find_by_email(t.epost)
      t.trial_attendances.each do |ta|
        if m
          attrs = ta.attributes
          attrs.delete_if { |k, v| ['id', 'created_at', 'updated_at'].include? k }
          attrs['member_id'] = attrs.delete('nkf_member_trial_id')
          m.attendances << Attendance.new(attrs)
        end
        ta.destroy
      end
      t.destroy
    end
    member_trial_rows.each do |row|
      attributes = {}
      columns.each_with_index do |column, i|
        column = 'medlems_type' if column == 'type'
        if row[i] =~ /^(\d\d)\.(\d\d)\.(\d{4})$/
          row[i] = "#$3-#$2-#$1"
        end
        attributes[column] = row[i]
      end
      record            = NkfMemberTrial.find_by_tid(row[columns.index('tid')])
      record            ||= NkfMemberTrial.find_by_reg_dato_and_fornavn_and_etternavn(row[columns.index('reg_dato')], row[columns.index('fornavn')], row[columns.index('etternavn')])
      record            ||= NkfMemberTrial.new
      record.attributes = attributes
      if record.changed?
        if record.save
          @changes << record.changes
        else
          logger.error "ERROR: #{columns}"
          logger.error "ERROR: #{row}"
          logger.error "ERROR: #{record.attributes}"
          logger.error "ERROR: #{record.errors.to_a.join(', ')}"
          @error_records << record
        end
      end
    end
  end

  def field2column(field_name)
    field_name.gsub('ø', 'o').gsub('Ø', 'O').gsub('å', 'a').gsub('Å', 'A').gsub(/[ -.\/]/, '_').downcase
  end

  def login
    @cookies      = []
    url           = URI.parse('http://nkfwww.kampsport.no/')
    login_content = nil
    Net::HTTP.start(url.host, url.port) do |http|
      begin
        login_form_response = http.get '/portal/page/portal/ks_utv/st_login', cookie_header
      rescue EOFError, SystemCallError
        logger.error $!.message
        retry
      end
      login_content = login_form_response.body
      process_response 'login form', login_form_response
    end

    url   = URI.parse('http://nkfwww.kampsport.no/')
    token = nil
    Net::HTTP.start(url.host, url.port) do |http|
      token_response = http.get '/portal/pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038&p_cancel=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpage%2Fportal%2Fks_utv%2Fst_login', cookie_header
      token_body     = token_response.body
      process_response 'token', token_response
      token_fields = token_body.scan /<input .*?name="(.*?)".*?value ?="(.*?)".*?>/i
      token        = token_fields.find { |t| t[0] == 'site2pstoretoken' }[1]

      create_response = http.get "/portal/pls/portal/myports.st_login_proc.create_user?CreUser=40001062", cookie_header
      process_response 'create', create_response
    end

    url = URI.parse('http://nkflogin.kampsport.no/')
    Net::HTTP.start(url.host, url.port) do |http|
      login_form_fields = login_content.scan /<input .*?name="(.*?)".*?value ?="(.*?)".*?>/
      login_form_fields.delete_if { |f| ['site2pstoretoken', 'ssousername', 'password'].include? f[0] }
      login_form_fields += [['site2pstoretoken', token], ['ssousername', '40001062'], ['password', 'CokaBrus42']]
      login_params      = login_form_fields.map { |field| "#{field[0]}=#{ERB::Util.url_encode field[1]}" }.join '&'
      login_response    = http.post('/pls/orasso/orasso.wwsso_app_admin.ls_login', login_params, cookie_header)
      process_response 'login', login_response
      raise "Wrong URL: #{login_response.code}" unless login_response.code == "302"
      raise "Missing session cookie" if @cookies.empty?
      return login_response['location']
    end

  end

  def store_cookie(response)
    return unless response['set-cookie']
    header = response['set-cookie']
    header.gsub! /expires=.{3},/, ''
    header.split(',').each do |cookie|
      cookie_value = cookie.strip.slice(/^.*?;/).chomp(';')
      if cookie_value =~ /^(.*?)=(.*)$/
        name = $1
        @cookies.delete_if { |c| c =~ /^#{name}=/ }
      end
      @cookies << cookie_value unless cookie_value =~ /^.*?=$/
    end
    @cookies.uniq!
  end

  def cookie_header
    return {} if @cookies.empty?
    {'Cookie' => @cookies.join(';')}
  end

  def process_response(title, response)
    store_cookie(response)
    if response.code == '302'
      logger.debug "Following redirect to #{response['location']}"
      url = URI.parse(response['location'])
      Net::HTTP.start(url.host, url.port) do |http|
        redirect_response = http.get "#{url.path}?#{url.query}", cookie_header
        process_response 'redirect', redirect_response
      end
    end
  end

  def logger
    ActiveRecord::Base.logger
  end

end