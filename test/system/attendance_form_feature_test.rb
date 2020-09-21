# frozen_string_literal: true

require 'application_system_test_case'

class AttendanceFormFeatureTest < ApplicationSystemTestCase
  setup do
    screenshot_section :attendance
  end
  def test_index
    screenshot_group :form
    login_and_visit '/'
    click_menu('Oppmøte', section: 'Instruksjon')
    assert_current_path attendance_forms_path
    find('#lists-tab').click
    screenshot :index
    find('#group_name_Panda').click
    screenshot :index_select_panda
    find('#group_name_Tiger').click
    screenshot :index_select_tiger
    find('#group_name_Voksne').click
    screenshot :index_select_voksne
  end

  def test_select_panda_october
    visit_with_login attendance_forms_path(anchor: :lists_tab)
    select('Oktober 2013', from: 'group_name_Panda')
    assert_current_path attendance_form_path year: 2013, month: 10, group_id: id(:panda)
    assert has_css? 'tr td:first-child'
    assert_equal ["Uwe Kubosch\n5556666",
                  'Totalt 1',
                  'Lars Bråten',
                  "Erik Hansen\nNKF_mt_two@example.com",
                  "Even Jensen\nNKF_mt_three@example.com",
                  "Hans Eriksen\nfaktura@eriksen.org",
                  'Totalt 4',
                  "Sebastian Kubosch (Permisjon)\n98765432 / 5556666",
                  'Totalt 1'],
        all('tr td:first-child').map(&:text).reject(&:blank?)
  end

  def test_record_panda_october
    visit_with_login attendance_form_path year: 2013, month: 10, group_id: id(:panda)
    assert_equal ["Uwe Kubosch\n5556666",
                  'Totalt 1',
                  'Lars Bråten',
                  "Erik Hansen\nNKF_mt_two@example.com",
                  "Even Jensen\nNKF_mt_three@example.com",
                  "Hans Eriksen\nfaktura@eriksen.org",
                  'Totalt 4',
                  "Sebastian Kubosch (Permisjon)\n98765432 / 5556666",
                  'Totalt 1'],
        all('tr td:first-child').map(&:text).reject(&:blank?)

    uwe_row = find('table:first-of-type tbody tr:first-of-type')
    assert uwe_row
    assert_equal ["Uwe Kubosch\n5556666", '42', 'svart belte', '', '', 'P', '', ''], # , '1 / 1'],
        uwe_row.all('td').map(&:text).map(&:strip)
    assert_difference 'Attendance.count' do
      uwe_row.find('td:nth-of-type(4)').find('a').click
      uwe_row.find('td:nth-of-type(4)').find('a', text: 'X')
    end

    # Attendance 'X' NOT present
    lars_row = find('table:first-of-type tbody tr:nth-of-type(5)')
    assert lars_row
    assert_equal ['Lars Bråten', '46', 'brunt belte', '', 'X', '', '', ''], # , '1 / 2'],
        lars_row.all('td').map(&:text).map(&:strip)

    # Mark Lars as present
    new_instructor_row = find('table:first-of-type tbody tr:nth-of-type(2)')
    assert new_instructor_row
    assert_equal ['', '', '', '', '', '', ''],
        new_instructor_row.all('td').map(&:text).map(&:strip)
    assert_difference 'Attendance.count' do
      new_instructor_row.find('td:nth-of-type(2)').click
      assert_current_path '/attendances/new', ignore_query: true
      select('Lars Bråten', from: 'attendance_member_id')
      click_button('Lagre')
      assert_current_path attendance_form_path year: 2013, month: 10, group_id: id(:panda)

      # Attendance 'X' present
      lars_row = find('table:first-of-type tbody tr:nth-of-type(5)')
      assert lars_row
      assert_equal ['Lars Bråten', '46', 'brunt belte', 'X', 'X', '', '', ''], # , '2 / 3'],
          lars_row.all('td').map(&:text).map(&:strip)
      lars_row.find('td:nth-of-type(4)').find('a', text: 'X')
    end

    assert_difference 'TrialAttendance.count' do
      erik_row = find('table:first-of-type tbody tr:nth-of-type(6)')
      assert erik_row
      assert_equal(['Erik Hansen NKF_mt_two@example.com', '7',
                    'Prøvetid til 2010-10-17 Mangler kontrakt', '', '', '', '', ''], # , ''],
          erik_row.all('td').map(&:text).map(&:strip).map { |s| s.gsub(/\s+/, ' ') })
      assert_difference 'TrialAttendance.count' do
        erik_row.find('td:nth-of-type(4)').find('a').click
        erik_row.find('td:nth-of-type(4)').find('a', text: 'X')
      end
    end
    assert_difference 'TrialAttendance.count' do
      hans_row = find('table:first-of-type tbody tr:nth-of-type(8)')
      assert hans_row
      assert_equal(['Hans Eriksen faktura@eriksen.org', '6',
                    'Prøvetid til 2010-10-17 Mangler kontrakt', '', '', 'X', '', ''], # , '2'],
          hans_row.all('td').map(&:text).map(&:strip).map { |s| s.gsub(/\s+/, ' ') })
      assert_difference 'TrialAttendance.count' do
        hans_row.find('td:nth-of-type(4)').find('a').click
        hans_row.find('td:nth-of-type(4)').find('a', text: 'X')
      end
    end
  end
end
