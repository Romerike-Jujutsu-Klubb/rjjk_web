# frozen_string_literal: true

require 'application_system_test_case'

class NewsFeatureTest < ApplicationSystemTestCase
  setup { screenshot_section :news }

  def test_index_public
    screenshot_group :index_public
    visit '/news'
    assert_current_path '/news'
    screenshot('index')
    first('.post img').click
    modal_selector = '#imageModal .modal-header > button.close'
    close_btn = find(modal_selector)
    screenshot('image')
    close_btn.click
    assert_no_css(modal_selector)
    all('.post img')[1].click
    screenshot('image_2')
  end

  def test_index_member
    screenshot_group :index_member
    login_and_visit '/news', :newbie
    assert_current_path '/news'
    screenshot('index')
  end

  def test_index_admin
    screenshot_group :index_admin
    login_and_visit '/news'
    assert_current_path '/news'
    screenshot('index')
  end

  def test_new_news_item
    screenshot_group :new
    visit_with_login '/?lang=nb'
    screenshot('front')
    click_menu 'Nyheter', section: 'Web'
    click_on 'Ny nyhet'
    assert_current_path '/news/new'
    screenshot('form')
    fill_in 'news_item[title]', with: 'A new hope'
    select 'Kladd', from: 'news_item[publication_state]'
    select_date(:news_item_publish_at, 15)
    select_date(:news_item_expire_at, 16)
    fill_in 'news_item_summary', with: 'A new hope is rising in the tortured galaxy.'
    click_on 'Mer informasjon (valgfritt)'
    fill_in 'news_item_body', with: 'A long time ago in a galaxy far, far away.'
    screenshot('form_filled_in')
    click_button('Lagre')
    screenshot('saved')
  end

  private

  def select_date(date_field_id, day)
    find("##{date_field_id}").click
    assert has_css?("##{date_field_id} + .bootstrap-datetimepicker-widget")
    screenshot("form_#{date_field_id}_selected")
    execute_script("$('##{date_field_id} + .bootstrap-datetimepicker-widget " \
        "td.day:contains(#{day})').click()")
    assert has_field?(date_field_id, with: /^2013-10-#{day}/),
        "Unable to find field #{date_field_id} with value '2013-10-#{day}'.  " \
        "Found: #{find("##{date_field_id}").value}"
    screenshot("form_#{date_field_id}_selected_date_#{day}")
    find('#news_item_title').click
  end
end
