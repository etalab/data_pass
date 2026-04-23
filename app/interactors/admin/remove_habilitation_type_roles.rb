class Admin::RemoveHabilitationTypeRoles < ApplicationInteractor
  def call
    uid = context.habilitation_type.uid
    fd_slug = context.habilitation_type.data_provider.slug

    exact_roles = User::ROLES.map { |role_type| "#{fd_slug}:#{uid}:#{role_type}" }
    User.with_role_matching(exact_roles).find_each do |user|
      user.roles.reject! { |r| ParsedRole.parse(r).definition_id == uid }
      user.save!
    end
  end
end
