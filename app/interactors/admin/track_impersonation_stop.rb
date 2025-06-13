class Admin::TrackImpersonationStop < ApplicationInteractor
  def call
    AdminEvent.create!(
      admin: context.admin,
      name: 'impersonate_stop',
      entity: context.current_user
    )
  end
end
