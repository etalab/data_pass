class Admin::DestroyHabilitationTypeRecord < ApplicationInteractor
  def call
    return if context.habilitation_type.destroy

    context.fail!(error: :model_error, model: context.habilitation_type)
  end
end
