require 'net/http'
require 'uri'
require 'erb'

class NkfMemberImport
  def self.import
    @changes = []
    @error_records = []
    
    iconv = Iconv.new('UTF8', 'ISO-8859-1')

    url = URI.parse('http://nkfwww.kampsport.no/')
    import_rows = nil
    Net::HTTP.start(url.host, url.port) do |http|
      active_members_response = http.get("/portal/pls/portal/myports.ks_reg_medladm_proc.download?p_cr_par=DBD1D4C6CD9CD9B1909E99A992D9ABCFD5D7A59297A8C5D967D299CCA39F89D2CBD4A7D1DCCAA79AA26A6890D4C39DABEBA9D6D4EF98E3CDD0D3D6DED8CAE6DCDEAF918BDE92E0DDC2D6D77659DAD9DCCDE6DCC0DF99D3CF7299A0C7CCD7D5D5E0C4E2D3E0CBA78FE296A4D8C3D7AC98DBA999D1D8D8E2D2D7CBD8DFD3A698D7CAD8D0C9E297D6E8D2CCD6A8A0DADBE2D1B0A587E197D6DD94D861C7CFD2A088DCC4DBE4D2CFCEA69F685ADAC3C59C92E0D0B087E9D1E3D7C2D0DBA88AD9D1D7DED1CAC9AB59E5D3CCDBE1A698D6DEE4CBD6D7CEE199D8CF72B056D8C5D7D1D0D9CAE0D6E7CACBDDE1745ADAC3D9ACA0DCD8D7D5D8D5E2DBD3C8E9D0A1A698D7CAE7D5D2D39FD9E8C7CEE7A87090EACFDBA6C7D1DC97CFCE72A4669A96A49192A193A6A2A39FA499A37164A3969A6B67B0A4")
      import_rows = active_members_response.body.split("\n").map{|line| iconv.iconv(line.chomp).split(';')}
    end
    
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
    return "#{@changes.size} records imported, #{@error_records.size} failed, #{import_rows.size - @changes.size - @error_records.size} skipped"
  end
  
  private
  
  def self.field2column(field_name)
    field_name.gsub('ø', 'o').gsub('Ø', 'O').gsub('å', 'a').gsub('Å', 'A').gsub(/[ -.\/]/, '_').downcase
  end
  
end
