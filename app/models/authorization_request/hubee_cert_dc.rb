class AuthorizationRequest::HubEECertDC < AuthorizationRequest
  add_attributes :intitule, :description

  validates :intitule, presence: true
  validates :description, presence: true, if: :need_complete_validation?
end
