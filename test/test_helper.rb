# frozen_string_literal: true

# require 'coveralls'
# Coveralls.wear!

if defined?(Rake) && (RUBY_ENGINE != 'jruby' || org.jruby.RubyInstanceConfig.FULL_TRACE_ENABLED)
  require 'simplecov'
  SimpleCov.start('rails') { minimum_coverage 86 }
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

Minitest::Reporters.use!

TEST_TIME = Time.zone.local(2013, 10, 17, 18, 46, 0) # Week 42, thursday

Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub([{
  'latitude' => 40.7143528,
  'longitude' => -74.0059731,
  'address' => 'New York, NY, USA',
  'state' => 'New York',
  'state_code' => 'NY',
  'country' => 'United States',
  'country_code' => 'US',
}])

class ActiveSupport::TestCase
  include UserSystem

  self.use_transactional_tests = true
  self.use_instantiated_fixtures = false

  fixtures :all

  setup { Timecop.freeze(TEST_TIME) }
  teardown { Timecop.return }
  teardown { clear_user }

  if defined?(Bullet) && Bullet.enable?
    Rails.backtrace_cleaner.remove_silencers!
    setup { Bullet.start_request }
    teardown do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end

  def login(login = :uwe)
    Thread.current[:user] = users(login)
  end

  def logout
    clear_user
  end

  def id(symbol)
    ActiveRecord::FixtureSet.identify(symbol)
  end

  # FIXME(uwe): Remove: Added in Rails 5
  def fixture_file_upload(path, mime_type = nil, binary = false)
    if self.class.respond_to?(:fixture_path) && self.class.fixture_path
      path = File.join(self.class.fixture_path, path)
    end
    Rack::Test::UploadedFile.new(path, mime_type, binary)
  end
  # EMXIF

  def with_retries(label: 'test', attempts: nil, exceptions: [Minitest::Assertion],
      backoff: 0.001.seconds, backoff_factor: 2, backoff_limit: Capybara.default_max_wait_time)
    yield
  rescue *exceptions => e
    attempt = attempt&.next || 1
    raise e if (attempts && attempt >= attempts) || backoff > backoff_limit

    puts "Retrying #{label} #{attempt} #{backoff} #{e}"
    sleep backoff
    backoff *= backoff_factor
    retry
  end
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

require 'webmock/minitest'

VCR.configure do |config|
  config.cassette_library_dir = "#{Rails.root}/test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end

class ActionMailer::TestCase
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
    assert_equal initial + count, Mail::TestMailer.deliveries.size, -> { Mail::TestMailer.deliveries.to_s }
  end

  def assert_mail_stored(count = 1, initial: 0)
    if block_given?
      assert_equal initial, UserMessage.pending.count,
          -> do
            "Unexpected user messages before block:\n#{UserMessage.pending.map(&:body).join("\n")}\n"
          end
      yield
    end
    assert_equal initial + count, UserMessage.pending.count, -> { UserMessage.all.map(&:inspect).to_s }
  end
end
