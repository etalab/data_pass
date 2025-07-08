class DataProvider < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :logo,
    :link

  def self.backend
    Rails.application.config_for(:data_providers).map do |uid, hash|
      new(id: uid.to_s, **hash.symbolize_keys)
    end
  end

  def authorization_definitions
    @authorization_definitions ||= AuthorizationDefinition.all.select do |authorization_definition|
      authorization_definition.provider.id == id
    end
  end

  def reporters
    users_for_roles(%w[instructor reporter])
  end

  def instructors
    users_for_roles(%w[instructor])
  end

  private

  def users_for_roles(roles)
    User.where(
      "EXISTS (
        SELECT 1
        FROM unnest(roles) AS role
        WHERE role in (?)
      )",
      roles.map { |role| build_user_role_query_param(role) }.flatten,
    )
  end

  def build_user_role_query_param(role)
    authorization_definitions.map do |authorization_definition|
      "#{authorization_definition.id}:#{role}"
    end
  end
end
