FactoryGirl.define do
  factory :access_token, class: OffendersApi::AccessToken do
    value '6e78cefe9fbc959631cce781ad546a5c28b1a04d57321d534c2140f769a9f7b6'
    type 'bearer'
    expires_in 7200
    created_at { Time.now.utc }

    initialize_with { new(attributes) }

    trait :valid do
      expires_in 7200
      created_at { Time.now.utc }
    end
  end
end
