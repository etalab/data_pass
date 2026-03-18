class Admin::UpdateDataProvider < ApplicationOrganizer
  before do
    context.admin_entity_key = :data_provider
    context.admin_event_name = 'data_provider_updated'
    context.admin_before_attributes = {
      name: context.data_provider.name,
      link: context.data_provider.link,
      logo: context.data_provider.logo.filename.to_s,
    }
  end

  organize Admin::UpdateDataProviderAttributes,
    Admin::TrackEvent
end
