# frozen_string_literal: true
require 'nokogiri'
require 'open-uri'

# http://hotell.difi.no/api/json/brreg/enhetsregisteret?orgnr=982452716

class PublicRecordImporter
  URL = 'http://w2.brreg.no/enhet/sok/detalj.jsp?orgnr=982452716'

  def self.import_public_record
    doc = Nokogiri::HTML(open(URL))
    record = PublicRecord.where(contact: find_field(doc, 'Kontaktperson'),
        chairman: find_field(doc, 'Styrets leder'),
        board_members: find_field(doc, 'Nestleder') + find_field(doc, 'Styremedlem'),
        deputies: find_field(doc, 'Varamedlem'))
        .first_or_initialize
    if record.new_record?
      record.save!
      PublicRecordMailer.new_record(record).store(Role[:Leder], tag: :new_public_record)
    end
  end

  def self.find_field(doc, name)
    found = false
    doc.css('tr').map do |row|
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
  end
end
