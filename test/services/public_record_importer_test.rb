# frozen_string_literal: true

require 'test_helper'

class PublicRecordImporterTest < ActionMailer::TestCase
  def test_import_public_record
    assert_difference('PublicRecord.count') do
      VCR.use_cassette 'BRREG' do
        assert_mail_stored do
          PublicRecordImporter.import_public_record
        end
      end
    end

    mail = UserMessage.pending[0]
    assert_equal 'Ny informasjon registrert i Brønnøysund', mail.subject
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match(/Hei Uwe!.*Her er oppdatert informasjon fra Brønnøysundregisteret:.*Kontaktperson:.*Svein Robert Rolijordet.*Styreleder:.*Svein Robert Rolijordet.*Styremedlemmer:.*Trond Even Evensen.*Katarzyna Anna Krohn.*Torstein Norum Resløkken.*Varamedlemmer:.*Lars Erling Bråten.*Curt Birger Holm Mekiassen/m, # rubocop: disable Metrics/LineLength
        mail.body)
  end
end
