FactoryBot.define do
  factory :authorization do
    transient do
      authorization_request_trait { :api_entreprise }
    end

    after(:build) do |authorization, evaluator|
      authorization.request ||= build(
        :authorization_request,
        evaluator.authorization_request_trait,
        :validated
      )
      authorization.applicant = authorization.request.applicant
      authorization.data = authorization.request.data.dup

      authorization.data['what'] = 'ever' if authorization.data.blank?
    end
  end
end
