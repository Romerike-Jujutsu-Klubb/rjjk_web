# frozen_string_literal: true

require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActionMailer::TestCase
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
    user = users(:admin)
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
    assert u.errors.empty?
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
    assert u.errors[:login].empty?

    u.login = 'oktesla'
    assert u.save
    assert u.errors.empty?
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
    assert_equal true, users(:admin).technical_committy?
    assert_equal true, users(:lars).technical_committy?
    assert_nil users(:long_user).technical_committy?
    assert_nil users(:newbie).technical_committy?
  end

  test 'emails' do
    assert_equal [
      ['deletable_user@example.com'],
      ['lars@example.com'],
      ['leftie@example.com'],
      ['long_user@example.com'],
      ['neuer@example.com'],
      ['neuer@example.com', 'newbie@example.com'],
      ['sebastian@example.com', 'uwe@example.com'],
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
end
