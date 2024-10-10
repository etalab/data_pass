class UpdateOrganizationINSEEPayloadJob < ApplicationJob
  attr_reader :organization

  retry_on Faraday::ServerError, wait: :polynomially_longer, attempts: Float::INFINITY
  retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: Float::INFINITY

  def perform(organization_id)
    @organization = Organization.find(organization_id)

    return if last_update_within_24h?

    update_organization_insee_payload
  # rubocop:disable Lint/SuppressedException
  rescue ActiveRecord::RecordNotFound
  end
  # rubocop:enable Lint/SuppressedException

  private

  def last_update_within_24h?
    organization.last_insee_payload_updated_at.present? &&
      organization.last_insee_payload_updated_at > 24.hours.ago
  end

  def update_organization_insee_payload
    organization.update(
      insee_payload:,
      last_insee_payload_updated_at: DateTime.current,
    )
  end

  def insee_payload
    if Rails.env.development?
      mocked_insee_payload_for_development
    else
      INSEESireneAPIClient.new.etablissement(siret: organization.siret)
    end
  end

  def mocked_insee_payload_for_development
    return organization.insee_payload if organization.insee_payload.present?

    {
      'etablissement' => {
        'adresseEtablissement' => {
          'numeroVoieEtablissement' => '1',
          'typeVoieEtablissement' => 'PLACE',
          'libelleVoieEtablissement' => "DE LA COMEDIE (c'est pas vrai)",
          'codeCommuneEtablissement' => '69381',
          'codePostalEtablissement' => '69001',
          'libelleCommuneEtablissement' => "LYON (c'est pas vrai)"
        },
        'uniteLegale' => {
          'denominationUniteLegale' => "COMMUNE DE LYON (c'est pas vrai)",
          'categorieJuridiqueUniteLegale' => '7210',
          'activitePrincipaleUniteLegale' => '84.11Z',
        }
      }
    }
  end
end
