# frozen_string_literal: true
require 'test_helper'

class UserMessageSenderTest < ActionMailer::TestCase
  def test_send
    UserMessageSender.send
    assert_mail_deliveries 0
  end

  test 'send with one message' do
    subject = 'A cool message'
    sender = 'sender@example.com'
    title = 'Important!'
    plain_message = 'A plain text message'
    html_message = 'An HTML message'
    um = UserMessage.create! user_id: users(:admin).id, from: sender,
        subject: subject, title: title, message_timestamp: TEST_TIME, html_body: html_message, plain_body: plain_message

    UserMessageSender.send

    assert_mail_deliveries 1

    mail = Mail::TestMailer.deliveries[0]
    assert_equal "[RJJK][TEST] #{subject}", mail.subject
    assert_equal '"Uwe Kubosch" <uwe@kubosch.no>', mail['to'].value
    assert_equal [sender], mail.from
    assert_equal 2, mail.parts.size

    part = mail.parts[0]
    assert_equal 'text/plain; charset=UTF-8', part.content_type
    assert_equal plain_message, part.body.decoded

    part = mail.parts[1]
    assert_equal 'text/html; charset=UTF-8', part.content_type
    body = part.body.decoded
    assert_match "<title>#{title}</title>", body
    assert_match %(<p style="margin:0 0 10px 0; font-size:18px; color:#E20916;">#{title}</p>), body
    assert_match '17. Oktober 2013', body
    assert_match html_message, body
    escaped_key = um.key.gsub('/', '%2F')
    assert_match %(href="http://example.com/user_messages/#{um.id}?key=#{escaped_key}"),
        body
  end
end
