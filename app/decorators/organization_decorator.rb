class OrganizationDecorator < ApplicationDecorator
  delegate_all

  def code_naf_with_libelle
    with_legal_entity_info(:code_naf_with_libelle) do
      return if code_naf.blank?

      [
        code_naf,
        code_naf_libelle,
      ].join(' - ')
    end
  end

  def address
    with_legal_entity_info(:address) do
      return unless insee_payload?

      [
        address_first_line,
        address_second_line,
      ].compact.join('<br />').html_safe
    end
  end

  private

  def code_naf_libelle
    CodeNAF.find(code_naf).libelle
  rescue StaticApplicationRecord::EntryNotFound
    'Activité inconnue'
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

  def code_naf
    return unless insee_payload?

    unite_legale_insee_payload['activitePrincipaleUniteLegale']
  end

  def unite_legale_insee_payload
    etablissement_insee_payload['uniteLegale']
  end

  def etablissement_insee_payload
    insee_payload['etablissement']
  end

  def address_etablissement_insee_payload
    etablissement_insee_payload['adresseEtablissement']
  end

  def with_legal_entity_info(attr_name)
    if legal_entity_registry == 'insee_sirene'
      yield
    else
      extra_legal_entity_infos[attr_name.to_s]
    end
  end

  def insee_payload?
    insee_payload.present?
  end
end
