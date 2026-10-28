class RefreshOrganizationINSEENow < ApplicationInteractor
  def call
    return unless organization.insee_refresh_due?

    UpdateOrganizationINSEEPayloadJob.new.perform(organization.id)
    organization.reload
  rescue INSEESireneAPIClient::EntityNotFoundError, AbstractINSEEAPIClient::UnavailableError,
         INSEESireneAPIClient::InvalidResponseError, Faraday::Error => e
    Sentry.capture_exception(e, level: :warning)
  end

  private

  def organization
    context.organization
  end
end
