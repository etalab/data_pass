class Organisms::Instruction::UserRights::TableComponent < ApplicationComponent
  HEADERS = %w[email family_name given_name rights actions].freeze

  def initialize(users:, authority:)
    @users = users
    @authority = authority
  end

  private

  attr_reader :users, :authority
end
