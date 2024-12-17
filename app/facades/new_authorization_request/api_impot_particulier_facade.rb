class NewAuthorizationRequest
  class APIImpotParticulierFacade < Base
    def public_available_forms_sandbox
      AuthorizationRequestFormDecorator.decorate_collection(raw_public_available_forms_sandbox)
    end

    private

    def raw_public_available_forms_sandbox
      available_forms_sandbox.select do |form|
        form.public &&
          form.startable_by_applicant
      end
    end

    def available_forms_sandbox
      AuthorizationRequestForm.where(authorization_request_class: authorization_request_class_sandbox).sort do |form|
        form.default ? 1 : 0
      end
    end

    def authorization_request_class_sandbox
      @authorization_request_class_sandbox ||= AuthorizationRequest.const_get('api_impot_particulier_sandbox'.classify)
    end
  end
end
