#!/bin/bash

LOCAL=true bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)"
LOCAL=true bundle exec rails runner "MainImport.new.perform"
LOCAL=true bundle exec rails runner "
ActiveRecord::Base.transaction do
  User.find_by(email: 'user@yopmail.com').try(:destroy)
  user = User.find_by(email: 'philippe.vrignaud@modernisation.gouv.fr')
  instructor_roles = AuthorizationDefinition.all.map { |definition| \"#{definition.id}:instructor\" }
  user.update!(email: 'user@yopmail.com', roles: ['admin'] + instructor_roles)

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
