class Organisms::Instruction::UserRights::TableComponentPreview < ViewComponent::Preview
  def with_users
    actor = User.find_by!(email: 'datapass@yopmail.com')
    users = User.with_roles.where.not(id: actor.id).limit(5)

    render Organisms::Instruction::UserRights::TableComponent.new(
      users: users,
      authority: Rights::ManagerAuthority.new(actor),
      current_user: actor,
      total_count: users.size
    )
  end

  def with_own_row_non_editable_as_manager
    actor = User.find_by!(email: 'datapass@yopmail.com')
    others = User.with_roles.where.not(id: actor.id).limit(4).to_a
    users = [actor, *others]

    render Organisms::Instruction::UserRights::TableComponent.new(
      users: users,
      authority: Rights::ManagerAuthority.new(actor),
      current_user: actor,
      total_count: users.size
    )
  end
end
