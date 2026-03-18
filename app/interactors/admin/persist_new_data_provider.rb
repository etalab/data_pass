class Admin::PersistNewDataProvider < ApplicationInteractor
  def call
    context.data_provider = DataProvider.create(context.params)

    return if context.data_provider.persisted?

    context.fail!(error: :model_error, model: context.data_provider)
  end
end
