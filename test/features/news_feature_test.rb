require 'capybara_setup'

class NewsFeatureTest < ActionDispatch::IntegrationTest
  def test_index_public
    visit '/news'
    assert_current_path '/news'
    screenshot('news/index_public')
    all('.post img')[0].click
    screenshot('news/index_public_image')
    click_button 'Close'
    assert has_no_css?('button', text: 'Close')
    all('.post img')[1].click
    screenshot('news/index_public_image_2')
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

  def test_new_news_item
    screenshot_group 'news/new'
    login_and_visit '/'
    assert_current_path '/'
    screenshot('front')
    click_link 'Ny nyhet'
    assert_current_path '/news/new'
    screenshot('form')
    fill_in 'news_item[title]', with: 'A new hope'
    select 'Kladd', from: 'news_item[publication_state]'
    select_date(:news_item_publish_at, 15)
    select_date(:news_item_expire_at, 16)
    # fill_in 'news_item[summary]', with: 'A new hope is rising in the tortured galaxy.'
    tinymce_fill_in 'news_item_summary', with: 'A new hope is rising in the tortured galaxy.'
    # fill_in 'news_item[body]', with: 'A long time ago in a galaxy far, far away.'
    tinymce_fill_in 'news_item_body', with: 'A long time ago in a galaxy far, far away.'
    screenshot('form_filled_in')
    click_button('Lagre')
    screenshot('saved')
  end

  private

  def tinymce_fill_in(name, options = {})
    if page.driver.browser == :chrome
      raise 'huh?!'
    else
      page.execute_script("tinyMCE.get('#{name}').setContent('#{options[:with]}')")
    end
  end

  def select_date(date_field_id, day)
    find("##{date_field_id}").click
    assert has_css?("##{date_field_id} + .bootstrap-datetimepicker-widget")
    screenshot("form_#{date_field_id}_selected")
    execute_script("$('##{date_field_id} + .bootstrap-datetimepicker-widget td.day:contains(#{day})').click()")
    assert has_field?(date_field_id, with: /^2013-10-#{day}/)
    screenshot("form_#{date_field_id}_selected_date_#{day}")
    find('body').click
  end
end
