class Organisms::Instruction::UserRights::TableComponent < ApplicationComponent
  HEADERS = %w[email family_name given_name rights actions].freeze

  def initialize(users:, actor:)
    @users = users
    @actor = actor
  end

  private

  attr_reader :users, :actor
end
