# frozen_string_literal: true

module NewFrontPageSystemTests
  SUBNAV_OFFSET = -268

  def test_member_front_page
    screenshot_group :front_page
    login_and_visit root_path
    assert_selector 'h4', text: 'Neste trening'
    assert_offset '.subnav', :left, SUBNAV_OFFSET
    assert_offset '.main_right', :right, SUBNAV_OFFSET
    bottom_logo_area = [703, 1820, 703, 1852]
    screenshot :index, skip_area: [logo_area, bottom_logo_area, scroll_bar_area]
    find('.fa-bars').click # Display menu
    assert_offset '.subnav', :left, 0
    info_section = find('h1', text: 'Informasjon')
    find('body').scroll_to(info_section)
    info_section.click
    assert_selector 'li a', text: 'My first article'
    assert_css '#menuShadow'
    screenshot :menu, skip_area: [menu_logo_area, logo_area]
    find('.fa-calendar-alt').click_at # Hide menu
    assert_offset '.subnav', :left, SUBNAV_OFFSET
    assert_no_css '#menuShadow'
    screenshot :menu_closed, skip_area: [logo_area, bottom_logo_area]

    find('#calendarBtn').click # Display calendar sidebar
    assert_offset '.main_right', :right, 0
    assert_css '#sidebarShadow'
    screenshot :calendar, skip_area: logo_area, area_size_limit: 18
    find('#sidebarShadow').click(x: 10, y: 10) # Hide calendar sidebar
    assert_offset '.main_right', :right, SUBNAV_OFFSET
    assert_no_css '#sidebarShadow'
    screenshot :calendar_closed, skip_area: [logo_area, bottom_logo_area]
  end

  def test_new_front_page
    visit front_page_path
    assert_css('#headermenuholder > .fa-bars')
    find('.newwrap').assert_matches_style(opacity: '1')
    screenshot :index, skip_area: [public_menu_btn_area, progress_bar_area].compact
    find('#headermenuholder > .fa-bars').click
    article_menu_link = find('.menubutton', text: 'My first article')
    find('#mainmenuholder').assert_matches_style(left: '0px')
    screenshot :menu, skip_area: public_menu_logo_area
    with_retries(label: 'article menu click') { article_menu_link.click }
    assert_css 'h1', text: 'My first article'
    screenshot :article, skip_area: [logo_area, scroll_bar_area]
  end

  def test_new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > .fa-bars')
    assert_css('.fa-chevron-down')
    find('.newwrap').assert_matches_style(opacity: '1')
    screenshot :index, area_size_limit: 533, skip_area: [public_menu_btn_area, progress_bar_area].compact
    find('.fa-chevron-down').click
    find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    scroll_position = evaluate_script('$(window).height()')
    with_retries { assert_equal scroll_position, evaluate_script('window.scrollY') }
    screenshot :scrolled, skip_area: scroll_bar_area
    assert_equal information_page_url(information_pages(:first).title),
        find('#footer .menu-item a', text: 'MY FIRST ARTICLE')[:href]
    with_retries label: 'article link click' do
      find('#footer .menu-item a', text: 'MY FIRST ARTICLE').click
      assert_current_path information_page_path(information_pages(:first).title)
    end

    assert_css('h1', text: 'My first article')
    screenshot :article, skip_area: [logo_area, scroll_bar_area]
  end
end
