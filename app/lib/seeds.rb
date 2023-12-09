class Seeds
  def perform; end

  def flushdb
    raise 'Not in production!' if Rails.env.production?

    load_all_models!

    ActiveRecord::Base.connection.transaction do
      ApplicationRecord.descendants.each(&:delete_all)
    end
  end

  private

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
      mon_compte_pro_payload: {
        label: 'Commune de clamart - Mairie'
      },
    )
  end

  def load_all_models!
    Dir[Rails.root.join('app/models/**/*.rb')].each { |f| require f }
  end
end
