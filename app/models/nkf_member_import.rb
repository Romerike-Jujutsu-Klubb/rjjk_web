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
    
    front_page_url = login
    url = URI.parse(front_page_url)
    Net::HTTP.start(url.host, url.port) do |http|
      html_search_response = http.get('/portal/page/portal/ks_utv/ks_reg_medladm?f_informasjon=skjul&f_utvalg=vis&frm_27_v01=&frm_27_v02=&frm_27_v03=&frm_27_v04=40001062&frm_27_v05=1&frm_27_v06=1&frm_27_v07=1034&frm_27_v10=162&frm_27_v12=O&frm_27_v13=&frm_27_v15=Romerike%20Jujutsu%20Klubb&frm_27_v16=Stasjonsvn.%2017&frm_27_v17=P.b.%20157&frm_27_v18=2011&frm_27_v20=47326154&frm_27_v21=&frm_27_v22=post%40jujutsu.no&frm_27_v23=70350537706&frm_27_v24=&frm_27_v25=http%3A%2F%2Fjujutsu.no%2F&frm_27_v26=&frm_27_v27=N&frm_27_v29=0&frm_27_v30=&frm_27_v31=&frm_27_v32=&frm_27_v33=&frm_27_v34=%3D&frm_27_v35=&frm_27_v36=&frm_27_v37=-1&frm_27_v38=&frm_27_v39=&frm_27_v40=&frm_27_v41=&frm_27_v42=&frm_27_v44=%3D&frm_27_v45=%3D&frm_27_v46=11&frm_27_v47=11&frm_27_v48=&frm_27_v49=N&frm_27_v50=134002.PNG&frm_27_v53=-1&frm_27_v54=&p_ks_reg_medladm_action=SEARCH&p_mode=&p_page_search=', cookie_header.update('Content-Type' => 'application/octet-stream'))
      html_search_body = html_search_response.body
      process_response 'html search', html_search_response
      download_codes = html_search_body.scan /Download27\('(.*?)'\)/

      raise download_codes.inspect unless download_codes && download_codes[0] && download_codes[0][0]
      
      members_response = http.get('http://nkfwww.kampsport.no/portal/pls/portal/myports.ks_reg_medladm_proc.download?p_cr_par=' + download_codes[0][0], cookie_header)
      members_body = members_response.body
      process_response 'members', members_response
      import_rows = members_body.split("\n").map{|line| @iconv.iconv(line.chomp).split(';')}
    end
    
    raise "Unknown format: #{import_rows && import_rows[0] && import_rows[0][0]}" unless import_rows && import_rows[0] && import_rows[0][0] == 'Medlemsnummer'
    
    header_fields = import_rows.shift
    columns = header_fields.map{|f| field2column(f)}
    puts "Found #{import_rows.size} active members"
    import_rows.each do |row|
      attributes = {}
      columns.each_with_index do |column, i|
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
          puts "ERROR: #{record.errors.to_a.join(', ')}"
          @error_records << record
        end
      end
    end
    return "#{@changes.size} records imported, #{@error_records.size} failed, #{import_rows.size - @changes.size - @error_records.size} skipped"
  end
  
  private
  
  def self.field2column(field_name)
    field_name.gsub('ø', 'o').gsub('Ø', 'O').gsub('å', 'a').gsub('Å', 'A').gsub(/[ -.\/]/, '_').downcase
  end
  
  def self.login
    @cookies = []
    url = URI.parse('http://nkfwww.kampsport.no/')
    login_content = nil
    Net::HTTP.start(url.host, url.port) do |http|
      login_form_response = http.get '/portal/page/portal/ks_utv/st_login', cookie_header
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
      login_form_fields += [['site2pstoretoken', token], ['ssousername', '40001062'], ['password', 'KS2006']]
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
    puts "#{@cookies.size}:"
    pp @cookies
  end
  
  def self.cookie_header
    return {} if @cookies.empty?
    {'Cookie' => @cookies.join(';')}
  end
  
  def self.process_response(title, response)
    puts '#' * 80
    puts "#{title}: #{response.code.inspect}"
    puts '*' * 80
    response.each_header do |h|
      p h
    end
    puts '*' * 80
    puts @iconv.iconv(response.body)
    puts '*' * 80
    store_cookie(response)
    
    if response.code == '302'
      puts "Following redirect to #{response['location']}"
      url = URI.parse(response['location'])
      Net::HTTP.start(url.host, url.port) do |http|
        redirect_response = http.get "#{url.path}?#{url.query}", cookie_header
        process_response 'redirect', redirect_response
      end
    end
  end
  
end