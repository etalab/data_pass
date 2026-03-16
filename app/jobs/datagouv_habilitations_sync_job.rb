class DatagouvHabilitationsSyncJob < ApplicationJob
  queue_as :default

  retry_on Faraday::ServerError, wait: :polynomially_longer, attempts: 5
  retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: 5
  retry_on DatagouvAPIClient::ServerError, wait: :polynomially_longer, attempts: 5

  def perform
    return unless api_key_configured?

    result = ExportDatagouvHabilitations.call
    raise result.error if result.failure?
  end

  private

  def api_key_configured?
    Rails.application.credentials.dig(:data_gouv_fr, :api_key).present?
  end
end
