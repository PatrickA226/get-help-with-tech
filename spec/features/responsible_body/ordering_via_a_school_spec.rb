require 'rails_helper'

RSpec.feature 'Ordering via a school' do
  let(:rb) { create(:local_authority, in_devices_pilot: true, schools: [school, school_that_cannot_order_as_reopened]) }
  let(:rb_user) { create(:local_authority_user, responsible_body: rb) }
  let(:preorder) { create(:preorder_information, :rb_will_order, :does_not_need_chromebooks, school_contact: school.contacts.first) }
  let(:another_preorder) { create(:preorder_information, :rb_will_order, :does_not_need_chromebooks, school_contact: school.contacts.first) }
  let(:another_allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices, devices_ordered: 3) }
  let(:school) { create(:school, :with_headteacher_contact) }
  let(:school_that_cannot_order_as_reopened) { create(:school, :with_headteacher_contact, order_state: :cannot_order_as_reopened) }

  let(:school_page) { PageObjects::ResponsibleBody::SchoolPage.new }
  let(:school_order_devices_page) { PageObjects::ResponsibleBody::SchoolOrderDevicesPage.new }

  before do
    school.update!(preorder_information: preorder)
    school_that_cannot_order_as_reopened.update!(preorder_information: another_preorder, std_device_allocation: another_allocation)
  end

  context 'when school has no devices to order' do
    scenario 'cannot order devices' do
      given_i_am_signed_in_as_rb_user

      when_i_view_a_school(school)
      then_i_see_status_of('Ready')
    end
  end

  scenario 'when school cannot_order_as_reopened' do
    given_i_am_signed_in_as_rb_user

    when_i_view_a_school(school_that_cannot_order_as_reopened)
    then_i_see("You ordered #{another_allocation.devices_ordered} of #{another_allocation.cap} devices")
  end

  context 'when school has devices to order' do
    let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices) }

    before do
      school.update!(std_device_allocation: allocation)
      school.preorder_information.refresh_status!
    end

    scenario 'can order devices' do
      given_i_am_signed_in_as_rb_user

      when_i_view_a_school(school)
      then_i_see_status_of('You can order')

      when_i_click_on('Order devices')
      then_i_see_the_school_order_devices_page
      and_i_see_the_techsource_button
    end
  end

  def given_i_am_signed_in_as_rb_user
    sign_in_as rb_user
  end

  def when_i_view_a_school(school)
    school_page.load(urn: school.urn)
  end

  def then_i_see_status_of(status)
    expect(school_page.school_details).to have_content(status)
  end

  def when_i_click_on(text)
    page.click_on text
  end

  def then_i_see_the_school_order_devices_page
    expect(school_order_devices_page).to be_displayed
  end

  def and_i_see_the_techsource_button
    expect(school_order_devices_page).to have_techsource_button
  end

  def then_i_see(content)
    expect(page).to have_content(content)
  end
end
