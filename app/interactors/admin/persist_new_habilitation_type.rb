class Admin::PersistNewHabilitationType < ApplicationInteractor
  def call
    context.habilitation_type = HabilitationType.create(context.params)

    return if context.habilitation_type.persisted?

    context.fail!(error: :model_error, model: context.habilitation_type)
  end
end
