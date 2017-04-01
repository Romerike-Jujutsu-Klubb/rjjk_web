# frozen_string_literal: true

require 'test_helper'

class BaiduMailerTest < ActionMailer::TestCase
  def test_newsletter
    mail = BaiduMailer.reject('http://not.example.com/')
    assert_equal '[RJJK] test Rejected BAIDU request', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "<h1>Rejected BAIDU request</h1>\n\nhttp://not.example.com/\n", mail.body.decoded
  end
end
