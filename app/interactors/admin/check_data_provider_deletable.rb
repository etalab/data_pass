class Admin::CheckDataProviderDeletable < ApplicationInteractor
  def call
    fail_with(:has_habilitation_types) if context.data_provider.linked_habilitation_types?
    fail_with(:has_authorization_definitions) if context.data_provider.authorization_definitions.any?
  end

  private

  def fail_with(error_key)
    context.data_provider.errors.add(:base, error_key)
    context.fail!(error: :model_error, model: context.data_provider)
  end
end
