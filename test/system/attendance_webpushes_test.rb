# frozen_string_literal: true

require 'application_system_test_case'

class AttendanceWebpushesTest < ApplicationSystemTestCase
  setup do
    @attendance_webpush = attendance_webpushes(:one)
    login
  end

  test 'visiting the index' do
    visit attendance_webpushes_path
    assert_selector 'h1', text: 'Attendance Webpushes'
  end

  test 'creating an attendance webpush' do
    visit attendance_webpushes_path
    click_on 'New Attendance webpush'

    fill_in 'Auth', with: @attendance_webpush.auth
    fill_in 'Endpoint', with: @attendance_webpush.endpoint
    fill_in 'Member', with: @attendance_webpush.member_id
    fill_in 'P256dh', with: @attendance_webpush.p256dh
    click_on 'Lag Attendance webpush'

    assert_text 'Attendance webpush was successfully created'
    click_on 'Back'
  end

  test 'updating an attendance webpush' do
    visit attendance_webpushes_path
    click_on 'Edit', match: :first

    fill_in 'Auth', with: @attendance_webpush.auth
    fill_in 'Endpoint', with: @attendance_webpush.endpoint
    fill_in 'Member', with: @attendance_webpush.member_id
    fill_in 'P256dh', with: @attendance_webpush.p256dh
    click_on 'Oppdater Attendance webpush'

    assert_text 'Attendance webpush was successfully updated'
    click_on 'Back'
  end

  test 'destroying an attendance webpush' do
    visit attendance_webpushes_path
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Attendance webpush was successfully destroyed'
  end
end
