class Molecules::Instruction::UserRights::TableRowComponent < ApplicationComponent
  def initialize(user:, authority:)
    @user = user
    @authority = authority
  end

  private

  attr_reader :user, :authority

  def visible_rights
    Instruction::UserRightsView.new(authority: authority, user: user).grouped_visible
  end
end
