class Molecules::Instruction::UserRights::TableRowComponent < ApplicationComponent
  def initialize(user:, authority:, current_user:)
    @user = user
    @authority = authority
    @current_user = current_user
  end

  private

  attr_reader :user, :authority, :current_user

  def visible_rights
    Instruction::UserRightsView.new(authority: authority, user: user).grouped_visible
  end

  def own_row?
    user.id == current_user.id
  end

  def editable?
    !own_row? || authority.can_self_edit?
  end
end
