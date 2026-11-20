class WalletRegistry::IntendedUseClaim < ApplicationRecord
  belongs_to :intended_use_attestation, class_name: 'WalletRegistry::IntendedUseAttestation', inverse_of: :requested_claims
  belongs_to :rulebook_claim, class_name: 'WalletRegistry::RulebookClaim'
end
