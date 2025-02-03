class AdminEvent < ApplicationRecord
  validates :name, presence: true

  belongs_to :admin,
    class_name: 'User',
    inverse_of: :admin_events

  belongs_to :entity,
    polymorphic: true
end
