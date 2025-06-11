class Admin::TrackImpersonationStart < ApplicationInteractor
  def call
    AdminEvent.create!(
      admin: context.admin,
      name: 'impersonate_user',
      entity: context.impersonation
    )
  end
end
