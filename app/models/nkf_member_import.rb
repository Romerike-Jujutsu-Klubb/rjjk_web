# encoding: UTF-8
require 'net/http'
require 'uri'
require 'erb'
require 'pp'
require 'iconv'

class NkfMemberImport
  CONCURRENT_REQUESTS = 7
  include MonitorMixin
  attr_reader :changes, :error_records, :exception, :import_rows, :new_records, :trial_changes

  def size
    new_records.try(:size).to_i + changes.try(:size).to_i + error_records.try(:size).to_i
  end

  def any?
    @exception || size > 0
  end

  def initialize
    super
    @new_records = []
    @changes = []
    @trial_changes = []
    @error_records = []

    @iconv = Iconv.new('UTF8', 'ISO-8859-1')
    @cookies = []

    login

    search_url = 'page/portal/ks_utv/ks_reg_medladm?f_informasjon=skjul&f_utvalg=vis&frm_27_v04=40001062&frm_27_v05=1&frm_27_v06=1&frm_27_v07=1034&frm_27_v10=162&frm_27_v12=O&frm_27_v15=Romerike%20Jujutsu%20Klubb&frm_27_v16=Stasjonsvn.%2017&frm_27_v17=P.b.%20157&frm_27_v18=2011&frm_27_v20=47326154&frm_27_v22=post%40jujutsu.no&frm_27_v23=70350537706&frm_27_v25=http%3A%2F%2Fjujutsu.no%2F&frm_27_v27=N&frm_27_v29=0&frm_27_v34=%3D&frm_27_v37=-1&frm_27_v44=%3D&frm_27_v45=%3D&frm_27_v46=11&frm_27_v47=11&frm_27_v49=N&frm_27_v50=134002.PNG&frm_27_v53=-1&p_ks_reg_medladm_action=SEARCH&p_page_search='
    html_search_body = http_get(search_url, true).body
    extra_function_codes = html_search_body.scan(/start_tilleggsfunk27\('(.*?)'\)/)
    raise html_search_body if extra_function_codes.empty?
    extra_function_code = extra_function_codes[0][0]
    session_id = html_search_body.scan(/Download27\('(.*?)'\)/)[0][0]
    detail_codes = html_search_body.scan(/edit_click27\('(.*?)'\)/).map { |dc| dc[0] }
    more_pages = html_search_body.scan(/<a class="aPagenr" href="javascript:window.next_page27\('(\d+)'\)">(\d+)<\/a>/).map { |r| r[0] }
    more_pages.each_slice(CONCURRENT_REQUESTS) do |page_numbers|
      threads = page_numbers.map do |p|
        Thread.start do
          begin
            more_search_url = search_url + p
            more_search_body = http_get(more_search_url, true).body
            synchronize do
              detail_codes += more_search_body.scan(/edit_click27\('(.*?)'\)/).map { |dc| dc[0] }
            end
          ensure
            ActiveRecord::Base.connection.close
          end
        end
      end
      threads.each(&:join)
    end

    raise 'Could not find session id' unless session_id

    @import_rows = get_member_rows(session_id, detail_codes)
    member_trial_rows = get_member_trial_rows(session_id, extra_function_code)

    import_member_rows(@import_rows)
    import_member_trials(member_trial_rows)
  rescue
    @exception = $!
  end

  private

  def get_member_rows(session_id, detail_codes)
    members_body = http_get("pls/portal/myports.ks_reg_medladm_proc.download?p_cr_par=#{session_id}").body
    import_rows = members_body.split("\n").map { |line| @iconv.iconv(line.chomp).split(';', -1)[0..-2] }
    #import_rows = members_body.split("\n").map { |line| line.chomp.split(';', -1)[0..-2] }
    import_rows[0] << 'ventekid'
    detail_codes.each_slice(CONCURRENT_REQUESTS) do |detail_code_slice|
      threads = detail_code_slice.map do |dc|
        Thread.start do
          begin
            details_body = http_get("page/portal/ks_utv/ks_medlprofil?p_cr_par=#{dc}").body
            if details_body =~ /<input readonly tabindex="-1" class="inputTextFullRO" id="frm_48_v02" name="frm_48_v02" value="(\d+?)"/
              member_id = $1
              if details_body =~ /<input type="text" class="displayTextFull" value="Aktiv ">/
                active = true
              else
                active = false
              end
              if details_body =~ /<span class="kid_1">(\d+)<\/span><span class="kid_2">(\d+)<\/span>/
                waiting_kid = "#$1#$2"
              else
                waiting_kid = nil
              end
              raise 'Both Active status and waiting kid was found' if active && waiting_kid
              raise 'Neither active status nor waiting kid was found' if !active && !waiting_kid
              import_rows.find { |ir| ir[0] == member_id } << waiting_kid
            else
              raise "Could not find member id:\n#{details_body}"
            end
          ensure
            ActiveRecord::Base.connection.close
          end
        end
      end
      threads.each { |t| t.join }
    end
    import_rows
  end

  def get_member_trial_rows(session_id, extra_function_code)
    trial_csv_url = 'pls/portal/myports.ks_godkjenn_medlem_proc.exceleksport?p_cr_par=' + session_id
    member_trials_csv_body = http_get(trial_csv_url).body
    member_trial_rows = member_trials_csv_body.split("\n").map { |line| @iconv.iconv(line.chomp).split(';') }
    # member_trial_rows = member_trials_csv_body.split("\n").map { |line| line.chomp.split(';') }

    trial_url = 'page/portal/ks_utv/vedl_portlets/ks_godkjenn_medlem?p_cr_par=' + extra_function_code
    member_trials_body = http_get(trial_url).body
    trial_ids = member_trials_body.scan(/edit_click28\('(.*?)'\)/).map { |tid| tid[0] }

    member_trial_rows[0] << 'tid'
    member_trial_rows[0] << 'epost_faktura'
    member_trial_rows[0] << 'stilart'

    trial_ids.each_slice(CONCURRENT_REQUESTS) do |trial_ids_slice|
      threads = trial_ids_slice.each.map do |tid|
        Thread.start do
          begin
            trial_details_url = "page/portal/ks_utv/vedl_portlets/ks_godkjenn_medlem?p_ks_godkjenn_medlem_action=UPDATE&frm_28_v04=#{tid}&p_cr_par=" + extra_function_code
            trial_details_body = http_get(trial_details_url).body
            if trial_details_body =~ /name="frm_28_v08" value="(.*?)"/
              first_name = $1
              if trial_details_body =~ /name="frm_28_v09" value="(.*?)"/
                last_name = $1
                if trial_details_body =~ /name="frm_28_v25" value="(.*?)"/
                  invoice_email = $1
                  if trial_details_body =~ /<select class="inputTextFull" name="frm_28_v28" id="frm_28_v28"><option value="-1">- Velg gren\/stilart -<\/option>.*?<option selected value="\d+">([^<]*)<\/option>.*<\/select>/
                    martial_art = $1
                    trial_row = member_trial_rows.find { |ir| ir.size < member_trial_rows[0].size && ir[1] == last_name && ir[2] == first_name }
                    if trial_row
                      trial_row << tid
                      trial_row << (invoice_email.blank? ? nil : invoice_email)
                      trial_row << martial_art
                    else
                      logger.error '*' * 80
                      logger.error "Fant ikke prøvetidsmedlem:  #{tid.inspect}"
                      logger.error "First name: #{first_name.inspect}"
                      logger.error "Last name: #{last_name.inspect}"
                      logger.error "invoice_email: #{invoice_email.inspect}"
                      logger.error "martial_art: #{martial_art.inspect}"
                      logger.error trial_details_body
                      logger.error member_trial_rows
                      logger.error '=' * 80
                    end
                  else
                    raise 'Could not find martial art'
                  end
                else
                  raise 'Could not find first name'
                end
              else
                logger.error trial_details_body
                raise 'Could not find last name'
              end
            else
              raise 'Could not find invoice email'
            end
          ensure
            ActiveRecord::Base.connection.close
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
    columns = header_fields.map { |f| field2column(f) }
    logger.debug "Found #{import_rows.size} active members"
    import_rows.each do |row|
      attributes = {}
      columns.each_with_index do |column, i|
        next if %w{aktivitetsomrade_id aktivitetsomrade_navn alder avtalegiro
                 dan_graderingsserifikat forbundskontingent foresatte foresatte_epost
                 foresatte_mobil foresatte_nr_2 foresatte_nr_2_mobil}.include? column
        attributes[column] = row[i] && row[i].strip
      end
      record = NkfMember.find_by_medlemsnummer(row[0]) || NkfMember.new
      if record.member_id.nil?
        member = Member.all(:conditions => ['UPPER(first_name) = ? AND UPPER(last_name) = ?', attributes['fornavn'].upcase, attributes['etternavn'].upcase]).find { |m| m.nkf_member.nil? }
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
      was_new_record = record.new_record?
      if record.changed?
        c = record.changes
        logger.debug "Found changes: #{c.inspect}"
        if record.save
          logger.debug "Found changes: #{c.inspect}"
          (was_new_record ? @new_records : @changes) << {:record => record, :changes => c}
        else
          logger.error "ERROR: #{record.errors.to_a.join(', ')}"
          @error_records << record
        end
      end
    end
  end

  def import_member_trials(member_trial_rows)
    header_fields = member_trial_rows.shift
    columns = header_fields.map { |f| field2column(f) }
    logger.debug "Found #{member_trial_rows.size} member trials"
    logger.debug "Columns: #{columns.inspect}"
    tid_col_idx = header_fields.index 'tid'
    # email_col_idx  = header_fields.index 'epost'
    missing_trials = NkfMemberTrial.all :conditions => ['tid NOT IN (?)', member_trial_rows.map { |t| t[tid_col_idx] }]
    missing_trials.each do |t|
      m = Member.find_by_email(t.epost)
      t.trial_attendances.each do |ta|
        if m
          attrs = ta.attributes
          attrs.delete_if { |k, _| %w(id created_at updated_at).include? k }
          attrs['member_id'] = m.id
          attrs.delete('nkf_member_trial_id')
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
      record = NkfMemberTrial.find_by_tid(row[columns.index('tid')])
      record ||= NkfMemberTrial.find_by_reg_dato_and_fornavn_and_etternavn(row[columns.index('reg_dato')], row[columns.index('fornavn')], row[columns.index('etternavn')])
      record ||= NkfMemberTrial.new
      record.attributes = attributes
      if record.changed?
        c = record.changes
        if record.save
          @trial_changes << {:record => record, :changes => c}
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
    login_content = http_get('page/portal/ks_utv/st_login').body

    token_body = http_get('pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=http%3A%2F%2Fwww.kampsport.no%2Fportal%2Fpls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038&p_cancel=http%3A%2F%2Fwww.kampsport.no%2Fportal%2Fpage%2Fportal%2Fks_utv%2Fst_login').body
    token_fields = token_body.scan /<input .*?name="(.*?)".*?value ?="(.*?)".*?>/i
    token = token_fields.find { |t| t[0] == 'site2pstoretoken' }[1]
    http_get('pls/portal/myports.st_login_proc.create_user?CreUser=40001062')

    url = URI.parse('http://login.kampsport.no/')
    login_form_fields = login_content.scan /<input .*?name="(.*?)".*?value ?="(.*?)".*?>/
    login_form_fields.delete_if { |f| %w{site2pstoretoken ssousername password}.include? f[0] }
    login_form_fields += [['site2pstoretoken', token], %w{ssousername 40001062}, %w{password CokaBrus42}]
    login_params = login_form_fields.map { |field| "#{field[0]}=#{ERB::Util.url_encode field[1]}" }.join '&'
    Net::HTTP.start(url.host, url.port) do |http|
      login_response = http.post('/pls/orasso/orasso.wwsso_app_admin.ls_login', login_params, cookie_header)
      unless login_response.code == '302'
        logger.error "Wrong URL: #{login_response.code}"
        redo
      end
      process_response login_response
      raise 'Missing session cookie' if @cookies.empty?
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

  def http_get(url_string, binary = false)
    logger.debug "Getting #{url_string}"
    url = URI.parse(url_string =~ %r{^http://} ? url_string : "http://www.kampsport.no/portal/#{url_string}")
    backoff = 1
    begin
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.get(url_string =~ %r{^http://} ? url_string.gsub(%r{^http://[^/]+}, '') : "/portal/#{url_string}", cookie_header.update(binary ? {'Content-Type' => 'application/octet-stream'} : {}))
        body = response.body
        raise Timeout::Error if body =~ /ks_medlprofil timed out|Siden er utl.pt/
        raise EOFError.new('Internal error') if body =~ /The server encountered an internal error or/
        raise EOFError.new('Try refreshing') if body =~ /An error occurred while processing the request. Try refreshing your browser. If the problem persists contact the site administrator/
        raise EOFError.new('Lytter returnerte feil') if body =~ /Feil: Lytteren returnerte den f.lgende meldingen: 503 Service Unavailable/
        raise EOFError.new('Servlet Error') if body =~ /<TITLE>Servlet Error<\/TITLE>/i
        return process_response(response)
      end
    rescue EOFError, SystemCallError, Timeout::Error, Errno::ECONNREFUSED
      logger.error $!.message
      if backoff > 15.minutes
        if $!.respond_to?(:message=)
          $!.message = "Backoff limit reached (#{backoff}): #{$!.message}"
        end
        raise
      end
      sleep backoff
      logger.info "Retrying #{backoff}"
      backoff *= 2
      retry
    end
  end

  def process_response(response)
    store_cookie(response)
    if response.code == '302'
      redirect_url = response['location']
      logger.debug "Following redirect to #{redirect_url}"
      return http_get redirect_url
    elsif response.code != '200'
      raise "Got response code #{response.code}"
    end
    response
  end

  def logger
    Rails.logger
  end

end
