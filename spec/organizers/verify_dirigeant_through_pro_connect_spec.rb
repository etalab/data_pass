RSpec.describe VerifyDirigeantThroughProConnect do
  it 'checks the certification, the account and the SIRET, then describes the verification' do
    expect(described_class.organized).to eq([
      CheckProConnectDirigeantAcr,
      CheckProConnectDirigeantIdentity,
      CheckProConnectDirigeantSiret,
      AssignProConnectDirigeantVerification
    ])
  end
end
