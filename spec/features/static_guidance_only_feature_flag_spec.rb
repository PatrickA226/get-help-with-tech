require 'rails_helper'

RSpec.feature 'Static Guidance Only feature flag', type: :feature do
  context 'with the static_guidance_only feature flag set' do
    before do
      FeatureFlag.activate(:static_guidance_only)
    end

    scenario 'visiting the guidance page works' do
      visit guidance_page_path
      expect(page).to have_http_status(:ok)
      expect(page).to have_selector 'h1', text: 'Increasing children’s internet access'
    end

    scenario 'visiting any other page returns a 404' do
      visit sign_in_path
      expect(page).to have_http_status(:not_found)
      expect(page).to have_selector 'h1', text: 'The page you were looking for doesn\'t exist'
    end
  end

  context 'with the static_guidance_only feature flag NOT set' do
    before do
      FeatureFlag.deactivate(:static_guidance_only)
    end

    scenario 'visiting the guidance page works' do
      visit guidance_page_path
      expect(page).to have_http_status(:ok)
      expect(page).to have_selector 'h1', text: 'Increasing children’s internet access'
    end

    scenario 'visiting any other page works' do
      visit sign_in_path
      expect(page).to have_http_status(:ok)
      expect(page).to have_selector 'h1', text: 'Sign in'
    end
  end
end
