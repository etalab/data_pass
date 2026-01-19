require_relative 'generate_report_2023_to_2025'

Stats::GenerateReport2023To2025.new.call
Stats::GenerateReport2023To2025.new(post_migration_only: true).call
Stats::GenerateReport2023To2025.new(provider: 'dinum').call
Stats::GenerateReport2023To2025.new(provider: 'dgfip', post_migration_only: true).call
Stats::GenerateReport2023To2025.new(provider: 'dgfip').call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::APIParticulier']).call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::APIEntreprise']).call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::HubEECertDC', 'AuthorizationRequest::HubEEDila']).call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::FranceConnect'], post_migration_only: true).call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::FranceConnect']).call
Stats::GenerateReport2023To2025.new(authorization_types: ['AuthorizationRequest::ProConnectServiceProvider', 'AuthorizationRequest::ProConnectIdentityProvider']).call