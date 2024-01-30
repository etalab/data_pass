FactoryBot.define do
  factory :authorization do
    transient do
      authorization_request_trait { :api_entreprise }
    end

    after(:build) do |authorization, evaluator|
      authorization_request = build(
        :authorization_request,
        evaluator.authorization_request_trait,
        :validated
      )
      authorization.authorization_request = authorization_request
      authorization.applicant = authorization_request.applicant
      authorization.data = authorization_request.data.dup
    end
  end
end
