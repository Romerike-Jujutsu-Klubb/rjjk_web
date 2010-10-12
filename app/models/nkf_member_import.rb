require 'net/http'
require 'uri'
require 'erb'
require 'pp'
  
class NkfMemberImport
  def self.import
    @changes = []
    @error_records = []
    
    @iconv = Iconv.new('UTF8', 'ISO-8859-1')
        
    import_rows = nil
    member_trial_rows = nil
    
    front_page_url = login

    url = URI.parse(front_page_url)
    Net::HTTP.start(url.host, url.port) do |http|
      search_url = '/portal/page/portal/ks_utv/ks_reg_medladm?f_informasjon=skjul&f_utvalg=vis&frm_27_v04=40001062&frm_27_v05=1&frm_27_v06=1&frm_27_v07=1034&frm_27_v10=162&frm_27_v12=O&frm_27_v15=Romerike%20Jujutsu%20Klubb&frm_27_v16=Stasjonsvn.%2017&frm_27_v17=P.b.%20157&frm_27_v18=2011&frm_27_v20=47326154&frm_27_v22=post%40jujutsu.no&frm_27_v23=70350537706&frm_27_v25=http%3A%2F%2Fjujutsu.no%2F&frm_27_v27=N&frm_27_v29=0&frm_27_v34=%3D&frm_27_v37=-1&frm_27_v44=%3D&frm_27_v45=%3D&frm_27_v46=11&frm_27_v47=11&frm_27_v49=N&frm_27_v50=134002.PNG&frm_27_v53=-1&p_ks_reg_medladm_action=SEARCH&p_page_search='
      logger.debug "Fetching #{search_url}"
      html_search_response = http.get(search_url, cookie_header.update('Content-Type' => 'application/octet-stream'))
      html_search_body = html_search_response.body
      process_response 'html search', html_search_response
      download_codes = html_search_body.scan /Download27\('(.*?)'\)/
      detail_codes = html_search_body.scan(/edit_click27\('(.*?)'\)/).map{|dc| dc[0]}
      more_pages = html_search_body.scan(/<a class="aPagenr" href="javascript:window.next_page27\('(\d+)'\)">(\d+)<\/a>/).map{|r| r[0]}
      more_pages.each do |p|
        more_search_url = search_url + p
        logger.debug "Fetching #{more_search_url}"
        more_search_response = http.get(more_search_url, cookie_header.update('Content-Type' => 'application/octet-stream'))
        more_search_body = more_search_response.body
        process_response 'more search', more_search_response
        detail_codes += more_search_body.scan(/edit_click27\('(.*?)'\)/).map{|dc| dc[0]}
      end

      raise download_codes.inspect unless download_codes && download_codes[0] && download_codes[0][0]

      members_url = 'http://nkfwww.kampsport.no/portal/pls/portal/myports.ks_reg_medladm_proc.download?p_cr_par=' + download_codes[0][0]
      logger.debug "Getting #{members_url}"
      members_response = http.get(members_url, cookie_header)
      members_body = members_response.body
      process_response 'members', members_response
      import_rows = members_body.split("\n").map{|line| @iconv.iconv(line.chomp).split(';', -1)[0..-2]}

      import_rows[0] << 'ventekid'

      detail_codes.each do |dc|
        logger.debug "Getting details #{dc}"
        details_url = "http://nkfwww.kampsport.no/portal/page/portal/ks_utv/ks_medlprofil?p_cr_par=" + dc
        logger.debug "Getting #{details_url}"
        begin
          details_response = http.get(details_url, cookie_header)
        rescue EOFError, SystemCallError
          logger.error $!.message
          retry
        end
        details_body = details_response.body
        process_response 'details', details_response
        if details_body =~ /<input readonly tabindex="-1" class="inputTextFullRO" id="frm_48_v02" name="frm_48_v02" value="(\d+)">/
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
          import_rows.find{|ir| ir[0] == member_id} << waiting_kid
        else
          raise "Could not find member id"
        end
      end

      trial_url = 'http://nkfwww.kampsport.no/portal/pls/portal/myports.ks_godkjenn_medlem_proc.exceleksport?p_cr_par=' + download_codes[0][0]
      logger.debug "Getting #{trial_url}"
      member_trials_response = http.get(trial_url, cookie_header)
      member_trials_body = member_trials_response.body
      process_response 'member trials', member_trials_response
      member_trial_rows = member_trials_body.split("\n").map{|line| @iconv.iconv(line.chomp).split(';')}
    end
    
    import_member_rows(import_rows)
    import_member_trials(member_trial_rows)
    return "#{@changes.size} records imported, #{@error_records.size} failed, #{import_rows.size - @changes.size - @error_records.size} skipped\n"
  end
  
  private
  
  def self.import_member_rows(import_rows)  
    raise "Unknown format: #{import_rows && import_rows[0] && import_rows[0][0]}" unless import_rows && import_rows[0] && import_rows[0][0] == 'Medlemsnummer'
    header_fields = import_rows.shift
    columns = header_fields.map{|f| field2column(f)}
    logger.debug "Found #{import_rows.size} active members"
    import_rows.each do |row|
      attributes = {}
      columns.each_with_index do |column, i|
        next if column == 'alder'
        attributes[column] = row[i]
      end
      record = NkfMember.find_by_medlemsnummer(row[0]) || NkfMember.new
      if record.member_id.nil?
        member = Member.find(:first, :conditions => ['UPPER(first_name) = ? AND UPPER(last_name) = ?', attributes['fornavn'].upcase, attributes['etternavn'].upcase])
        if member
          attributes['member_id'] = member.id
        end
      end
      record.attributes = attributes
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
  
  def self.import_member_trials(member_trial_rows)  
    header_fields = member_trial_rows.shift
    columns = header_fields.map{|f| field2column(f)}
    logger.debug "Found #{member_trial_rows.size} member trials"
    NkfMemberTrial.delete_all
    member_trial_rows.each do |row|
      attributes = {}
      columns.each_with_index do |column, i|
        column = 'medlems_type' if column == 'type'
        if row[i] =~ /^(\d\d)\.(\d\d)\.(\d{4})$/
          row[i] = "#$3-#$2-#$1"
        end
        attributes[column] = row[i]
      end
      record = NkfMemberTrial.find_by_reg_dato_and_fornavn_and_etternavn(row[columns.index('reg_dato')], row[columns.index('fornavn')], row[columns.index('etternavn')]) || NkfMemberTrial.new
      record.attributes = attributes
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
  
  def self.field2column(field_name)
    field_name.gsub('ø', 'o').gsub('Ø', 'O').gsub('å', 'a').gsub('Å', 'A').gsub(/[ -.\/]/, '_').downcase
  end
  
  def self.login
    @cookies = []
    url = URI.parse('http://nkfwww.kampsport.no/')
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
    
    url = URI.parse('http://nkfwww.kampsport.no/')
    token = nil
    Net::HTTP.start(url.host, url.port) do |http|
      token_response = http.get '/portal/pls/portal/portal.wwptl_login.show_site2pstoretoken?p_url=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpls%2Fportal%2Fmyports.st_login_proc.set_language%3Fref_path%3D7513_ST_LOGIN_463458038&p_cancel=http%3A%2F%2Fnkfwww.kampsport.no%2Fportal%2Fpage%2Fportal%2Fks_utv%2Fst_login', cookie_header
      token_body = token_response.body
      process_response 'token', token_response
      token_fields = token_body.scan /<input .*?name="(.*?)".*?value ?="(.*?)".*?>/i
      token = token_fields.find{|t| t[0] == 'site2pstoretoken'}[1]
      
      create_response = http.get "/portal/pls/portal/myports.st_login_proc.create_user?CreUser=40001062", cookie_header
      process_response 'create', create_response
    end
    
    url = URI.parse('http://nkflogin.kampsport.no/')
    Net::HTTP.start(url.host, url.port) do |http|
      login_form_fields = login_content.scan /<input .*?name="(.*?)".*?value ?="(.*?)".*?>/
      login_form_fields.delete_if{|f| ['site2pstoretoken', 'ssousername', 'password'].include? f[0]}
      login_form_fields += [['site2pstoretoken', token], ['ssousername', '40001062'], ['password', 'CokaBrus42']]
      login_params = login_form_fields.map {|field| "#{field[0]}=#{ERB::Util.url_encode field[1]}"}.join '&'
      login_response = http.post('/pls/orasso/orasso.wwsso_app_admin.ls_login', login_params, cookie_header)
      process_response 'login', login_response
      raise "Wrong URL: #{login_response.code}" unless login_response.code == "302"
      raise "Missing session cookie" if @cookies.empty?
      return login_response['location']
    end
    
  end
  
  def self.store_cookie(response)
    return unless response['set-cookie']
    header = response['set-cookie']
    header.gsub! /expires=.{3},/, ''
    header.split(',').each do |cookie|
      cookie_value = cookie.strip.slice(/^.*?;/).chomp(';')
      if cookie_value =~ /^(.*?)=(.*)$/
        name = $1
        @cookies.delete_if{|c| c =~ /^#{name}=/}
      end
      @cookies << cookie_value unless cookie_value =~ /^.*?=$/
    end
    @cookies.uniq!
  end
  
  def self.cookie_header
    return {} if @cookies.empty?
    {'Cookie' => @cookies.join(';')}
  end
  
  def self.process_response(title, response)
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
  
  def self.logger
    ActiveRecord::Base.logger
  end

end