class RegisterOrganizationWithContactsOnCRMJob < ApplicationJob
  attr_reader :authorization_request

  def perform(authorization_request_id)
    return unless hubspot_enabled?

    @authorization_request = AuthorizationRequest.find_by(id: authorization_request_id)

    return unless authorization_request

    crm_company = find_or_create_company_on_crm

    valid_contacts.each do |contact|
      add_contact_to_company(
        find_or_create_contact_on_crm(contact),
        crm_company
      )
    end
  end

  private

  def create_contact_on_crm(contact)
    crm_client.create_contact(
      email: contact.email,
      firstname: contact.given_name,
      lastname: contact.family_name,
      phone: contact.phone_number,
      type_de_contact: humanize_contact_types(extract_contact_type(contact)),
      bouquet_s__associe_s_: extract_bouquet(:contact)
    )
  end

  def create_company_on_crm
    crm_client.create_company(
      siret: organization.siret,
      name: organization.raison_sociale,
      categorie_juridique: organization.categorie_juridique.try(:code),
      n_datapass: authorization_request.id.to_s,
      bouquets_utilises: extract_bouquet(:company)
    )
  end

  def find_or_create_company_on_crm
    crm_company = crm_client.find_company_by_siret(organization.siret, properties_to_include: company_properties_to_retrieve)

    update_multi_attributes_on_company(crm_company) if crm_company

    crm_company ||
      create_company_on_crm
  end

  def find_or_create_contact_on_crm(contact)
    crm_contact = crm_client.find_contact_by_email(contact.email, properties_to_include: contact_properties_to_retrieve)

    update_multi_attributes_on_contact(crm_contact, contact) if crm_contact

    crm_contact ||
      create_contact_on_crm(contact)
  end

  def add_contact_to_company(crm_contact, crm_company)
    crm_client.add_contact_to_company(crm_contact, crm_company)
  end

  def valid_contacts
    authorization_request.contacts.select { |contact|
      valid_contact_types.include?(contact.type.to_sym)
    } << authorization_request.applicant
  end

  def valid_contact_types
    %i[contact_metier contact_technique responsable_technique responsable_traitement delegue_protection_donnees]
  end

  # rubocop:disable Metrics/AbcSize
  def update_multi_attributes_on_company(crm_company)
    datapass_ids = crm_company.properties['n_datapass']

    datapass_ids = if datapass_ids.present? && datapass_ids.split(';').map(&:to_i).exclude?(authorization_request.id)
                     datapass_ids << "; #{authorization_request.id}"
                   else
                     authorization_request.id.to_s
                   end

    bouquets_utilises = crm_company.properties['bouquets_utilises']

    if bouquets_utilises.present? && bouquets_utilises.exclude?(extract_bouquet(:company))
      bouquets_utilises << "; #{extract_bouquet(:company)}"
    else
      bouquets_utilises = extract_bouquet(:company)
    end

    crm_client.update_company(
      crm_company, {
        n_datapass: datapass_ids,
        bouquets_utilises:
      }
    )
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def update_multi_attributes_on_contact(crm_contact, contact)
    contact_types = crm_contact.properties['type_de_contact']
    current_content_type = extract_contact_type(contact)

    if contact_types.present? && contact_types.exclude?(humanize_contact_types(contact.type))
      contact_types << "; #{humanize_contact_types(current_content_type)}"
    else
      contact_types = humanize_contact_types(current_content_type)
    end

    bouquets_utilises = crm_contact.properties['bouquet_s__associe_s_']

    if bouquets_utilises.present? && bouquets_utilises.exclude?(extract_bouquet(:contact))
      bouquets_utilises << "; #{extract_bouquet(:contact)}"
    else
      bouquets_utilises = extract_bouquet(:contact)
    end

    crm_client.update_contact(
      crm_contact, {
        type_de_contact: contact_types,
        bouquet_s__associe_s_: bouquets_utilises
      }
    )
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def company_properties_to_retrieve
    %w[
      n_datapass
      bouquet_s__associe_s_
    ]
  end

  def contact_properties_to_retrieve
    %w[
      type_de_contact
      bouquets_utilises
    ]
  end

  def humanize_contact_types(type)
    case type.to_s
    when 'contact_metier'
      'Contact Métier'
    when 'responsable_technique', 'contact_technique'
      'Contact Technique'
    when 'delegue_protection_donnees'
      'Délégué à la protection des données'
    when 'demandeur'
      'Demandeur'
    when 'responsable_traitement'
      'Responsable de traitement'
    end
  end

  # rubocop:disable Metrics/MethodLength
  def extract_bouquet(kind)
    case authorization_request.type
    when 'AuthorizationRequest::APIEntreprise'
      if kind == :company
        'ENTREPRISE'
      else
        'API Entreprise'
      end
    when 'AuthorizationRequest::APIParticulier'
      if kind == :company
        'PARTICULIER'
      else
        'API Particulier'
      end
    when 'AuthorizationRequest::FranceConnect'
      if kind == :company
        'FRANCE_CONNECT'
      else
        'FranceConnect'
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def extract_contact_type(contact)
    if contact.is_a?(User)
      'demandeur'
    else
      contact.type.to_s
    end
  end

  def organization
    @organization ||= authorization_request.organization
  end

  def hubspot_enabled?
    Rails.env.local? ||
      Rails.application.credentials.hubspot_private_app_access_token.present?
  end

  def crm_client
    @crm_client ||= HubspotAPI.new
  end
end
