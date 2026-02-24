# frozen_string_literal: true

class RemoveAidesEtatAndDgeProvider < ActiveRecord::Migration[8.0]
  def up
    AuthorizationRequest.where(type: 'AuthorizationRequest::AidesEtat').destroy_all

    dge = DataProvider.find_by(slug: 'dge')
    dge&.logo&.purge
    dge&.destroy
  end

  def down
  end
end
