require 'test_helper'

class PublicRecordImporterTest < ActionMailer::TestCase
  def test_import_public_record
    assert_difference('PublicRecord.count') do
      PublicRecordImporter.import_public_record
    end

    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][test] Ny informasjon registrert i Brønnøysund', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{Ny informasjon registrert i Brønnøysund.*Hei Uwe!.*Her er oppdatert informasjon fra Brønnøysundregisteret:.*Kontaktperson:.*Anita Tveter.*Styreleder:.*Anita Tveter.*Styremedlemmer:.*Lars Erling Bråten.*Henning Løvstad.*Kaija Wergeland Østnes.*Fratrådt.*Varamedlemmer:.*Hans Petter Skolsegg.*Svein Robert Rolijordet}m, mail.body.decoded
  rescue SocketError
  end
end
