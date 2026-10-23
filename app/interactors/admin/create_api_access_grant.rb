class Admin::CreateAPIAccessGrant < ApplicationInteractor
  def call
    context.grant = APIAccessGrant.new(grant_attributes)

    return if context.grant.save

    fail_with_model_error
  rescue ActiveRecord::RecordNotUnique
    context.grant.errors.add(:base, :already_granted)
    fail_with_model_error
  end

  private

  def grant_attributes
    context.params.merge(
      granted_by_id: context.admin.id,
      granted_by_email: context.admin.email
    )
  end

  def fail_with_model_error
    context.fail!(error: :model_error, model: context.grant)
  end
end
