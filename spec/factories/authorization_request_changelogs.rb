FactoryBot.define do
  factory :authorization_request_changelog do
    authorization_request { create(:authorization_request, :submitted) }

    initialize_with do
      if attributes[:diff].present?
        new(attributes)
      else
        CreateAuthorizationRequestChangelog.call(authorization_request: attributes[:authorization_request]).changelog
      end
    end
  end
end
