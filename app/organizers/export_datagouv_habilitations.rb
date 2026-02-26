class ExportDatagouvHabilitations < ApplicationOrganizer
  organize Datagouv::BuildHabilitationsRows,
    Datagouv::GenerateHabilitationsCsv,
    Datagouv::UploadHabilitationsCsv
end
