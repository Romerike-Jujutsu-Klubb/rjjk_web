require 'net/http'
require 'uri'

class CmsImport
  def self.import
    url = URI.parse('http://62.92.243.194:8000/')

    import_rows = nil
    user_responses = {}
    user_fields = {}

    Net::HTTP.start(url.host, url.port) {|http|
      login_form_response = http.get('/WebDebtCollection/')
      login_form_fields = login_form_response.body.scan /<input .*?name="(.*?)".*?value="(.*?)".*?>/
      login_form_fields += [['txtUsername', 'rjjk'], ['txtPassword', 'rjjk2055']]
      login_params = login_form_fields.map{|field|"#{field[0]}=#{ERB::Util.url_encode field[1]}"}.join('&')
      login_response = http.post('/WebDebtCollection/Default.aspx', login_params)
      #header = login_response.header
      #cookie = header['set-cookie']
      #puts
      #puts login_response.body
      #puts
      raise "Wrong URL" unless login_response.code == "200"
      session_cookie = login_response['set-cookie']
      raise "Missing session cookie" unless session_cookie
      #puts "Cookie:"
      #p session_cookie
      #session_cookie_class = login_response['set-cookie'].class
      list_response = http.get("/WebDebtCollection/generic.aspx?cat=1&o=1&g=con", {'Cookie' => session_cookie})
    
      active_members_report = list_response.body
      import_rows = active_members_report.scan(/<tr.*?>.*?<\/tr>/m).map do |row|
        cells = row.scan(/<td.*?>(.*?)<\/td>/m)
        cells.map! {|cell| cell[0]}
        cells.map! {|cell| cell =~ /<a.*?>(.*?)<\/a>/ ? $1 : cell}
        cells.map! {|cell| cell.strip.gsub('&AElig;', 'Æ').gsub('&aelig;', 'æ').gsub('&Oslash;', 'Ø').gsub('&oslash;', 'ø').gsub('&Aring;', 'Å').gsub('&aring;', 'å')}
      end
      import_rows.shift
    
      import_rows.each do |fields|
        cms_contract_id = fields[1]
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

    @new_members = []
    @updated_members = []
    import_rows.each do |fields|
      cms_contract_id = fields[1]
      detail_fields = user_fields[cms_contract_id]
      member = Member.find_by_cms_contract_id(cms_contract_id)
      member = Member.new(:department => 'Jujutsu', :instructor => false) if member.nil?
      old_values = member.attributes
      new_contract_birthdate = (detail_fields[38].empty? || detail_fields[38] == '--' ? nil : Date.strptime(detail_fields[38], '%d%m%y'))
      phone_pattern = '(?:\d| )+'
      debitor_contact_pattern = /(.*?)<br \/>Att: <br \/>(.*?)<br \/>(\d*?) (.*?)/
      contract_contact_pattern = /(.*?)<br \/>(.*?)<br \/>(.*?) .*?<br \/>/
p detail_fields[29]
p detail_fields[29] =~ debitor_contact_pattern && $1
p detail_fields[29] =~ debitor_contact_pattern && $2
p detail_fields[29] =~ debitor_contact_pattern && $3
      new_values = {
        :first_name => fields[3].split(' ')[1..-1].join(' '),
        :last_name => fields[3].split(' ').first,
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
  
end
