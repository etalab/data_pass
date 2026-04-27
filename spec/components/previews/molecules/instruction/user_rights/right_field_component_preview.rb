class Molecules::Instruction::UserRights::RightFieldComponentPreview < ViewComponent::Preview
  def empty
    render Molecules::Instruction::UserRights::RightFieldComponent.new(
      index: 0,
      scope: '',
      role_type: '',
      permissions: definition_manager_permissions
    )
  end

  def filled
    render Molecules::Instruction::UserRights::RightFieldComponent.new(
      index: 1,
      scope: 'dinum:api_entreprise',
      role_type: 'manager',
      permissions: fd_manager_permissions
    )
  end

  def nested_form_template
    render Molecules::Instruction::UserRights::RightFieldComponent.new(
      index: 'NEW',
      scope: '',
      role_type: '',
      permissions: definition_manager_permissions
    )
  end

  private

  def definition_manager_permissions
    Instruction::ManagerScopeOptions.new(User.find_by!(email: 'datapass@yopmail.com'))
  end

  def fd_manager_permissions
    Instruction::ManagerScopeOptions.new(User.find_by!(email: 'datapass@yopmail.com'))
  end
end
