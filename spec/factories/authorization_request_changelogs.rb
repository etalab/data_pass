FactoryBot.define do
  factory :authorization_request_changelog do
    authorization_request { build(:authorization_request, :submitted) }

    after(:build) do |authorization_request_changelog|
      next if authorization_request_changelog.diff.present?

      authorization_request = authorization_request_changelog.authorization_request
      authorization_request_changelog.diff = authorization_request.data.to_h { |k, _| [k, [nil, authorization_request.public_send(k)]] }
    end
  end
end
