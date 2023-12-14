class Seeds
  def perform
    create_entities

    create_authorization_request(:api_entreprise)
    create_authorization_request(:api_entreprise, state: 'submitted', description: very_long_description)
    create_authorization_request(:hubee_cert_dc)
  end

  def flushdb
    raise 'Not in production!' if Rails.env.production?

    load_all_models!

    ActiveRecord::Base.connection.transaction do
      ApplicationRecord.descendants.each(&:delete_all)
    end
  end

  private

  def create_entities
    organization.users << user
  end

  def user
    @user ||= User.create!(
      email: 'user@yopmail.com',
      external_id: '1',
      current_organization: organization
    )
  end

  def organization
    @organization ||= Organization.create!(
      siret: '21920023500014',
      last_mon_compte_pro_updated_at: DateTime.now,
      mon_compte_pro_payload: {
        label: 'Commune de clamart - Mairie'
      },
    )
  end

  def create_authorization_request(kind, options = {})
    FactoryBot.create(
      :authorization_request,
      kind,
      options.merge(
        applicant: user,
        organization:,
      )
    )
  end

  def very_long_description
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl.'
  end

  def load_all_models!
    Dir[Rails.root.join('app/models/**/*.rb')].each { |f| require f }
  end
end
