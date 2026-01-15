require_relative 'generate_report_2023_to_2025'
Stats::GenerateReport2023To2025.new.call
Stats::GenerateReport2023To2025.new(provider: 'dinum').call
Stats::GenerateReport2023To2025.new(provider: 'dgfip').call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::APIParticulier']).call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::APIEntreprise']).call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::HubEECertDC', 'AuthorizationRequest::HubEEDila']).call