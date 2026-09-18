class UpdateOrganizationINSEEPayloadJob < ApplicationJob
  INSEE_CALLS_PAUSE_DURATION = 6.hours

  attr_reader :organization

  retry_on Faraday::ServerError, wait: :polynomially_longer, attempts: Float::INFINITY
  retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: Float::INFINITY
  retry_on INSEESireneAPIClient::InvalidResponseError, wait: :polynomially_longer, attempts: Float::INFINITY
  rescue_from INSEESireneAPIClient::EntityNotFoundError do |e|
    Sentry.capture_exception(e, level: :warning)
  end
  discard_on Faraday::UnauthorizedError do |_job, error|
    insee_calls_pause.mark(expires_in: INSEE_CALLS_PAUSE_DURATION)
    Sentry.capture_exception(error)
  end

  def self.insee_calls_pause
    Kredis.flag('insee_calls_pause')
  end

  def perform(organization_id)
    return if skip_development?
    return if self.class.insee_calls_pause.marked?

    @organization = Organization.find(organization_id)

    return if last_update_within_24h?
    return if organization.foreign?

    update_organization_insee_payload
  # rubocop:disable Lint/SuppressedException
  rescue ActiveRecord::RecordNotFound
  end
  # rubocop:enable Lint/SuppressedException

  private

  def skip_development?
    Rails.env.development? && ENV.fetch('INSEE_CLIENT_ID', Rails.application.credentials.insee_client_id).blank?
  end

  def last_update_within_24h?
    organization.last_insee_update_within_24h?
  end

  def update_organization_insee_payload
    organization.update(
      insee_payload:,
      last_insee_payload_updated_at: DateTime.current,
    )
  end

  def insee_payload
    INSEESireneAPIClient.new.etablissement(siret: organization.siret)
  end
end
