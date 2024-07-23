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
      'email' => 'example@admin.fr',
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
      validateDateTime: '2024-07-08T14:31:43+02:00',
      updateDateTime: '2024-07-08T14:31:43+02:00',
      status: 'Inactif',
      email: 'example@admin.fr',
      localAdministrator: {
        email: 'example@admin.fr',
      }
    }
  end

  def subscription_response
    {
      'creationDateTime' => '2024-07-11T10:41:04.861+00:00',
      'datapassId' => 2,
      'email' => 'example@admin.fr',
      'id' => 'd8b00b31-9bb2-4fba-bd55-14776ecdc8f6',
      'localAdministrator' => { 'email' => 'example@admin.fr' },
      'notificationFrequency' => 'unitaire',
      'processCode' => 'CERTDC',
      'status' => 'Inactif',
      'subscriber' => { 'branchCode' => '83139', 'companyRegister' => '21830139800010', 'type' => 'SI' },
      'updateDateTime' => '2024-07-11T10:41:04+0000',
      'validateDateTime' => '2024-07-08T14:31:43+02:00'
    }
  end
end
