FactoryBot.define do
  factory :school do
    association :responsible_body, factory: %i[local_authority trust].sample
    urn { Faker::Number.number(digits: 6) }
    name { Faker::Educator.secondary_school }
    computacenter_reference { Faker::Number.number(digits: 8) }
    phase { School.phases.values.sample }
    establishment_type { School.establishment_types.values.sample }

    trait :with_preorder_information do
      preorder_information
    end

    trait :primary do
      phase { :primary }
    end

    trait :secondary do
      phase { :secondary }
    end

    trait :academy do
      establishment_type { :academy }
    end

    trait :la_maintained do
      establishment_type { :local_authority }
    end
  end
end
