# frozen_string_literal: true

require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  test 'should destroy attachment' do
    event = events(:one)
    event.attachments.attach(io: StringIO.new('Test Data'), filename: 'file.pdf')
    attachment = event.attachments.first

    assert_difference('ActiveStorage::Attachment.count', -1) do
      delete attachment_url(attachment)
    end

    assert_redirected_to edit_event_url(event)
  end
end
