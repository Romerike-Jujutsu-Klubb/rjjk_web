# encoding: utf-8
require 'test_helper'

class PublicRecordImporterTest < ActionMailer::TestCase
  def test_import_public_record
    assert_difference('PublicRecord.count') do
      VCR.use_cassette 'BRREG' do
        assert_mail_deliveries 1 do
          PublicRecordImporter.import_public_record
        end
      end
    end

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Ny informasjon registrert i Brønnøysund', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{Ny informasjon registrert i Brønnøysund.*Hei Uwe!.*Her er oppdatert informasjon fra Brønnøysundregisteret:.*Kontaktperson:.*Svein Robert Rolijordet.*Styreleder:.*Svein Robert Rolijordet.*Styremedlemmer:.*Trond Even Evensen.*Katarzyna Anna Krohn.*Torstein Norum Resløkken.*Varamedlemmer:.*Lars Erling Bråten.*Curt Birger Holm Mekiassen}m,
        mail.body.decoded
  rescue SocketError
  end
end
