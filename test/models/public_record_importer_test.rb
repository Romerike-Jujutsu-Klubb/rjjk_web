require 'test_helper'

class PublicRecordImporterTest < ActionMailer::TestCase
  def test_import_public_record
    assert_difference('PublicRecord.count') do
      VCR.use_cassette 'BRREG' do
        assert_mail_stored 1 do
          PublicRecordImporter.import_public_record
        end
      end
    end

    mail = UserMessage.pending[0]
    assert_equal 'Ny informasjon registrert i Brønnøysund', mail.subject
    assert_equal ["\"Uwe Kubosch\" <admin@test.com>"], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_match(/Hei Uwe!.*Her er oppdatert informasjon fra Brønnøysundregisteret:.*Kontaktperson:.*Svein Robert Rolijordet.*Styreleder:.*Svein Robert Rolijordet.*Styremedlemmer:.*Trond Even Evensen.*Katarzyna Anna Krohn.*Torstein Norum Resløkken.*Varamedlemmer:.*Lars Erling Bråten.*Curt Birger Holm Mekiassen/m,
        mail.body)
  rescue SocketError
  end
end
