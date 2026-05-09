class Admin::RemoveHabilitationTypeRoles < ApplicationInteractor
  def call
    UserRole.where(authorization_definition_id: context.habilitation_type.uid).destroy_all
  end
end
