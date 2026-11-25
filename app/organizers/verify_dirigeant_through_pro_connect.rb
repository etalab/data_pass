class VerifyDirigeantThroughProConnect < ApplicationOrganizer
  organize CheckProConnectDirigeantACR,
    CheckProConnectDirigeantIdentity,
    CheckProConnectDirigeantSiret,
    AssignProConnectDirigeantVerification
end
