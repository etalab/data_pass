class Admin::CreateImpersonation < ApplicationInteractor
  def call
    context.impersonation = create_impersonation_record

    return if context.impersonation.persisted?

    context.fail!(error: :model_error, model: context.impersonation)
  end

  private

  def create_impersonation_record
    Impersonation.create(
      context.impersonation_params.merge(
        user: context.target_user,
        admin: context.admin,
      )
    )
  end
end
