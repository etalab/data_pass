class Organisms::Instruction::UserRights::TableComponent < ApplicationComponent
  HEADERS = %w[identity organisation roles droits actions].freeze

  def initialize(users:, authority:, current_user:, total_count:)
    @users = users
    @authority = authority
    @current_user = current_user
    @total_count = total_count
  end

  private

  attr_reader :users, :authority, :current_user, :total_count
end
