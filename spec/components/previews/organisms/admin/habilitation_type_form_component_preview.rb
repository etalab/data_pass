class Organisms::Admin::HabilitationTypeFormComponentPreview < ViewComponent::Preview
  def new_record
    render Organisms::Admin::HabilitationTypeFormComponent.new(
      habilitation_type: HabilitationType.new(blocks: HabilitationType::BLOCK_ORDER)
    )
  end

  def existing_record
    render Organisms::Admin::HabilitationTypeFormComponent.new(
      habilitation_type: HabilitationType.first
    )
  end
end
