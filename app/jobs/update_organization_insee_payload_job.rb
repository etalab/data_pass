class UpdateOrganizationINSEEPayloadJob < ApplicationJob
  attr_reader :organization

  retry_on Faraday::ServerError, wait: :polynomially_longer, attempts: Float::INFINITY
  retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: Float::INFINITY
  retry_on Faraday::UnauthorizedError, wait: 1, attempts: 5

  def perform(organization_id)
    @organization = Organization.find(organization_id)

    return if last_update_within_24h?
    return if organization.foreign?

    update_organization_insee_payload
  # rubocop:disable Lint/SuppressedException
  rescue ActiveRecord::RecordNotFound
  end
  # rubocop:enable Lint/SuppressedException

  private

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
