require 'net/http'
require 'uri'
require 'erb'

class NkfMemberImport
  def self.import
    @changes = []
    @error_records = []
    iconv = Iconv.new('UTF8', 'ISO-8859-1')
    import_rows = File.readlines('Medlemsliste.csv').map{|line| iconv.iconv(line.chomp).split(';')}
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
        p record.changes
        if record.save
          @changes << record.changes
        else
          puts "ERROR: #{record.errors.to_a.join(', ')}"
          @error_records << record
        end
      end
    end
    puts "#{@changes.size} records imported, #{@error_records.size} failed, #{import_rows.size - @changes.size - @error_records.size} skipped"
  end
  
  private
  
  def self.field2column(field_name)
    field_name.gsub('ø', 'o').gsub('Ø', 'O').gsub('å', 'a').gsub('Å', 'A').gsub(/[ -.\/]/, '_').downcase
  end
  
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
