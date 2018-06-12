# frozen_string_literal: true

require 'feature_test'

class NewsFeatureTest < FeatureTest
  setup { screenshot_section :news }

  def test_index_public
    screenshot_group :index_public
    visit '/news'
    assert_current_path '/news'
    screenshot('index')
    all('.post img')[0].click
    screenshot('image') || sleep(Capybara::Screenshot.stability_time_limit || 0.5)
    find('.close').click
    assert has_no_css?('.close')
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
    login_and_visit '/'
    assert_current_path '/'
    screenshot('front')
    click_menu 'Ny nyhet'
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

  def tinymce_fill_in(name, options = {})
    raise 'huh?!' if page.driver.browser == :chrome
    page.execute_script("tinyMCE.get('#{name}').setContent('#{options[:with]}')")
  end

  def select_date(date_field_id, day)
    find("##{date_field_id}").click
    assert has_css?("##{date_field_id} + .bootstrap-datetimepicker-widget")
    screenshot("form_#{date_field_id}_selected")
    execute_script("$('##{date_field_id} + .bootstrap-datetimepicker-widget " \
        "td.day:contains(#{day})').click()")
    assert has_field?(date_field_id, with: /^2013-10-#{day}/),
        "Unable to find field #{date_field_id} with value '2013-10-#{day}'.  " \
        "Found: #{find("##{date_field_id}").value}"
    # FIXME(uwe): Bootstrap 4 beta2 leaves a stray line after blur animation
    screenshot("form_#{date_field_id}_selected_date_#{day}", area_size_limit: 33)
    # EMXIF
    find('#news_item_title').click
  end
end
