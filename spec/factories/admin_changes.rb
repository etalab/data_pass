FactoryBot.define do
  factory :admin_change do
    authorization_request factory: %i[authorization_request api_entreprise]
    public_reason { 'Correction des données suite à une demande de support' }
    private_reason { 'Ticket #SP-1234' }
    diff { { 'contact_technique_email' => ['ancien@email.com', 'nouveau@email.com'] } }
  end
end
