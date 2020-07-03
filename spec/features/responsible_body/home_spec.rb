require 'rails_helper'

RSpec.feature ResponsibleBody do
  let(:rb_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }

  context 'not signed-in' do
    scenario 'visiting the page redirects to sign-in' do
      visit responsible_body_home_path

      expect(page).to have_current_path(sign_in_path)
    end
  end

  context 'signed in as non-RB user' do
    before do
      sign_in_as mno_user
    end

    scenario 'visiting the page shows a :forbidden error' do
      visit responsible_body_home_path

      expect(page).to have_content("You're not allowed to do that")
      expect(page).to have_http_status(:forbidden)
    end
  end

  context 'signed in as an RB user' do
    before do
      sign_in_as rb_user
    end

    scenario 'visiting the page' do
      visit responsible_body_home_path

      expect(page.status_code).to eq 200
    end

    context 'when the user has no requests' do
      scenario 'the "Request extra mobile data" task shows as not started yet' do
        visit responsible_body_home_path
        expect(page).to have_text("Request extra mobile data\nNot started yet")
      end
    end

    context 'when the user has at least one request' do
      before do
        create(:extra_mobile_data_request, created_by_user: rb_user)
      end

      scenario 'the "Request extra mobile data" task shows as In progrss' do
        visit responsible_body_home_path
        expect(page).to have_text("Request extra mobile data\nIn progress")
      end
    end
  end
end