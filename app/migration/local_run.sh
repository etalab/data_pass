#!/bin/bash

# bundle exec rails db:schema:load
LOCAL=true time bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)"
LOCAL=true time bundle exec rails runner "MainImport.new.perform"
LOCAL=true bundle exec rails runner "
ActiveRecord::Base.transaction do
  User.find_by(email: 'user@yopmail.com').try(:destroy)
  user = User.find_by(email: 'philippe.vrignaud@modernisation.gouv.fr')
  user.update!(email: 'user@yopmail.com', roles: ['api_entreprise:instructor'])

  common_entities_data = {
    applicant_id: user.id,
    organization_id: user.current_organization_id,
  }

  authorization_request = AuthorizationRequest.where(form_uid: 'api-entreprise-mgdis').last
  authorization_request.update!(common_entities_data)

  authorization_request = AuthorizationRequest.where(form_uid: 'api-entreprise-marches-publics').last
  authorization_request.update!(common_entities_data)
end
"
