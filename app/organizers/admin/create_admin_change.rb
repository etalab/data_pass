class Admin::CreateAdminChange < ApplicationOrganizer
  def self.call(context = {}, &block)
    context[:block] = block if block
    super(context)
  end

  before do
    context.event_name = 'admin_change'
    context.event_entity = :admin_change
  end

  organize Admin::BuildAdminChangeDiff,
    Admin::PersistAdminChange,
    CreateAuthorizationRequestEventModel
end
