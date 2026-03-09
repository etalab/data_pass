class Admin::UpdateHabilitationType < ApplicationOrganizer
  before do
    context.admin_entity_key = :habilitation_type
    context.admin_event_name = 'habilitation_type_updated'
    context.admin_before_attributes = {
      name: context.habilitation_type.name,
      blocks: context.habilitation_type.blocks,
    }
  end

  organize Admin::UpdateHabilitationTypeAttributes,
    Admin::TrackEvent
end
