# frozen_string_literal: true

require 'test_helper'

class NkfAppointmentsScraperTest < ActiveSupport::TestCase
  test 'import_appointments' do
    VCR.use_cassette('NKF Import Appointments') do
      a = NkfAppointmentsScraper.import_appointments
      assert a
      assert_equal 9, a.size
      appointments = a.select { |app| app.class == Appointment }
      assert_equal 1, appointments.size
      assert_equal 'Uwe Kubosch', appointments[0].member.user.name
    end
  end
end
