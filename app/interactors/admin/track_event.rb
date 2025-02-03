class Admin::TrackEvent < ApplicationInteractor
  def call
    create_event!
  end

  private

  def create_event!
    AdminEvent.create!(
      name: context.admin_event_name,
      admin: context.admin,
      before_attributes: context.admin_before_attributes,
      after_attributes:,
      entity:,
    )
  end

  def entity
    context.send(context.admin_entity_key)
  end

  def after_attributes
    context.admin_before_attributes.keys.index_with do |key|
      entity.send(key)
    end
  end
end
