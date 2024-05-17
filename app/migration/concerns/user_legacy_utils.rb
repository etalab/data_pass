module UserLegacyUtils
  extend ActiveSupport::Concern

  include LocalDatabaseUtils

  def all_legacy_users_id_to_email
    @all_legacy_users_id_to_email ||= database.execute('select id, email from users').to_h
  end

  def all_users_email_to_id
    @all_users_email_to_id ||= User.pluck(:email, :id).to_h
  end

  def legacy_user_id_to_user_id(legacy_id)
    all_users_email_to_id[all_legacy_users_id_to_email[legacy_id.to_i]]
  end
end
