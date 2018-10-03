# frozen_string_literal: true

require 'integration_test'

class AnnualMeetingsControllerTest < IntegrationTest
  setup do
    @annual_meeting = annual_meetings(:last)
    login(:admin)
  end

  test 'should get index' do
    get annual_meetings_path
    assert_response :success
  end

  test 'should get new' do
    get new_annual_meeting_path
    assert_response :success
  end

  test 'should create annual_meeting' do
    assert_difference('AnnualMeeting.count') do
      post annual_meetings_path, params: { annual_meeting: {
        invitation_sent_at: @annual_meeting.invitation_sent_at,
        public_record_updated_at: @annual_meeting.public_record_updated_at,
        start_at: @annual_meeting.start_at,
      } }
    end

    assert_redirected_to annual_meeting_path(AnnualMeeting.last)
  end

  test 'should show annual_meeting' do
    get annual_meeting_path(@annual_meeting)
    assert_response :success
  end

  test 'should get edit' do
    get edit_annual_meeting_path(@annual_meeting)
    assert_response :success
  end

  test 'should update annual_meeting' do
    put annual_meeting_path(@annual_meeting), params: { annual_meeting: {
      invitation_sent_at: @annual_meeting.invitation_sent_at,
      public_record_updated_at: @annual_meeting.public_record_updated_at,
      start_at: @annual_meeting.start_at,
    } }
    assert_redirected_to annual_meeting_path(@annual_meeting)
  end

  test 'should destroy annual_meeting' do
    assert_difference('AnnualMeeting.count', -1) do
      delete annual_meeting_path(@annual_meeting)
    end

    assert_redirected_to annual_meetings_path
  end
end
