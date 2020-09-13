# frozen_string_literal: true

require 'application_system_test_case'

class EventAttachmentsTest < ApplicationSystemTestCase
  setup { screenshot_section :event_attachments }

  test 'visiting the index' do
    screenshot_group :index
    visit_with_login edit_event_path(id(:one), anchor: :attachments_tab)
    assert_selector 'h2', text: 'Vedlegg'
    event = events(:one)
    event.attachments.attach(io: StringIO.new('Test Data'), filename: 'file1.pdf')
    event.attachments.attach(io: StringIO.new('Test Data'), filename: 'file2.pdf')
    event.attachments.attach(io: StringIO.new('Test Data'), filename: 'file3.pdf')
    event.attachments.attach(io: StringIO.new('Test Data'), filename: 'file4.pdf')
    visit_with_login edit_event_path(id(:one), anchor: :attachments_tab)
    screenshot :four_files
  end

  test 'creating a attachment' do
    screenshot_group :create
    visit_with_login edit_event_path(id(:one), anchor: :attachments_tab)
    screenshot :form
    find('#event_attachments', visible: false).set("#{Rails.root}/test/fixtures/files/tiny.png")
    screenshot :form_filled_in
    click_on 'Last opp fil'
    screenshot :uploaded
  end

  test 'destroying an attachment' do
    screenshot_group :delete
    event = events(:one)
    event.attachments.attach(io: StringIO.new('Test Data'), filename: 'file.pdf')

    visit_with_login edit_event_path(id(:one), anchor: :attachments_tab)
    page.accept_confirm { find('#attachments a.btn[data-method=delete]').click }

    assert_text 'Vedlegget ble slettet.'
    screenshot :deleted
  end
end
