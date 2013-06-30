require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  self.use_transactional_fixtures = false

  def test_authenticate
    assert_equal users(:tesla), User.authenticate(users(:tesla).login, 'atest')
    assert_nil User.authenticate('nontesla', 'atest')
    assert_nil User.authenticate(users(:tesla).login, 'wrong password')
  end

  def test_authenticate_by_token
    user = users(:unverified_user)
    assert_equal user, User.authenticate_by_token(user.id, user.security_token)
  end

  def test_authenticate_by_token__fails_if_expired
    user = users(:unverified_user)
    Clock.time = Clock.now + User.token_lifetime
    assert_nil User.authenticate_by_token(user.id, user.security_token)
  end

  def test_authenticate_by_token__fails_if_bad_token
    user = users(:unverified_user)
    assert_nil User.authenticate_by_token(user.id, 'bad_token')
  end

  def test_authenticate_by_token__fails_if_bad_id
    user = users(:unverified_user)
    assert_nil User.authenticate_by_token(-1, user.security_token)
  end

  def test_change_password
    user = users(:long_user)
    user.change_password('a new password')
    user.save
    assert_equal user, User.authenticate(user.login, 'a new password')
    assert_nil User.authenticate(user.login, 'alongtest')
  end

  def test_generate_security_token
    user = User.new :login => 'user', :email => 'user@example.com', :salt => 'salt', :salted_password => 'tlas'
    user.save
    token = user.generate_security_token
    assert_not_nil token
    user.reload
    assert_equal token, user.security_token
    assert_equal((Clock.now + User.token_lifetime).to_i, user.token_expiry.to_i)
  end

  def test_generate_security_token__reuses_token_when_not_stale
    user = users(:unverified_user)
    Clock.advance_by_seconds((User.token_lifetime/2))
    assert_equal user.security_token, user.generate_security_token 
  end

  def test_generate_security_token_generates_new_token_when_getting_stale
    user = users(:unverified_user)
    Clock.advance_by_seconds(1.second + User.token_lifetime/2)
    assert_not_equal user.security_token, user.generate_security_token
  end

  def test_change_password__disallowed_passwords
    u = User.new
    u.login = 'test_user'
    u.email = 'disallowed_password@example.com'

    u.change_password('tiny')
    assert !u.save     
    assert u.errors['password'].any?

    u.change_password('hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge')
    assert !u.save     
    assert u.errors['password'].any?
        
    u.change_password('')
    assert !u.save    
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
    assert !u.save     
    assert u.errors[:login].any?

    u.login = 'hugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahugeteslahug'
    assert !u.save     
    assert u.errors[:login].any?

    u.login = '' # login is set to email automatically
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
    u.login = users(:tesla).login
    u.email = 'new@example.com'
    u.change_password('password')
    assert !u.save
  end

  def test_create__validates_unique_email
    u = User.new
    u.login = 'new_user'
    u.email= users(:tesla).email
    u.change_password('password')
    assert !u.save
  end

end
