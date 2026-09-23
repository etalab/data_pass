class UpdateOrganizationINSEEPayloadJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  MAX_ATTEMPTS = 5

  queue_as :insee

  good_job_control_concurrency_with(
    key: 'insee',
    perform_throttle: -> { [Setting.fetch(:insee_calls_per_minute), 1.minute] },
  )

  attr_reader :organization

  retry_on Faraday::ServerError, wait: :polynomially_longer, attempts: MAX_ATTEMPTS
  retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: MAX_ATTEMPTS
  retry_on INSEESireneAPIClient::InvalidResponseError, wait: :polynomially_longer, attempts: MAX_ATTEMPTS

  rescue_from INSEESireneAPIClient::EntityNotFoundError do |e|
    Sentry.capture_exception(e, level: :warning)
  end

  discard_on AbstractINSEEAPIClient::UnavailableError do |_job, error|
    Sentry.capture_exception(error, level: :warning)
  end

  def perform(organization_id)
    return if skip_development?
    return unless AbstractINSEEAPIClient.calls_allowed?

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
    Rails.env.development? && Setting.fetch(:insee_client_id).blank?
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
