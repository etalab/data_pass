class Seeds
  def perform
    create_entities

    create_authorization_request(:api_entreprise)
    create_authorization_request(:api_entreprise, attributes: { state: 'submitted', description: very_long_description })
    create_authorization_request(:api_particulier, traits: %i[refused])
    create_authorization_request(:hubee_cert_dc)

    create_authorization_request(:api_infinoe_production, attributes: { state: 'draft' })
  end

  def flushdb
    raise 'Not in production!' if production?

    load_all_models!

    ActiveRecord::Base.connection.transaction do
      ApplicationRecord.descendants.each(&:delete_all)
    end
  end

  private

  def create_entities
    clamart_organization.users << demandeur
    dinum_organization.users << api_entreprise_instructor
  end

  def demandeur
    @demandeur ||= User.create!(
      email: 'user@yopmail.com',
      external_id: '1',
      current_organization: clamart_organization
    )
  end

  def api_entreprise_instructor
    @api_entreprise_instructor ||= User.create!(
      email: 'api-entreprise@yopmail.com',
      external_id: '4',
      current_organization: dinum_organization,
      roles: ['api_entreprise:instructor']
    )
  end

  def clamart_organization
    @clamart_organization ||= create_organization(siret: '21920023500014', name: 'Ville de Clamart')
  end

  def dinum_organization
    @dinum_organization ||= create_organization(siret: '13001518800019', name: 'DINUM')
  end

  def create_organization(siret:, name:)
    Organization.create!(
      siret:,
      last_mon_compte_pro_updated_at: DateTime.now,
      mon_compte_pro_payload: {
        label: name
      }
    )
  end

  def create_authorization_request(kind, attributes: {}, traits: [])
    traits << kind

    FactoryBot.create(
      :authorization_request,
      *traits,
      attributes.merge(
        applicant: demandeur,
        organization: clamart_organization,
      )
    )
  end

  def very_long_description
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl.'
  end

  def load_all_models!
    Dir[Rails.root.join('app/models/**/*.rb')].each { |f| require f }
  end

  def production?
    Rails.env.production? && ENV['CAN_FLUSH_DB'].blank?
  end
end
