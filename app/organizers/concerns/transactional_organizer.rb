module TransactionalOrganizer
  extend ActiveSupport::Concern

  included do
    around do |organizer|
      ActiveRecord::Base.transaction(requires_new: true) { organizer.call }
    end
  end
end
