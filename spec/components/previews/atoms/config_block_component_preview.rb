class Atoms::ConfigBlockComponentPreview < ApplicationPreview
  def default
    render Atoms::ConfigBlockComponent.new(
      rows: [
        { label: 'Type', value: tag.strong('Production') },
        { label: 'Activé', value: tag.span('Oui', class: 'config-block__badge config-block__badge--success') },
        { label: 'Email support', value: mail_to('support@example.com', 'support@example.com', class: 'fr-link') }
      ]
    )
  end
end
