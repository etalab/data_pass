class AuthorizationDocument < ApplicationRecord
  belongs_to :authorization

  has_one_attached :file

  validates :identifier, presence: true
end
