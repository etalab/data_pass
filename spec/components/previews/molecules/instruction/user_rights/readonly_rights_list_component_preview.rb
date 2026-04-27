class Molecules::Instruction::UserRights::ReadonlyRightsListComponentPreview < ViewComponent::Preview
  def with_rights
    render Molecules::Instruction::UserRights::ReadonlyRightsListComponent.new(rights: sample_rights)
  end

  def empty
    render Molecules::Instruction::UserRights::ReadonlyRightsListComponent.new(rights: [])
  end

  private

  def sample_rights
    [
      { scope: 'dinum:api_entreprise', role_type: 'developer' },
      { scope: 'dinum:api_particulier', role_type: 'developer' }
    ]
  end
end
