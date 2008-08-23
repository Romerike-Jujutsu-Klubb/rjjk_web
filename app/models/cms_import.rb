require 'net/http'
require 'uri'
require 'erb'

class CmsImport
  def self.import
    url = URI.parse('http://62.92.243.194:8000/')

    cms_contract_ids = nil
    user_responses = {}
    user_fields = {}

    Net::HTTP.start(url.host, url.port) {|http|
      session_cookie = login http
      active_members_response = http.get("/WebDebtCollection/generic.aspx?cat=1&o=1&g=con", {'Cookie' => session_cookie})
      active_members_report = active_members_response.body
      import_rows = active_members_report.scan(/<tr.*?>.*?<\/tr>/m).map do |row|
        cells = row.scan(/<td.*?>(.*?)<\/td>/m)
        cells.map! {|cell| cell[0]}
        cells.map! {|cell| cell =~ /<a.*?>(.*?)<\/a>/ ? $1 : cell}
        cells.map! {|cell| cell.strip.gsub('&AElig;', 'Æ').gsub('&aelig;', 'æ').gsub('&Oslash;', 'Ø').gsub('&oslash;', 'ø').gsub('&Aring;', 'Å').gsub('&aring;', 'å')}
      end
      import_rows.shift
      cms_contract_ids = import_rows.map{|r|r[1]}
      puts "Found #{cms_contract_ids.size} active members"

      contracts_report_pattern = %q{<tr><td class="report_drilled_cell" style="width:4%; text-align:center;">(.*?)</td><td class="report_drilled_cell" style="width:4%; text-align:center;">(.*?)</td><td class="report_drilled_cell" style="width:5%; text-align:center;">(.*?)</td><td class="report_drilled_cell" style="width:14%; text-align:left;">(.*?)</td><td class="report_drilled_cell" style="width:12%; text-align:left;">(.*?)</td><td class="report_drilled_cell" style="width:4%; text-align:left;">(.*?)</td><td class="report_drilled_cell" style="width:7%; text-align:left;">(.*?)</td><td class="report_drilled_cell" style="width:6%; text-align:left;">(.*?)</td><td class="report_drilled_cell" style="width:9%; text-align:left;">(.*?)</td><td class="report_drilled_cell" style="width:4%; text-align:center;">(.*?)</td><td class="report_drilled_cell" style="width:5%; text-align:center;">(.*?)</td><td class="report_drilled_cell" style="width:5%; text-align:center;">(.*?)</td><td class="report_drilled_cell" style="width:6%; text-align:left;">(.*?)</td><td class="report_drilled_cell" style="width:9%; text-align:center;">(.*?)</td><td class="report_drilled_cell" style="width:6%; text-align:left;">(.*?)</td></tr>}
      all_contracts_response = http.get("/WebDebtCollection/reporting/contracts.aspx", {'Cookie' => session_cookie})
      event_target = 'btnRefresh'
      event_argument = ''
      view_state = all_contracts_response.body.scan(/<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)" \/>/)[0][0]
      previous_page = all_contracts_response.body.scan(/<input type="hidden" name="__PREVIOUSPAGE" id="__PREVIOUSPAGE" value="(.*?)" \/>/)[0][0]
      event_validation = all_contracts_response.body.scan(/<input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="(.*?)" \/>/)[0][0]

      all_contracts_response = http.post("/WebDebtCollection/reporting/contracts.aspx?update=true", "__EVENTTARGET=#{event_target}&__EVENTARGUMENT=#{event_argument}&__VIEWSTATE=#{ERB::Util.url_encode view_state}&txtRegFromDate=1.1.1981&txtRegToDate=#{Date.today.strftime '%d.%m.%Y'}&txtAgeFrom=&txtAgeTo=&drpGender=0&drpCurrentStatus=0&drpArt=0&drpParti=0&__PREVIOUSPAGE=#{ERB::Util.url_encode previous_page}&__EVENTVALIDATION=#{ERB::Util.url_encode event_validation}", {'Cookie' => session_cookie, 'Content-Type' => 'application/x-www-form-urlencoded', 'Referer' => 'http://62.92.243.194:8000/WebDebtCollection/reporting/contracts.aspx?update=true'})

      all_contracts_lines = all_contracts_response.body.scan /#{contracts_report_pattern}/
      cms_contract_ids = all_contracts_lines.map{|l| l[9]}
      puts "Found #{cms_contract_ids.size} members"

      cms_contract_ids.each do |cms_contract_id|
        user_responses[cms_contract_id] = http.get("/WebDebtCollection/generic.aspx?det=#{cms_contract_id}&o=1&g=con", {'Cookie' => session_cookie})
        body = user_responses[cms_contract_id].body
        cells = body.scan(/<td.*?>(.*?)<\/td>/m)
        cells.map! {|cell| cell[0]}
        cells.map! {|cell| cell.gsub(/<a.*?>(.*?)<\/a>/, '\1')}
        cells.map! {|cell| cell.gsub(/<b>(.*?)<\/b>/, '\1')}
        cells.map! {|cell| cell.gsub(/ <br \/>$/, '')}
        cells.map! {|cell| cell.gsub('&nbsp;', '')}
        cells.map! {|cell| cell.strip.gsub('&AElig;', 'Æ').gsub('&aelig;', 'æ').gsub('&Oslash;', 'Ø').gsub('&oslash;', 'ø').gsub('&Aring;', 'Å').gsub('&aring;', 'å')}
        user_fields[cms_contract_id] = cells
      end
    }

    puts "Found #{cms_contract_ids.size} members"
    puts "Found #{cms_contract_ids.select {|m| user_fields[m][64].empty?}.size} active members"
    @new_members = []
    @updated_members = []
    cms_contract_ids.each do |cms_contract_id|
      detail_fields = user_fields[cms_contract_id]
      member = Member.find_by_cms_contract_id(cms_contract_id)
      member = Member.new(:department => 'Jujutsu', :instructor => false) if member.nil?
      old_values = member.attributes
      new_contract_birthdate = (detail_fields[38].empty? || detail_fields[38] == '--' ? nil : Date.strptime(detail_fields[38], '%d%m%y'))
      phone_pattern = '(?:\d| )+'
      debitor_contact_pattern = /(.*?)<br \/>Att: <br \/>(.*?)<br \/>(\d*?) (.*?)/
      contract_contact_pattern = /(.*?)<br \/>(.*?)<br \/>(.*?) .*?<br \/>/
      new_values = {
        :first_name => detail_fields[41] =~ contract_contact_pattern && $1.split(' ')[1..-1].map{|n|n.capitalize}.join(' '),
        :last_name => detail_fields[41] =~ contract_contact_pattern && $1.split(' ').first.capitalize,
        :birtdate => new_contract_birthdate,
        :senior => (new_contract_birthdate.nil? ? true : ((Date.today - new_contract_birthdate) / 365) > 15),
        :email => detail_fields[41] =~ /([^>]*)\s*\(e-post\)<br \/>/ && ($1.strip != '--' ? $1.strip : nil),
        :phone_mobile => detail_fields[41] =~ /(#{phone_pattern})\s*\(mobil\)/ && $1.gsub(' ', ''),
        :phone_home => detail_fields[41] =~ /(#{phone_pattern})\s*\(privat\)/ && $1.gsub(' ', ''),
        :phone_work => nil,
        :phone_parent => nil,
        :social_sec_no => old_values[:social_security_number],
        :male => (detail_fields[43] =~ /^M$/) == 0,
        :joined_on => detail_fields[58].empty? ? nil : Date.strptime(detail_fields[58], '%d.%m.%Y'),
        :contract_id => detail_fields[8],
        :cms_contract_id => detail_fields[11],
        :left_on => (detail_fields[64].empty? ? nil : Date.strptime(detail_fields[64], '%d.%m.%Y')),
        :parent_name => detail_fields[29] =~ debitor_contact_pattern && $1,
        :address => detail_fields[41] =~ contract_contact_pattern && $2,
        :postal_code => detail_fields[41] =~ contract_contact_pattern && $3,
        :billing_type => detail_fields[79],
        :billing_name => detail_fields[29] =~ debitor_contact_pattern && $1,
        :billing_address => detail_fields[29] =~ debitor_contact_pattern && $2,
        :billing_postal_code => detail_fields[29] =~ debitor_contact_pattern && $3,
#        :billing_phone_home => reports[2][index][9],
#        :billing_phone_mobile => reports[3][index][1],
#        :account_no => reports[3][index][5],
        :payment_problem => false,
#        :comment => reports[1][index][4],
        :nkf_fee => detail_fields[106] == 'J',
      }
      changes = new_values.clone.delete_if {|k, v| v.to_s == old_values[k.to_s].to_s}
      if changes.size > 0
        if member.new_record?
          @new_members << member
        else
          old_values = {}
          changes.keys.each {|k| old_values[k] = member[k]}
          @updated_members << [member, old_values]
        end
        message = "#{member.new_record? ? 'Adding' : 'Updating'} member: #{member.first_name} #{member.last_name}\n#{changes.inspect}"
        Member.logger.info message
        member.update_attributes(changes)
        member.save!
      end
    end
    return @new_members, @updated_members
  end
  
  private
  
  def self.login http
    login_form_response = http.get '/WebDebtCollection/'
    login_form_fields = login_form_response.body.scan /<input .*?name="(.*?)".*?value="(.*?)".*?>/
    login_form_fields = login_form_fields + [['txtUsername', 'rjjk'], ['txtPassword', 'rjjk2055']]
    login_params = login_form_fields.map {|field| "#{field[0]}=#{ERB::Util.url_encode field[1]}"}.join '&'
    login_response = http.post('/WebDebtCollection/Default.aspx', login_params)
    raise "Wrong URL" unless login_response.code == "200"
    session_cookie = login_response['set-cookie']
    raise "Missing session cookie" unless session_cookie
    session_cookie
  end
  
end
