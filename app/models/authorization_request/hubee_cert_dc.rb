class AuthorizationRequest::HubEECertDC < AuthorizationRequest
  add_attributes :intitule, :description

  add_document :cadre_juridique, content_type: ['application/pdf'], size: { less_than: 10.megabytes, message: 'La taille du fichier ne doit pas dépasser 10 Mo' }

  validates :intitule, presence: true
  validates :description, presence: true, if: :need_complete_validation?

  add_scopes

  contact :administrateur_metier
end
