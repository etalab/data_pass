FactoryBot.define do
  factory :authorization do
    transient do
      authorization_request_trait { :api_entreprise }
    end

    after(:build) do |authorization, evaluator|
      authorization.authorization_request ||= build(
        :authorization_request,
        evaluator.authorization_request_trait,
        :validated
      )
      authorization.applicant = authorization.authorization_request.applicant
      authorization.data = authorization.authorization_request.data.dup

      authorization.data['what'] = 'ever' if authorization.data.blank?
    end
  end
end
