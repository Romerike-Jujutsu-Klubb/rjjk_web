require 'test_helper'

class NkfAppointmentsScraperTest < ActiveSupport::TestCase
  test 'import_appointments' do
    VCR.use_cassette('NKF Import Appointments') do
      a = NkfAppointmentsScraper.import_appointments
      assert a
      assert_equal 7, a.size
      assert_equal 1, a.select { |app| app.class == Appointment }.size
    end
  end
end
