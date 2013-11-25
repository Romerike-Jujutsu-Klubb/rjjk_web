require File.expand_path('../test_helper', File.dirname(__FILE__))

class AttendanceFormTest < ActionDispatch::IntegrationTest
  fixtures :all

  def setup
    Capybara.current_session.driver.browser.manage.window.resize_to(1024, 768)
  end

  def test_select_panda_october
    visit_with_login '/attendances/form_index'
    select('Oktober 2013', :from => 'group_name_Panda')
    assert_equal ['Uwe Kubosch',
        'Totalt 1',
        'Lars Bråten',
        'Hans Eriksen faktura@eriksen.org',
        'Totalt 2'], all('tr td:first-child').map(&:text).reject(&:blank?)
  end

  def test_record_panda_october
    visit_with_login "/attendances/form/2013/10/#{groups(:panda).id}"
    assert_equal ['Uwe Kubosch',
        'Totalt 1',
        'Lars Bråten',
        'Hans Eriksen faktura@eriksen.org',
        'Totalt 2'], all('tr td:first-child').map(&:text).reject(&:blank?)

    uwe_row = find('table:first-of-type tbody tr:first-of-type')
    assert uwe_row
    assert_equal ['Uwe Kubosch', '42', '', '', '', 'P', '', '', '1 / 1'],
        uwe_row.all('td').map(&:text)
    assert_difference 'Attendance.count' do
      uwe_row.find('td:nth-of-type(4)').find('a').click
      uwe_row.find('td:nth-of-type(4)').find('a', :text => 'X')
    end

    # Attendance 'X' NOT present
    lars_row = find('table:first-of-type tbody tr:nth-of-type(5)')
    assert lars_row
    assert_equal ['Lars Bråten', '46', 'gult', '', 'X', '', '', '', '1 / 1'],
        lars_row.all('td').map(&:text)

    # Mark Lars as present
    new_instructor_row = find('table:first-of-type tbody tr:nth-of-type(2)')
    assert new_instructor_row
    assert_equal ['', '', '', '', '', '', ''],
        new_instructor_row.all('td').map(&:text)
    assert_difference 'Attendance.count' do
      new_instructor_row.find('td:nth-of-type(2)').click
      assert_equal '/attendances/new', current_path
      select('Lars Bråten', :from => 'attendance_member_id')
      click_button('Create')
      assert_equal "/attendances/form/2013/10/#{groups(:panda).id}", current_path

      # Attendance 'X' present
      lars_row = find('table:first-of-type tbody tr:nth-of-type(5)')
      assert lars_row
      assert_equal ['Lars Bråten', '46', 'gult', 'X', 'X', '', '', '', '2 / 2'],
          lars_row.all('td').map(&:text)
      lars_row.find('td:nth-of-type(4)').find('a', :text => 'X')
    end

    assert_difference 'TrialAttendance.count' do
      hans_row = find('table:first-of-type tbody tr:nth-of-type(6)')
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

  private

  def visit_with_login(path)
    visit path
    if current_path == '/user/login'
      fill_in 'user_login', :with => 'admin'
      fill_in 'user_password', :with => 'atest'
      click_button 'Logg inn'
    end
    assert_equal path, current_path
  end

end
