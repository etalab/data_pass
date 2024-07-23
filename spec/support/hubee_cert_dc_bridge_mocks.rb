# frozen_string_literal: true

module HubEECertDCBridgeMocks
  def organization_bridge_payload
    {
      type: 'SI',
      companyRegister: '21920023500014',
      branchCode: '92023',
      name: 'COMMUNE DE CLAMART',
      code: nil,
      country: 'France',
      postalCode: '92140',
      territory: 'CLAMART',
      email: 'admin@yopmail.com',
      phoneNumber: '0123456789',
      status: 'Actif'
    }
  end

  def subscription_body_payload(process_code)
    {
      datapassId: 2,
      processCode: process_code,
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
end
