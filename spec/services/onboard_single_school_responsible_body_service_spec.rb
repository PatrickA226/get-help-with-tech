require 'rails_helper'

RSpec.describe OnboardSingleSchoolResponsibleBodyService, type: :model do
  after do
    clear_enqueued_jobs
  end

  let(:responsible_body) { create(:trust, :single_academy_trust, in_devices_pilot: false) }
  let(:school) { create(:school, responsible_body: responsible_body) }

  context 'when the responsible body has no users and the school has no headteacher' do
    it 'raises an error' do
      expect {
        described_class.new(urn: school.urn).call
      }.to raise_error(/Cannot continue without RB users or a school headteacher/)
    end
  end

  context 'when the responsible body has users' do
    before do
      create_list(:trust_user, 4, responsible_body: responsible_body, orders_devices: true)

      described_class.new(urn: school.urn).call
      responsible_body.reload
      school.reload
    end

    it 'brings the responsible body into the devices pilot' do
      expect(responsible_body.in_devices_pilot?).to be_truthy
    end

    it 'marks the responsible body as having devolved ordering to schools' do
      expect(responsible_body.who_will_order_devices).to eq('schools')
    end

    it 'sets one of the users as a school contact' do
      expect(school.preorder_information.school_contact).to be_present

      contact_email_address = school.preorder_information.school_contact.email_address
      expect(responsible_body.users.find_by(email_address: contact_email_address)).to be_present
    end

    it 'contacts the school contact and marks the school as contacted' do
      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.first.to.first).to eq(school.preorder_information.school_contact.email_address)
      expect(school.preorder_information.status).to eq('school_contacted')
    end

    it 'contacts all RB users' do
      perform_enqueued_jobs

      contacted_emails = ActionMailer::Base.deliveries.flat_map(&:to)
      expect(contacted_emails).to match_array(responsible_body.users.map(&:email_address))
    end

    it 'ensures that only 3 of the RB users are going to order devices' do
      # it's a bit strange that some users have their ability to order randomly switched off,
      # but there's no other obvious way to decide who to ensure the '3 Techsource users' constraint
      expect(responsible_body.users.who_can_order_devices.count).to eq(3)
    end

    it 'adds all the RB users as school users' do
      User.all.each do |user|
        expect(user).to be_hybrid
        expect(user.school).to eq(school)
        expect(user.responsible_body).to eq(responsible_body)
      end
    end
  end

  context 'when the responsible body has no users but the school has a headteacher contact' do
    before do
      @headteacher = create(:school_contact, :headteacher, school: school)

      described_class.new(urn: school.urn).call
      responsible_body.reload
      school.reload
    end

    it 'brings the responsible body into the devices pilot' do
      expect(responsible_body.in_devices_pilot?).to be_truthy
    end

    it 'marks the responsible body as having devolved ordering to schools' do
      expect(responsible_body.who_will_order_devices).to eq('schools')
    end

    it 'sets the headteacher as a school contact' do
      expect(school.preorder_information.school_contact).to eq(@headteacher)
    end

    it 'contacts the headteacher and marks the school as contacted' do
      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.first.to.first).to eq(@headteacher.email_address)
      expect(school.preorder_information.status).to eq('school_contacted')
    end

    it 'adds the headteacher as a hybrid user who can order' do
      user = User.find_by!(email_address: @headteacher.email_address)

      expect(user).to be_hybrid
      expect(user.school).to eq(school)
      expect(user.responsible_body).to eq(responsible_body)
    end
  end
end
