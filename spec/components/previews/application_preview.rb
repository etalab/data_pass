class ApplicationPreview < ViewComponent::Preview
  delegate_missing_to :helpers

  private :method_missing, :respond_to_missing?

  private

  def helpers
    ApplicationController.helpers
  end
end
