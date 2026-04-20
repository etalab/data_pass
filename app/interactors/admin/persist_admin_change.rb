class Admin::PersistAdminChange < ApplicationInteractor
  def call
    admin_change = AdminChange.new(
      authorization_request: context.authorization_request,
      public_reason: context.public_reason,
      private_reason: context.private_reason,
      diff: context.diff,
    )

    context.fail!(errors: admin_change.errors) unless admin_change.save

    context.admin_change = admin_change
  end

  def rollback
    context.admin_change.destroy
  end
end
