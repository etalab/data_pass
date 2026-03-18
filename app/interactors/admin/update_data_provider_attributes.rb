class Admin::UpdateDataProviderAttributes < ApplicationInteractor
  def call
    return if context.data_provider.update(context.params)

    context.fail!(error: :model_error, model: context.data_provider)
  end
end
