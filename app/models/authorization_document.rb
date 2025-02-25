class AuthorizationDocument < ApplicationRecord
  belongs_to :authorization

  has_many_attached :files

  validates :identifier, presence: true
end
