class Molecules::Instruction::UserRights::TableRowComponent < ApplicationComponent
  def initialize(user:, actor:)
    @user = user
    @actor = actor
  end

  private

  attr_reader :user, :actor

  def visible_rights
    Instruction::UserRightsView.new(manager: actor, user: user).grouped_visible
  end
end
