class MigrateAPIEntrepriseTvaScopeFromViesToDGFIP < ActiveRecord::Migration[8.1]
  def up
    service.up
  end

  def down
    service.down
  end

  private

  def service
    ScopeMigrationService.new(
      'AuthorizationRequest::APIEntreprise',
      'open_data_numero_tva_commission_europeenne' => 'open_data_numero_tva_dgfip'
    )
  end
end
