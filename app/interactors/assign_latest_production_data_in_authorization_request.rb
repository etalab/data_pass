class AssignLatestProductionDataInAuthorizationRequest < ApplicationInteractor
  def call
    return unless production_authorization

    interactor = AssignParamsToAuthorizationRequest.call(
      authorization_request:,
      authorization_request_params:,
      skip_validation: true,
    )

    context.fail! unless interactor.success?

    authorization_request.save!(validate: false)
  end

  private

  def authorization_request_params
    ActionController::Parameters.new(
      production_data_without_sandbox_data
    )
  end

  def production_data_without_sandbox_data
    production_authorization.data.slice(*keys_to_copy.map(&:to_s)).to_h
  end

  def keys_to_copy
    production_data_attributes - sandbox_data_attributes
  end

  def production_data_attributes
    extract_data_attributes(production_authorization)
  end

  def sandbox_data_attributes
    extract_data_attributes(sandbox_authorization)
  end

  def extract_data_attributes(authorization)
    authorization.authorization_request_class.constantize.extra_attributes
  end

  def authorization_request
    @authorization_request ||= AuthorizationRequest.find(context.authorization_request.id)
  end

  def production_authorization
    @production_authorization ||= authorization_request.latest_authorization_of_stage('production')
  end

  def sandbox_authorization
    @sandbox_authorization ||= authorization_request.latest_authorization_of_stage('sandbox')
  end
end
