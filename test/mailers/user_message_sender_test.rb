require 'test_helper'

class UserMessageSenderTest < ActionMailer::TestCase
  def test_send
    UserMessageSender.send
    assert_mail_deliveries 0
  end

  test 'send with one message' do
    subject = 'A cool message'
    sender = 'sender@example.com'
    plain_message = 'A plain text message'
    html_message = 'An HTML message'
    um = UserMessage.create! user_id: users(:admin).id, from: sender,
        subject: subject, html_body: html_message, plain_body: plain_message

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
    assert_match html_message, part.body.decoded
    assert_match %(href="http://example.com/user_messages/980190963?email=&amp;key=#{um.key.gsub('/', '%252F')}"),
        part.body.decoded
  end
end
