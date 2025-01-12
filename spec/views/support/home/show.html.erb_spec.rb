require 'rails_helper'

RSpec.describe 'support/home/show.html.erb' do
  context 'when support user' do
    let(:support_user) { build(:support_user) }

    before do
      enable_pundit(view, support_user)
    end

    it 'does not display privileged users section' do
      render
      expect(rendered).not_to include('Privileged users')
    end
  end

  context 'when third line support user' do
    let(:support_user) { build(:support_user, role: 'third_line') }

    before do
      enable_pundit(view, support_user)
    end

    it 'displays privileged users section' do
      render
      expect(rendered).to include('Privileged users')
    end
  end
end
