class Import::Users < Import::Base
  include LocalDatabaseUtils

  def extract(user_row)
    user = User.find_or_initialize_by(email: user_row['email'].downcase.strip)
    user_organizations = Organization.where(siret: sanitize_user_organizations(user_row['organizations']).map { |org| org['siret'] }).distinct

    user.phone_number ||= user_row['phone_number']
    user.created_at ||= user_row['created_at']
    user.given_name ||= user_row['given_name'].try(:strip)
    user.family_name ||= user_row['family_name'].try(:strip)
    user.job_title ||= user_row['job_title'].try(:strip)
    user.email_verified ||= to_boolean(user_row['email_verified'])
    user.external_id ||= user_row['uid']

    (user_organizations.to_a.concat(extra_organizations(user_row['uid']))).each do |organization|
      user.organizations << organization unless user.organizations.include?(organization)
    end

    user.current_organization = user_organizations.first if user.current_organization.blank?
    user.organizations << user.current_organization unless user.organizations.include?(user.current_organization)

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

  def extra_organizations(user_external_id)
    sirets = {
      '13025' => ['23130002100012', '20005375900011', '23450002300028', '20005372600028', '20005376700014', '20005550700012', '20005379100014', '20005376700014', '20005267800014'],
      '14308' => ['18450311800020'],
      '66565' => ['22270229200012'],
      '39697' => ['89991311500015'],
      '47430' => ['12000018700027', '12002503600035'],
      '85017' => ['21440109300015'],
      '210355' => ['21860194600013'],
      '223733' => ['21300133200146'],
    }[user_external_id]

    if sirets.present?
      Organization.where(siret: sirets)
    else
      []
    end
  end

  def organization_sirets
    @organization_sirets ||= Organization.pluck(:siret)
  end

  def csv_or_table_to_loop
    if options[:users_sql_where].present?
      @rows_from_sql = true
      database.execute("SELECT * FROM users WHERE #{options[:users_sql_where]}")
    else
      super
    end
  end
end
