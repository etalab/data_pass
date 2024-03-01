class OrganizationDecorator < ApplicationDecorator
  delegate_all

  def code_naf_with_libelle
    return if code_naf.blank?

    [
      code_naf,
      CodeNAF.find(code_naf).libelle,
    ].join(' - ')
  end

  def code_naf
    return unless insee_payload?

    unite_legale_insee_payload['activitePrincipaleUniteLegale']
  end

  def address
    return unless insee_payload?

    [
      address_first_line,
      address_second_line,
    ].compact.join('<br />').html_safe
  end

  def address_first_line
    return unless insee_payload?

    [
      address_etablissement_insee_payload['numeroVoieEtablissement'],
      address_etablissement_insee_payload['typeVoieEtablissement'],
      address_etablissement_insee_payload['libelleVoieEtablissement'],
    ].compact.join(' ')
  end

  def address_second_line
    return unless insee_payload?

    [
      address_etablissement_insee_payload['codePostalEtablissement'],
      address_etablissement_insee_payload['libelleCommuneEtablissement'],
    ].compact.join(' ')
  end

  private

  def unite_legale_insee_payload
    etablissement_insee_payload['uniteLegale']
  end

  def etablissement_insee_payload
    insee_payload['etablissement']
  end

  def address_etablissement_insee_payload
    etablissement_insee_payload['adresseEtablissement']
  end

  def insee_payload
    object.insee_payload
  end

  def insee_payload?
    insee_payload.present?
  end
end
