# frozen_string_literal: true

if defined?(Rake) &&
      (RUBY_ENGINE != 'jruby' || org.jruby.RubyInstanceConfig.FULL_TRACE_ENABLED)
  require 'simplecov'
  SimpleCov.start('rails') { minimum_coverage 84 }
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

MiniTest::Reporters.use!

TEST_TIME = Time.zone.local(2013, 10, 17, 18, 46, 0) # Week 42, thursday

class ActiveSupport::TestCase
  include UserSystem

  fixtures :all

  setup { Timecop.freeze(TEST_TIME) }
  teardown { Timecop.return }

  if Bullet.enable?
    Rails.backtrace_cleaner.remove_silencers!
    setup { Bullet.start_request }
    teardown { Bullet.end_request }
  end

  def login(login = :admin)
    user = users(login)
    self.current_user = user
    store_cookie if respond_to? :cookies
    user
  end

  def logout
    self.current_user = nil
    clear_cookie
  end

  def assert_no_errors(symbol)
    v = assigns(symbol)
    assert v, "Assignment #{symbol} not found in the controller."
    assert_equal [], v.errors.full_messages
  end

  # FIXME(uwe): Remove: Added in Rails 5
  def fixture_file_upload(path, mime_type = nil, binary = false)
    if self.class.respond_to?(:fixture_path) && self.class.fixture_path
      path = File.join(self.class.fixture_path, path)
    end
    Rack::Test::UploadedFile.new(path, mime_type, binary)
  end
  # EMXIF
end

module MailDeliveryError
  cattr_accessor :inject_one_error
  self.inject_one_error = false

  def deliver!(mail)
    if inject_one_error
      self.class.inject_one_error = false
      raise 'Failed to send email' if ActionMailer::Base.raise_delivery_errors
    end
    super mail
  end
end

Mail::TestMailer.prepend MailDeliveryError

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
          -> do
            "Unexpected user messages before block:\n#{UserMessage.pending}\n" \
                "#{UserMessage.pending.map(&:body).join("\n")}\n"
          end
      yield
    end
    assert_equal initial + count, UserMessage.pending.count,
        -> { UserMessage.all.map(&:inspect).to_s }
  end
end

class Rack::Test::CookieJar
  def signed
    self
  end
end
