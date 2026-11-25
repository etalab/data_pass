RSpec.describe VerifyDirigeantThroughProConnect do
  it 'checks the certification, the account and the SIRET, then describes and records the verification' do
    expect(described_class.organized).to eq([
      CheckProConnectDirigeantACR,
      CheckProConnectDirigeantIdentity,
      CheckProConnectDirigeantSiret,
      AssignProConnectDirigeantVerification,
      RecordProConnectDirigeantCertification
    ])
  end
end
