# @label Origine de l'habilitation (sous-en-tête)
class Habilitation::OriginHeaderInfoPreview < ApplicationPreview
  # @label 1. Avec formulaire et instructeur
  def with_form_and_instructor
    authorization = Authorization.joins(:approve_authorization_request_event)
      .where.not(form_uid: nil)
      .first!

    render Habilitation::OriginHeaderInfo.new(authorization: authorization)
  end

  # @label 2. Sans formulaire
  def without_form
    authorization = Authorization.where(form_uid: nil, parent_authorization_id: nil).first!

    render Habilitation::OriginHeaderInfo.new(authorization: authorization)
  end

  # @label 3. Auto-générée
  def auto_generated
    authorization = Authorization.where.not(parent_authorization_id: nil).first!

    render Habilitation::OriginHeaderInfo.new(authorization: authorization)
  end
end
