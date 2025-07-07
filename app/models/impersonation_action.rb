class ImpersonationAction < ApplicationRecord
  belongs_to :impersonation

  validates :action, presence: true, inclusion: { in: %w[create update destroy] }
  validates :model_type, presence: true
  validates :model_id, presence: true
  validates :controller, presence: true
end
