class AuthorizationRequest::APIInfinoeProduction < AuthorizationRequest
  %i[
    homologation_autorite_nom
    homologation_autorite_fonction
    homologation_date_debut
    homologation_date_fin

    volumetrie_appels_par_minute
  ].each do |attr|
    add_attribute attr, validation: { presence: true, if: :need_complete_validation? }
  end

  validates :homologation_date_debut, timeliness: { type: :date }, if: :need_complete_validation?
  validates :homologation_date_fin, timeliness: { after: :homologation_date_debut, type: :date }, if: :need_complete_validation?

  add_attribute :recette_fonctionnelle, validation: { presence: true, inclusion: ['1'], if: :need_complete_validation? }

  add_attribute :sandbox_authorization_request_id

  belongs_to :sandbox_authorization_request,
    class_name: 'AuthorizationRequest::APIInfinoeSandbox'
  def sandbox_authorization_request=(model)
    self.sandbox_authorization_request_id = model&.id
  end

  def sandbox_authorization_request
    @sandbox_authorization_request ||= AuthorizationRequest::APIInfinoeSandbox.find_by(id: sandbox_authorization_request_id)
  end
end
