require 'nokogiri'
require 'open-uri'

class PublicRecordImporter
  def self.import_public_record
    doc = Nokogiri::HTML(open('http://w2.brreg.no/enhet/sok/detalj.jsp?orgnr=982452716'))
    record = PublicRecord.where(:contact => find_field(doc, 'Kontaktperson'),
                                :chairman => find_field(doc, 'Styrets leder'),
                                :board_members => find_field(doc, 'Styremedlem'),
                                :deputies => find_field(doc, 'Varamedlem')).
        first_or_initialize
    if record.new_record?
      record.save!
      PublicRecordMailer.new_record(record).deliver
    end
  rescue Exception
    raise if Rails.env.test?
    logger.error 'Execption importing public record.'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  private

  def self.find_field(doc, name)
    found = false
    chairman = doc.css('tr').map do |row|
      cells = row.css('td')
      unless cells.size == 2
        found = false
        next
      end
      unless cells[0].content =~ /#{name}:/ || (found && cells[0].content.strip.empty?)
        found = false
        next
      end
      found = true
      cells[1].content.strip
    end.compact.join("\n")
    chairman
  end
end
