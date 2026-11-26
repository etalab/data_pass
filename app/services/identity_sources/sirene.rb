class IdentitySources::Sirene
  ATTRIBUTE_NAMES = %i[source siret legal_name legal_form legal_category_code naf public_sector address].freeze
  UNAVAILABLE_SOURCE = 'sirene_unavailable'.freeze
  PENDING_SOURCE = 'sirene_pending'.freeze

  def self.attribute_names
    ATTRIBUTE_NAMES
  end

  def self.unavailable_source
    UNAVAILABLE_SOURCE
  end

  def self.pending_source
    PENDING_SOURCE
  end

  def refresh(organization)
    previous_insee_update = organization.last_insee_payload_updated_at

    UpdateOrganizationINSEEPayload.call(
      organization:,
      force_insee_refresh: true,
      tolerate_insee_entity_not_found: true
    )

    organization.last_insee_payload_updated_at != previous_insee_update
  end

  def attributes(organization)
    @organization = organization
    return ATTRIBUTE_NAMES.index_with(nil).merge(source: missing_payload_source, siret: organization.siret) if organization.insee_payload.blank?

    identity.merge(source: diffusible? ? 'sirene' : 'non_diffusible', address:)
  end

  private

  attr_reader :organization

  def identity
    {
      siret: organization.siret,
      legal_name: organization.name,
      legal_form: legal_form,
      legal_category_code: organization.legal_category_code,
      naf: organization.decorate.code_naf_with_libelle,
      public_sector: public_sector,
    }
  end

  def diffusible?
    organization.etablissement_diffusible?
  end

  def legal_form
    CategorieJuridique.find(organization.legal_category_code).libelle
  rescue StaticApplicationRecord::EntryNotFound
    organization.legal_category_code
  end

  def missing_payload_source
    organization.insee_consecutive_failures.to_i.positive? ? UNAVAILABLE_SOURCE : PENDING_SOURCE
  end

  def public_sector
    classification = PublicSectorClassification.new(organization)

    classification.public_sector?.to_s if classification.known?
  end

  def address
    postal_address = INSEEPostalAddress.new(organization.insee_payload.dig('etablissement', 'adresseEtablissement'))

    postal_address.to_s if postal_address.known?
  end
end
