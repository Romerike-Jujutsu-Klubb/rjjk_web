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
end
