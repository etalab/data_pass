class Admin::CreateDataProvider < ApplicationOrganizer
  before do
    context.admin_entity_key = :data_provider
    context.admin_event_name = 'data_provider_created'
    context.admin_before_attributes = {}
  end

  organize Admin::PersistNewDataProvider,
    Admin::TrackEvent
end
