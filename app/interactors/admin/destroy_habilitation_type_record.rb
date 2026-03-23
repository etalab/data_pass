class Admin::DestroyHabilitationTypeRecord < ApplicationInteractor
  def call
    context.habilitation_type.destroy!
  end
end
