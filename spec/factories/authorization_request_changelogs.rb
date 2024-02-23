FactoryBot.define do
  factory :authorization_request_changelog do
    authorization_request { build(:authorization_request, :submitted) }

    after(:build) do |authorization_request_changelog|
      next if authorization_request_changelog.diff.present?

      authorization_request_changelog.diff = authorization_request_changelog.authorization_request.data.transform_values { |v| [nil, v] }
    end
  end
end
