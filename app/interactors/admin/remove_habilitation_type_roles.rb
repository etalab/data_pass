class Admin::RemoveHabilitationTypeRoles < ApplicationInteractor
  def call
    uid = context.habilitation_type.uid

    User::ROLES.each do |role_type|
      role = "#{uid}:#{role_type}"

      User.where('? = ANY(roles)', role).find_each do |user|
        user.roles.delete(role)
        user.save!
      end
    end
  end
end
