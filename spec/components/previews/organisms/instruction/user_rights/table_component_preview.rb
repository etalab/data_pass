class Organisms::Instruction::UserRights::TableComponentPreview < ViewComponent::Preview
  def with_users
    actor = User.find_by!(email: 'datapass@yopmail.com')
    users = User.with_roles.where.not(id: actor.id).limit(5)

    render Organisms::Instruction::UserRights::TableComponent.new(users: users, actor: actor)
  end
end
