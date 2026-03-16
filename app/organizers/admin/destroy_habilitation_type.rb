class Admin::DestroyHabilitationType < ApplicationOrganizer
  before do
    context.admin_entity_key = :habilitation_type
    context.admin_event_name = 'habilitation_type_destroyed'
    context.admin_before_attributes = {
      name: context.habilitation_type.name,
      slug: context.habilitation_type.slug,
    }
  end

  organize Admin::DestroyHabilitationTypeRecord,
    Admin::RemoveHabilitationTypeRoles,
    Admin::TrackEvent
end
