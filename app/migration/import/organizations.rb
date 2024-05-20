require 'json'

class Import::Organizations < Import::Base
  def extract(user_row)
    sanitize_user_organizations(user_row['organizations']).each do |organization_data|
      organization = Organization.find_or_initialize_by(siret: organization_data['siret'])

      organization.mon_compte_pro_payload = organization_data if organization.mon_compte_pro_payload.blank?
      organization.last_mon_compte_pro_updated_at ||= DateTime.current
      organization.created_at ||= user_row['created_at']

      organization.save!

      @models << organization
    end
  end

  def after_load_from_csv
    return if Organization.find_by(siret: '89991311500015').present?

    @models << Organization.create!(
      siret: '89991311500015',
      mon_compte_pro_payload: {
        siret: '89991311500015',
      },
      last_mon_compte_pro_updated_at: 1.year.ago,
    )
  end

  private

  def csv_or_table_to_loop
    csv('users')
  end
end
