class Import::Users < Import::Base
  def extract(user_row)
    user = User.find_or_initialize_by(email: user_row['email'])
    user_organizations = Organization.where(siret: sanitize_user_organizations(user_row['organizations']).map { |org| org['siret'] }).distinct

    user.assign_attributes(
      user_row.to_h.slice(
        'phone_number',
      ).merge(
        given_name: user_row['given_name'].try(:strip),
        family_name: user_row['family_name'].try(:strip),
        job_title: user_row['job'].try(:strip),
        email_verified: to_boolean(user_row['email_verified']),
        external_id: user_row['uid'],
      )
    )

    (user_organizations.concat(extra_organizations(user_row['id']))).each do |organization|
      user.organizations << organization unless user.organizations.include?(organization)
    end

    user.current_organization = user_organizations.first if user.current_organization.blank?

    user.save!

    @models << user
  end

  private

  def import?(user_row)
    organization_sirets.intersect?(
      sanitize_user_organizations(user_row['organizations']).map { |org| org['siret'] }
    )
  end

  def sql_tables_to_save
    @sql_tables_to_save ||= super.concat(['organizations_users'])
  end

  def extra_organizations(user_id)
    sirets = {
      '42364' => ['22270229200012'],
    }[user_id]

    if sirets.present?
      Organization.where(siret: sirets)
    else
      []
    end
  end

  def organization_sirets
    @organization_sirets ||= organizations.map(&:siret)
  end

  def organizations
    @organizations ||= options[:organizations]
  end
end
