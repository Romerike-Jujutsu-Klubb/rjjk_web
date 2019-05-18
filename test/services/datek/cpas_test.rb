# frozen_string_literal: true

require 'test_helper'

class CpasTest < ActiveSupport::TestCase
  test 'send_sms' do
    stub_request(:post, 'https://example.com/sms/send/mt')
        .with(
            body: { 'text' => 'Gratz!', 'to' => '5551234' },
            headers: {
              'Connection' => 'close',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'Host' => 'example.com',
              'User-Agent' => 'http.rb/4.1.1',
            }
          )
        .to_return(status: 200, body: '', headers: {})

    Datek::Cpas.send_sms to: 5_551_234, text: 'Gratz!'
  end
end
