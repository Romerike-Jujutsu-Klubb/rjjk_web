# frozen_string_literal: true

require 'application_system_test_case'

class AttendanceFormFeatureTest < ApplicationSystemTestCase
  setup { screenshot_section :attendance }

  def test_index
    screenshot_group :form
    login_and_visit '/'
    click_menu('Oppmøte', section: 'Instruksjon')
    assert_current_path attendance_forms_path
    click_on('Panda')
    screenshot :select_panda
    click_on('Tiger')
    screenshot :select_tiger
    click_on('Voksne')
    screenshot :select_voksne
  end

  def test_select_panda_october
    visit_with_login attendance_forms_path
    find('.nav-link', text: 'Panda').click
    click_on('Liste')
    assert_current_path attendance_form_path year: 2013, month: 10, group_id: id(:panda)
    assert has_css? 'tr td:first-child'
    assert_equal ['Uwe Kubosch',
                  'Lars Bråten',
                  'Erik Hansen',
                  'Hans Eriksen',
                  'Totalt 3',
                  'Sebastian Kubosch (Permisjon)',
                  'Totalt 1'],
        all('tr td:first-child').map(&:text).reject(&:blank?)
  end

  def test_record_panda_october
    visit_with_login attendance_form_path year: 2013, month: 10, group_id: id(:panda)
    assert_equal ['Uwe Kubosch',
                  'Lars Bråten', 'Erik Hansen', 'Hans Eriksen', 'Totalt 3',
                  'Sebastian Kubosch (Permisjon)', 'Totalt 1'],
        all('tr td:first-child').map(&:text).reject(&:blank?)

    uwe_row = first('table tbody tr')
    assert uwe_row
    assert_equal ['Uwe Kubosch', '42', 'svart belte', '', '', 'P', '', ''], # , '1 / 1'],
        uwe_row.all('td').map(&:text).map(&:strip)
    assert_difference 'Attendance.count' do
      uwe_row.find('td:nth-of-type(4)').find('a').click
      uwe_row.find('td:nth-of-type(4)').find('a', text: 'X')
    end

    # Attendance 'X' NOT present
    lars_row = find('table#members tbody tr:nth-of-type(1)')
    assert lars_row
    assert_equal ['Lars Bråten', '46', 'brunt belte', '', 'X', '', '', ''], # , '1 / 2'],
        lars_row.all('td').map(&:text).map(&:strip)

    # Mark Lars as present
    new_instructor_row = first('table tbody tr:nth-of-type(2)')
    assert new_instructor_row
    assert_equal ['', '', '', '', '', ''], new_instructor_row.all('td').map(&:text).map(&:strip)
    assert_difference 'Attendance.count' do
      new_instructor_row.find('td:nth-of-type(2)').click
      assert_current_path '/attendances/new', ignore_query: true
      select_from_chosen('Lars Bråten', from: 'attendance_user_id')
      click_button('Lagre')
      assert_current_path attendance_form_path year: 2013, month: 10, group_id: id(:panda)

      # Attendance 'X' present
      lars_row = find('table#members tbody tr:nth-of-type(1)')
      assert lars_row
      assert_equal ['Lars Bråten', '46', 'brunt belte', 'X', 'X', '', '', ''],
          lars_row.all('td').map(&:text).map(&:strip)
      lars_row.find('td:nth-of-type(4)').find('a', text: 'X')
    end

    assert_difference 'Attendance.count' do
      erik_row = find('table#members tbody tr:nth-of-type(2)')
      assert erik_row
      assert_equal(['Erik Hansen', '7', 'Prøvetid til 2010-10-17 Mangler kontrakt', '', '', '', '', ''],
          erik_row.all('td').map(&:text).map(&:strip).map { |s| s.gsub(/\s+/, ' ') })
      assert_difference 'Attendance.count' do
        erik_row.find('td:nth-of-type(4)').find('a').click
        erik_row.find('td:nth-of-type(4)').find('a', text: 'X')
      end
    end

    assert_difference 'Attendance.count' do
      hans_row = find('table#members tbody tr:nth-of-type(3)')
      assert hans_row
      assert_equal(['Hans Eriksen', '6', 'Prøvetid til 2010-10-17 Mangler kontrakt', '', '', 'X', '', ''],
          hans_row.all('td').map(&:text).map(&:strip).map { |s| s.gsub(/\s+/, ' ') })
      assert_difference 'Attendance.count' do
        hans_row.find('td:nth-of-type(4)').find('a').click
        hans_row.find('td:nth-of-type(4)').find('a', text: 'X')
      end
    end
  end
end
