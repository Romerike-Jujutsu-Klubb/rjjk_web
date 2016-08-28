# frozen_string_literal: true
if defined?(Rake) &&
      (RUBY_ENGINE != 'jruby' || org.jruby.RubyInstanceConfig.FULL_TRACE_ENABLED)
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/app/views/'
  end
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

MiniTest::Reporters.use!

TEST_TIME = Time.local(2013, 10, 17, 18, 46, 0) # Week 42, thursday

class ActiveSupport::TestCase
  fixtures :all

  setup { Timecop.freeze(TEST_TIME) }
  teardown { Timecop.return }

  def login(login = :admin)
    u = users(login)
    request.session[:user_id] = u.id
    Thread.current[:user] = u
  end

  def logout
    request.session.delete(:user_id)
    Thread.current[:user] = nil
  end

  def assert_no_errors(symbol)
    v = assigns(symbol)
    assert v, "Assignment #{symbol} not found in the controller."
    assert_equal [], v.errors.full_messages
  end
end

class Mail::TestMailer
  cattr_accessor :inject_one_error
  self.inject_one_error = false

  def deliver_with_error!(mail)
    if inject_one_error
      self.class.inject_one_error = false
      raise 'Failed to send email' if ActionMailer::Base.raise_delivery_errors
    end
    deliver_without_error! mail
  end

  alias_method_chain :deliver!, :error
end

# FIMXME(uwe): Remove?
require 'ish'

VCR.configure do |config|
  config.cassette_library_dir = "#{Rails.root}/test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end

class ActionMailer::TestCase
  fixtures :all

  # FIXME(uwe): Check out assert_emails core method
  def assert_mail_deliveries(count, initial = 0, &block)
    if block
      assert_equal initial, Mail::TestMailer.deliveries.size,
          -> {
            "Unexpected mail deliveries before block:
#{Mail::TestMailer.deliveries}
#{Mail::TestMailer.deliveries(&:body).join("\n")}\n"
          }
      yield
    end
    assert_equal initial + count, Mail::TestMailer.deliveries.size,
        -> { Mail::TestMailer.deliveries.to_s }
  end

  def assert_mail_stored(count, initial = 0, &block)
    if block
      assert_equal initial, UserMessage.pending.count,
          -> { "Unexpected user messages before block:\n#{UserMessage.pending}\n#{UserMessage.pending.map(&:body).join("\n")}\n" }
      yield
    end
    assert_equal initial + count, UserMessage.pending.count,
        -> { UserMessage.all.map(&:inspect).to_s }
  end
end
