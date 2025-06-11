class Impersonation < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :impersonation_actions, dependent: :destroy

  validates :reason, presence: true
end
