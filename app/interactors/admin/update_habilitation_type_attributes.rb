class Admin::UpdateHabilitationTypeAttributes < ApplicationInteractor
  def call
    return if context.habilitation_type.update(context.params)

    context.fail!(error: :model_error, model: context.habilitation_type)
  end
end
