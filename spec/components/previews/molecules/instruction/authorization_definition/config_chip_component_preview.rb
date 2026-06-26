class Molecules::Instruction::AuthorizationDefinition::ConfigChipComponentPreview < ApplicationPreview
  def boolean_value
    render Molecules::Instruction::AuthorizationDefinition::ConfigChipComponent.new(
      label: 'Démarrable par le demandeur'
    ) do |chip|
      chip.with_value { tag.span('Oui', class: 'config-chip__value') }
    end
  end

  def code_value
    render Molecules::Instruction::AuthorizationDefinition::ConfigChipComponent.new(
      label: 'Type'
    ) do |chip|
      chip.with_value { tag.code('api', class: 'fr-code-inline') }
    end
  end

  def link_value
    render Molecules::Instruction::AuthorizationDefinition::ConfigChipComponent.new(
      label: 'Email de support'
    ) do |chip|
      chip.with_value { tag.a('support@example.com', href: 'mailto:support@example.com', class: 'fr-link') }
    end
  end
end
