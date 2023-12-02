class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  before_save { email.downcase! }

  validates :external_id, presence: true, uniqueness: true

  has_and_belongs_to_many :organizations
end
