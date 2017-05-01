# frozen_string_literal: true

require 'test_helper'

class BotMailerTest < ActionMailer::TestCase
  def test_reject
    mail = BotMailer.reject('HTTP_REFERER' => 'http://not.example.com/', 'HTTP_USER_AGENT' => 'BLEXBot')
    assert_equal '[RJJK] test Rejected BAIDU request', mail.subject
    assert_equal %w[uwe@kubosch.no], mail.to
    assert_equal %w[test@jujutsu.no], mail.from
    assert_match <<~EXPECTED.chomp, mail.body.decoded
      <h1>Rejected BOT request</h1><p>http://not.example.com/</p><pre>{&quot;HTTP_REFERER&quot;=&gt;&quot;http://not.example.com/&quot;, &quot;HTTP_USER_AGENT&quot;=&gt;&quot;BLEXBot&quot;}\n</pre>
    EXPECTED
  end
end
