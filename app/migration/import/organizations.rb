require 'json'

class Import::Organizations < Import::Base
  def extract(user_row)
    sanitize_user_organizations(user_row['organizations']).each do |organization_data|
      organization = Organization.find_or_initialize_by(siret: organization_data['siret'])

      organization.assign_attributes(
        mon_compte_pro_payload: organization_data,
        last_mon_compte_pro_updated_at: DateTime.now
      )

      organization.save!

      @models << organization
    end
  end

  private

  def csv_to_loop
    csv('users')
  end

  def import?(user_row)
    options[:users_filter].present? &&
      options[:users_filter].call(user_row)
  end
end
