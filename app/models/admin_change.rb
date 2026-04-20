class AdminChange < ApplicationRecord
  include CommonInstructionModel

  validates :public_reason, presence: true

  def legacy? = false
  def initial? = false
end
