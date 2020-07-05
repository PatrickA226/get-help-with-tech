require 'rails_helper'

RSpec.feature 'Submitting eligibility and BT hotspot information', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:responsible_body_home_page) { PageObjects::ResponsibleBody::HomePage.new }

  before do
    sign_in_as user
  end

  context 'for the first time' do
    scenario 'takes the user through the form, confirmation and back to the homepage' do
      expect(user.responsible_body.allocation_request).to be_nil

      visit responsible_body_home_path
      expect(page).to have_http_status(:ok)
      expect(responsible_body_home_page.step_1_status.text).to eq('Not started yet')

      click_on 'How many young people are eligible?'

      expect(page).to have_css('h1', text: 'How many young people are eligible?')
      click_on 'Continue'

      expect(page).to have_css('h1', text: 'Check your answers')
      click_on 'Submit'

      expect(responsible_body_home_page).to be_displayed
      expect(responsible_body_home_page.step_1_status.text).to eq('Completed')

      expect(user.responsible_body.reload.allocation_request).to be_present
    end
  end

  context 'after the information has already been submitted' do
    before do
      create(:allocation_request, created_by_user: user, responsible_body: user.responsible_body)
    end

    scenario 'updates the info for the responsible body' do
      expect(user.responsible_body.allocation_request).to be_present

      visit responsible_body_home_path
      expect(responsible_body_home_page.step_1_status.text).to eq('Completed')

      click_on 'How many young people are eligible?'

      # TODO: rest of the spec will be added here
    end
  end
end
