class Import::Users < Import::Base
  def extract(user_row)
    user = User.find_or_initialize_by(email: user_row['email'])
    user_organizations = Organization.where(siret: sanitize_user_organizations(user_row['organizations']).map { |org| org['siret'] })

    user.assign_attributes(
      user_row.to_h.slice(
        'given_name',
        'family_name',
        'phone_number',
      ).merge(
        given_name: user_row['given_name'].strip,
        family_name: user_row['family_name'].strip,
        job_title: user_row['job'].strip,
        email_verified: to_boolean(user_row['email_verified']),
        external_id: user_row['uid'],
      )
    )

    user.organizations = user_organizations
    user.current_organization = user_organizations.first if user.current_organization.blank?

    user.save!

    @models << user
  end

  private

  def import?(user_row)
    options[:users_filter].present? &&
      options[:users_filter].call(user_row) &&
      in_organizations?(user_row)
  end

  def in_organizations?(user_row)
    sanitize_user_organizations(user_row['organizations']).map { |org| org['siret'] } & organization_sirets != []
  end

  def organization_sirets
    @organization_sirets ||= organizations.map(&:siret)
  end

  def organizations
    @organizations ||= options[:organizations]
  end
end
