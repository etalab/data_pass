class Admin::CreateHabilitationType < ApplicationOrganizer
  before do
    context.admin_entity_key = :habilitation_type
    context.admin_event_name = 'habilitation_type_created'
    context.admin_before_attributes = {}
  end

  organize Admin::PersistNewHabilitationType,
    Admin::TrackEvent
end
