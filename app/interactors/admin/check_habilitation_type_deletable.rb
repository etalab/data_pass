class Admin::CheckHabilitationTypeDeletable < ApplicationInteractor
  def call
    return if context.habilitation_type.authorization_requests_count.zero?

    context.habilitation_type.errors.add(:base, :has_authorization_requests)
    context.fail!(error: :model_error, model: context.habilitation_type)
  end
end
