# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../test_helper"

class UserTest < ActionMailer::TestCase
  class Image
    def original_filename
      'My Image'
    end

    def content_type
      'image/png'
    end

    def read
      'Image Content'
    end
  end

  def test_authenticate
    assert_equal users(:lars), User.authenticate(users(:lars).login, 'atest')
    assert_nil User.authenticate('nontesla', 'atest')
    assert_nil User.authenticate(users(:lars).login, 'wrong password')
  end

  def test_authenticate_by_token
    user = users(:unverified_user)
    assert_equal user, User.authenticate_by_token(user.security_token)
  end

  def test_authenticate_by_token_from_user_message
    user = users(:uwe)
    assert_equal user, User.authenticate_by_token(user_messages(:one).key)
  end

  def test_authenticate_by_token__fails_if_expired
    user = users(:unverified_user)
    Timecop.freeze(Time.current + User.token_lifetime) do
      assert_nil User.authenticate_by_token(user.security_token)
    end
  end

  def test_authenticate_by_token__fails_if_bad_token
    assert_nil User.authenticate_by_token('bad_token')
  end

  def test_change_password
    user = users(:long_user)
    user.change_password('a new password')
    user.save!
    assert_equal user, User.authenticate(user.login, 'a new password')
    assert_nil User.authenticate(user.login, 'alongtest')
  end

  def test_generate_security_token
    user = User.create! login: 'user', email: 'user@example.com', salt: 'salt', salted_password: 'tlas'
    token = user.generate_security_token
    assert_not_nil token
    user.reload
    assert_equal token, user.security_token
    assert_equal((Time.current + User.token_lifetime).to_i, user.token_expiry.to_i)
  end

  test 'generate security token when no password is set' do
    user = User.create! login: 'user', email: 'user@example.com'
    token = user.generate_security_token
    assert_not_nil token
    user.reload
    assert_equal token, user.security_token
    assert_equal((Time.current + User.token_lifetime).to_i, user.token_expiry.to_i)
  end

  def test_generate_security_token__reuses_token_when_not_stale
    user = users(:unverified_user)
    Timecop.freeze(Time.current + User.token_lifetime / 2 - 1.minute) do
      assert_equal user.security_token, user.generate_security_token
    end
  end

  def test_generate_security_token_generates_new_token_when_getting_stale
    user = users(:unverified_user)
    Timecop.freeze(Time.current + User.token_lifetime / 2 + 1) do
      assert_not_equal user.security_token, user.generate_security_token
    end
  end

  def test_change_password__disallowed_passwords
    u = User.new
    u.login = 'test_user'
    u.email = 'disallowed_password@example.com'

    u.change_password('tiny')
    assert_not u.save
    assert u.errors['password'].any?

    u.change_password('huge' * 50)
    assert_not u.save
    assert u.errors['password'].any?

    u.change_password('')
    assert_not u.save
    assert u.errors['password'].any?

    u.change_password('a_s3cure_p4ssword')
    assert u.save
    assert_empty u.errors
  end

  def test_validates_login
    u = User.new
    u.change_password('teslas_secure_password')
    u.email = 'bad_login_tesla@example.com'

    u.login = 'x'
    assert_not u.save
    assert u.errors[:login].any?

    u.login = 'hugetesla' * 20
    assert_not u.save
    assert u.errors[:login].any?

    u.login = ''
    assert u.save
    assert_empty u.errors[:login]

    u.login = 'oktesla'
    assert u.save
    assert_empty u.errors
  end

  def test_create
    u = User.new
    u.login = 'nonexisting_user'
    u.email = 'nonexisting_email@example.com'
    u.change_password('password')
    assert u.save
  end

  def test_create__validates_unique_login
    u = User.new
    u.login = users(:lars).login
    u.email = 'new@example.com'
    u.change_password('password')
    assert_not u.save
  end

  def test_create__validates_unique_email
    u = User.new
    u.login = 'new_user'
    u.email = users(:lars).email
    u.change_password('password')
    assert_not u.save
  end

  def test_technical_committy
    assert users(:uwe).technical_committy?
    assert users(:lars).technical_committy?
    assert_nil users(:long_user).technical_committy?
    assert_not users(:newbie).technical_committy?
  end

  test 'emails' do
    assert_equal [
      ['deletable_user@example.com'],
      ['lars@example.com'],
      ['leftie@example.com'],
      ['lise@example.com'],
      ['lise@example.com', 'sebastian@example.com', 'uwe@example.com'],
      ['long_user@example.com'],
      ['neuer@example.com'],
      ['neuer@example.com', 'newbie@example.com'],
      ['oldie@example.com'],
      ['post@jujutsu.no'],
      ['sandra@example.com'],
      ['unverified_user@example.com'],
      ['uwe@example.com'],
    ], User.all.map(&:emails).sort
  end

  test 'name with last name first' do
    assert_equal 'Bråten, Lars', users(:lars).name(last_name_first: true)
  end

  test 'label with last name first' do
    assert_equal 'Bråten, Lars', users(:lars).label(last_name_first: true)
  end

  test 'valid fixtures' do
    assert User.all.all?(&:valid?)
  end

  test 'normalize phone' do
    u = users(:lars)
    u.update! phone: '+47 12 34 56 78'
    assert_equal '12345678', u.phone
  end

  test 'absent?' do
    assert_not users(:lars).absent?
    assert_not users(:newbie).absent?
    assert users(:sebastian).absent?
    assert_not users(:uwe).absent?
  end

  test 'absent? preloaded attendances for group' do
    users = User.includes(:attendances).order(:id)
    assert_equal [true, false, true, true, true, true, false, false, true, true, false, true, true],
        (users.map { |m| m.absent?(Date.current, groups(:voksne)) })
  end

  test 'absent? preloaded recent_attendances' do
    users = User.includes(:recent_attendances).order(:id)
    assert_equal [true, false, true, true, true, true, false, false, true, true, false, true, true],
        (users.map { |m| m.absent?(Date.current, groups(:voksne)) })
  end

  def test_update_image
    VCR.use_cassette 'GoogleMaps Lars' do
      users(:lars).update! profile_image_file: Image.new
    end
  end
end
