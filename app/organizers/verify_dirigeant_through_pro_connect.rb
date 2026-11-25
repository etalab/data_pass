class VerifyDirigeantThroughProConnect < ApplicationOrganizer
  organize CheckProConnectDirigeantACR,
    CheckProConnectDirigeantIdentity,
    CheckProConnectDirigeantSiret,
    AssignProConnectDirigeantVerification,
    RecordProConnectDirigeantCertification
end
