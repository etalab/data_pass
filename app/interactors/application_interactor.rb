class ApplicationInteractor
  include Interactor

  def fail_with_error(key, errors: [], format: nil)
    context.fail!(error: { key:, errors:, format: })
  end
end
