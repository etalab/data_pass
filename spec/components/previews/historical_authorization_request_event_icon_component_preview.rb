# @label Icône d'événement de demande d'autorisation
class HistoricalAuthorizationRequestEventIconComponentPreview < ApplicationPreview
  # @param name select { choices: ['approve', 'reject', 'request_changes'] } "Type d'événement"

  def default(name: 'approve')
    render HistoricalAuthorizationRequestEventIconComponent.new(name:)
  end
end
