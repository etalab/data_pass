class DeprecateLinkedAuthorizations < ApplicationInteractor
  delegate :deprecated_authorizations, to: :context

  def call
    return if deprecated_authorizations.blank?

    linked_authorizations.each(&:deprecate!)
  end

  private

  def linked_authorizations
    Authorization.where(parent_authorization_id: deprecated_authorizations.pluck(:id))
  end
end
