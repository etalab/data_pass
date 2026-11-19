class VerifyDirigeantThroughProConnect < ApplicationOrganizer
  organize CheckProConnectDirigeantAcr,
    CheckProConnectDirigeantIdentity,
    CheckProConnectDirigeantSiret,
    AssignProConnectDirigeantVerification
end
