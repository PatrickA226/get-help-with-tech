FactoryBot.define do
  factory :extra_mobile_data_request, class: 'ExtraMobileDataRequest' do
    account_holder_name               { Faker::Name.name }
    device_phone_number               { '07123 456789' }
    agrees_with_privacy_statement     { true }
    status                            { :requested }
    association :mobile_network
    association :created_by_user, factory: :local_authority_user
  end
end
