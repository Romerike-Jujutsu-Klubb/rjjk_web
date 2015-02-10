# encoding: utf-8
require 'test_helper'

class AttendanceFormTest < ActionDispatch::IntegrationTest
  def test_index
    login_and_visit '/'
    click_link 'Oppmøtelister'
    assert_current_path '/attendances/form_index'
    screenshot('attendance/form/index')
    find('#group_name_Panda').click
    sleep 0.5
    screenshot('attendance/form/index_select_panda')
    find('#group_name_Tiger').click
    sleep 0.5
    screenshot('attendance/form/index_select_tiger')
    find('#group_name_Voksne').click
    sleep 0.5
    screenshot('attendance/form/index_select_voksne')
  end

  def test_select_panda_october
    visit_with_login '/attendances/form_index'
    select('Oktober 2013', from: 'group_name_Panda')
    assert_current_path "/attendances/form/2013/10/#{groups(:panda).id}"
    assert_equal ['Uwe Kubosch',
            'Totalt 1',
            'Lars Bråten',
            'Erik Hansen MyString',
            'Hans Eriksen faktura@eriksen.org',
            'Totalt 3'], all('tr td:first-child').map(&:text).reject(&:blank?)
  end

  def test_record_panda_october
    visit_with_login "/attendances/form/2013/10/#{groups(:panda).id}"
    assert_equal ['Uwe Kubosch',
            'Totalt 1',
            'Lars Bråten',
            'Erik Hansen MyString',
            'Hans Eriksen faktura@eriksen.org',
            'Totalt 3'], all('tr td:first-child').map(&:text).reject(&:blank?)

    uwe_row = find('table:first-of-type tbody tr:first-of-type')
    assert uwe_row
    assert_equal ['Uwe Kubosch', '42', 'svart', '', '', 'P', '', '', '1 / 1'],
        uwe_row.all('td').map(&:text)
    assert_difference 'Attendance.count' do
      uwe_row.find('td:nth-of-type(4)').find('a').click
      uwe_row.find('td:nth-of-type(4)').find('a', :text => 'X')
    end

    # Attendance 'X' NOT present
    lars_row = find('table:first-of-type tbody tr:nth-of-type(5)')
    assert lars_row
    assert_equal ['Lars Bråten', '46', 'brunt', '', 'X', '', '', '', '1 / 2'],
        lars_row.all('td').map(&:text)

    # Mark Lars as present
    new_instructor_row = find('table:first-of-type tbody tr:nth-of-type(2)')
    assert new_instructor_row
    assert_equal ['', '', '', '', '', '', ''],
        new_instructor_row.all('td').map(&:text)
    assert_difference 'Attendance.count' do
      new_instructor_row.find('td:nth-of-type(2)').click
      assert_equal '/attendances/new', current_path
      select('Lars Bråten', from: 'attendance_member_id')
      click_button('Create')
      assert_equal "/attendances/form/2013/10/#{groups(:panda).id}", current_path

      # Attendance 'X' present
      lars_row = find('table:first-of-type tbody tr:nth-of-type(5)')
      assert lars_row
      assert_equal ['Lars Bråten', '46', 'brunt', 'X', 'X', '', '', '', '2 / 3'],
          lars_row.all('td').map(&:text)
      lars_row.find('td:nth-of-type(4)').find('a', text: 'X')
    end

    assert_difference 'TrialAttendance.count' do
      erik_row = find('table:first-of-type tbody tr:nth-of-type(6)')
      assert erik_row
      assert_equal ['Erik Hansen MyString', '7',
              'Prøvetid til 2010-10-17 Mangler kontrakt', '', '', '', '', '', ''],
          erik_row.all('td').map(&:text)
      assert_difference 'TrialAttendance.count' do
        erik_row.find('td:nth-of-type(4)').find('a').click
        erik_row.find('td:nth-of-type(4)').find('a', :text => 'X')
      end
    end
    assert_difference 'TrialAttendance.count' do
      hans_row = find('table:first-of-type tbody tr:nth-of-type(7)')
      assert hans_row
      assert_equal ['Hans Eriksen faktura@eriksen.org', '6',
              'Prøvetid til 2010-10-17 Mangler kontrakt', '', '', 'X', '', '', '2'],
          hans_row.all('td').map(&:text)
      assert_difference 'TrialAttendance.count' do
        hans_row.find('td:nth-of-type(4)').find('a').click
        hans_row.find('td:nth-of-type(4)').find('a', :text => 'X')
      end
    end
  end

end
