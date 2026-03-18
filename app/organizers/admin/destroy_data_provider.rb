class Admin::DestroyDataProvider < ApplicationOrganizer
  before do
    context.admin_entity_key = :data_provider
    context.admin_event_name = 'data_provider_destroyed'
    context.admin_before_attributes = {
      name: context.data_provider.name,
      slug: context.data_provider.slug,
    }
  end

  organize Admin::CheckDataProviderDeletable,
    Admin::DestroyDataProviderRecord,
    Admin::TrackEvent
end
