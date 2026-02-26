class DatagouvHabilitationsSyncJob < ApplicationJob
  queue_as :default

  retry_on Faraday::ServerError, wait: :polynomially_longer, attempts: 5
  retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: 5

  def perform
    return unless api_key_configured?

    result = ExportDatagouvHabilitations.call
    cleanup_csv(result)
    raise result.error if result.failure?
  end

  private

  def api_key_configured?
    Rails.application.credentials.dig(:data_gouv_fr, :api_key).present?
  end

  def cleanup_csv(result)
    return unless result.csv_path.present? && File.exist?(result.csv_path)

    File.delete(result.csv_path)
  end
end
