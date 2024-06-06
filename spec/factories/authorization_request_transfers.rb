FactoryBot.define do
  factory :authorization_request_transfer do
    authorization_request

    from { build(:user) }

    after(:build) do |authorization_request_transfer|
      authorization_request_transfer.to ||= create(:user, current_organization: authorization_request_transfer.from.current_organization)
    end
  end
end
