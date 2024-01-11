require 'json'

class Import::Organizations < Import::Base
  def perform
    log("# Importing organizations")

    count = 0

    csv('users').each do |user_row|
      next unless import?(user_row)

      sanitize_user_organizations(user_row['organizations']).each do |organization_data|
        organization = Organization.find_or_initialize_by(siret: organization_data['siret'])

        count += 1 if organization.new_record?

        organization.assign_attributes(
          mon_compte_pro_payload: organization_data,
          last_mon_compte_pro_updated_at: DateTime.now
        )

        organization.save!
      end
    end

    log("- #{count} organizations imported")
  end

  private

  def import?(user_row)
    options[:users_filter].present? &&
      options[:users_filter].call(user_row)
  end

  def sanitize_user_organizations(organizations)
    json = organizations
      .gsub('{"{', '[{')
      .gsub('}"}', '}]')
      .gsub('\\"', '"')

    JSON.parse(json)
  end
end
