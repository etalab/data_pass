class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  before_save { email.downcase! }

  validates :external_id, presence: true, uniqueness: true

  has_and_belongs_to_many :organizations

  def full_name
    "#{family_name} #{given_name}"
  end
end
