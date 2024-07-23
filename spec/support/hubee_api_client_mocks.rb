# frozen_string_literal: true

module HubEEAPIClientMocks
  def organization_payload
    {
      'type' => 'SI',
      'companyRegister' => '21920023500014',
      'branchCode' => '92023',
      'name' => 'COMMUNE DE CLAMART',
      'code' => nil,
      'country' => 'France',
      'postalCode' => '92140',
      'territory' => 'CLAMART',
      'email' => 'admin@yopmail.com',
      'phoneNumber' => '0123456789',
      'status' => 'ACTIF'
    }
  end

  def subscription_body
    {
      datapassId: 1,
      processCode: 'CERTDC',
      subscriber: {
        type: 'SI',
        companyRegister: '21920023500014',
        branchCode: '92023',
      },
      notificationFrequency: 'unitaire',
      validateDateTime: '2024-07-18T14:00:55+02:00',
      updateDateTime: '2024-07-18T14:00:55+02:00',
      status: 'Inactif',
      email: 'admin@yopmail.com',
      localAdministrator: {
        email: 'admin@yopmail.com',
      }
    }
  end

  def subscription_response
    {
      'accessMode' => nil,
      'activateDateTime' => nil,
      'creationDateTime' => '2024-07-18T14:00:55+02:00',
      'datapassId' => 2,
      'delegationActor' => nil,
      'email' => 'admin@yopmail.com',
      'endDateTime' => nil,
      'id' => '22',
      'localAdministrator' => { 'email' => 'admin@yopmail.com' },
      'notificationFrequency' => 'unitaire',
      'processCode' => 'CERTDC',
      'rejectDateTime' => nil,
      'rejectionReason' => nil,
      'status' => 'Inactif',
      'subscriber' => { 'branchCode' => '213302722', 'companyRegister' => '21330272200011', 'type' => 'SI' },
      'updateDateTime' => '2024-07-18T14:00:55+02:00',
      'validateDateTime' => '2024-07-18T14:00:55+02:00'
    }
  end
end
