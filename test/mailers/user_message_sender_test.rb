# frozen_string_literal: true

require 'test_helper'

class UserMessageSenderTest < ActionMailer::TestCase
  def test_send
    UserMessageSenderJob.perform_now
    assert_mail_deliveries 0
  end

  test 'send with one message' do
    subject = 'A cool message'
    sender = 'sender@example.com'
    title = 'Important!'
    plain_message = 'A plain text message'
    html_message = <<~HTML
      An HTML message with an <a href="/internal/link">internal link</a>
      and an <a href="/internal/link?a=2">internal link with parameter</a>
      and an <a href="http://example.net/external/link">external link</a>
      and an <a href="http://example.net/external/link?b=4">external link with parameter</a>
    HTML

    um = UserMessage.create! user_id: users(:admin).id, from: sender, key: '42', tag: :test,
                             subject: subject, title: title, message_timestamp: TEST_TIME.to_date,
                             html_body: html_message, plain_body: plain_message

    UserMessageSenderJob.perform_now

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
    assert_match(/17. Oktober\s+2013/, body)
    escaped_key = um.key.gsub('/', '%2F')
    assert_match %(href="https://example.com/user_messages/#{um.id}?) +
        %(email=dXdlQGV4YW1wbGUuY29t%0A&amp;key=#{escaped_key}"),
        body
    assert_match <<~HTML, body
      An HTML message with an <a href="https://example.com/internal/link?key=42">internal link</a>
      and an <a href="https://example.com/internal/link?a=2&key=42">internal link with parameter</a>
      and an <a href="http://example.net/external/link?key=42">external link</a>
      and an <a href="http://example.net/external/link?b=4&key=42">external link with parameter</a>
    HTML
  end
end
