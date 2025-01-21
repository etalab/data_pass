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
      if authorization.applicant.nil?
        authorization.applicant = authorization.request.applicant
      else
        authorization.request.applicant = authorization.applicant
        authorization.request.organization = authorization.applicant.current_organization
      end
      authorization.data = authorization.request.data.dup

      authorization.data['what'] = 'ever' if authorization.data.blank?
      authorization.form_uid ||= authorization.request.form_uid
    end
  end
end
