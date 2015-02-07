# encoding: utf-8
require 'test_helper'

class NewsFeatureTest < ActionDispatch::IntegrationTest
  def test_index_public
    visit '/news'
    assert_current_path '/news'
    screenshot('news/index_public')
    find('.post img').click
    screenshot('news/index_public_image')
  end

  def test_index_member
    login_and_visit '/news', :sebastian
    assert_current_path '/news'
    screenshot('news/index_member')
  end

  def test_index_admin
    login_and_visit '/news'
    assert_current_path '/news'
    screenshot('news/index_admin')
  end

end
