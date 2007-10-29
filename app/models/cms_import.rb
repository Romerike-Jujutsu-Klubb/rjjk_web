require 'net/http'
require 'uri'

class CmsImport
  def self.import
    report_files = {"Medlemsliste_1" => "475","Medlemsliste_2" => "461", "Medlemsliste_3" => "476","Medlemsliste_4" => "464"}
    
    url = URI.parse('http://cmsnorge.com/cms/login.php?bruker=rjjk&pass=rjjk2055')
    responses = {}
    
    Net::HTTP.start(url.host, url.port) {|http|
      login_response = http.get('/cms/login.php?bruker=rjjk&pass=rjjk2055')
      header = login_response.header
      cookie = header['set-cookie']
      session_cookie = login_response['set-cookie']
      session_cookie_class = login_response['set-cookie'].class
      report_files.each do |file, report_number|
        responses[file] = http.get("/cms/rapp_egenxls.php?id=#{report_number}", {'Cookie' => session_cookie})
        puts responses[file].body
      end
    }
    
    reports = []
     (1..4).each do |index|
      report = responses["Medlemsliste_#{index}"].body
      
      reports[index] = report.scan(/<(?:ss:)?Row>.*?<\/(?:ss:)?Row>/m).map do |xml_row|cells = xml_row.scan(/<ss:Cell>\s*?<ss:Data ss:Type=".*?">\s*?(.*?)\s*?<\/ss:Data>\s*?<\/ss:Cell>/m)
        cells.map {|cell| cell[0].strip.gsub('&AElig;', 'Æ').gsub('&aelig;', 'æ').gsub('&Oslash;', 'Ø').gsub('&oslash;', 'ø').gsub('&Aring;', 'Å').gsub('&aring;', 'å')}
      end
      reports[index].shift
    end
    
    raise "Report sizes differ: #{reports[1..-1].map{|r|r.size}.join(', ')}" if reports.find {|report| report && report.size != reports[1].size}
    
    puts "reports: #{reports.size-1}"
    puts "rows: #{reports[1].size}"
    
     (0...reports[1].size).each do |index|
      member = Member.find_by_cms_contract_id(reports[1][index][0])
      member = Member.new if member.nil?
      old_values = member.attributes
      new_values = {
        :first_name => reports[3][index][7].split(' ')[1..-1].join(' '),
        :last_name => reports[3][index][7].split(' ').first,
        :senior => (reports[4][index][7].empty? ? true : ((Date.today - Date.strptime(reports[4][index][7], '%d-%m-%Y')) / 365) > 15),
        :email => reports[2][index][8],
        :phone_mobile => reports[4][index][5],
        :phone_home => reports[4][index][4],
        :phone_work => nil,
        :phone_parent => nil,
        :birtdate => (reports[4][index][7].empty? ? nil : Date.strptime(reports[4][index][7], '%d-%m-%Y')),
        :social_sec_no => reports[3][index][4],
        :male => reports[4][index][6] == 'M',
        :joined_on => reports[1][index][1].empty? ? nil : Date.strptime(reports[1][index][1], '%d-%m-%Y'),
        :contract_id => reports[3][index][6],
        :department => 'Jujutsu',
        :cms_contract_id => reports[1][index][0],
        :left_on => (reports[1][index][2].empty? ? nil : Date.strptime(reports[1][index][2], '%d-%m-%Y')),
        :parent_name => (reports[2][index][3] != reports[3][index][7] ? reports[2][index][3] : nil),
        :address => reports[3][index][9],
        :postal_code => reports[4][index][1],
        :billing_type => reports[2][index][1] == 'J' ? 'AUTOGIRO' : 'MANUELL GIRO',
        :billing_name => reports[2][index][3],
        :billing_address => reports[2][index][5],
        :billing_postal_code => reports[2][index][6],
        :billing_phone_home => reports[2][index][9],
        :billing_phone_mobile => reports[3][index][1],
        :account_no => reports[3][index][5],
        :payment_problem => false,
        :comment => reports[1][index][4],
        :instructor => false,
        :nkf_fee => true
      }
      changes = new_values.clone.delete_if {|k, v| v.to_s == old_values[k.to_s].to_s}
      if changes.size > 0
        message = "#{member.new_record? ? 'Adding' : 'Updating'} member: #{member.first_name} #{member.last_name}\n#{changes.inspect}"
        puts message
        Member.logger.info message
        member.update_attributes(changes)
        member.save!
      end
    end
  end
  
end
