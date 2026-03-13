class Datagouv::UploadHabilitationsCsv < ApplicationInteractor
  def call
    client.upload_resource(context.csv_path)
    client.update_resource_title(resource_title)
    client.update_dataset_temporal_coverage(start_date: temporal_coverage_start_date)
  end

  private

  def client
    @client ||= DatagouvAPIClient.new
  end

  def resource_title
    date_str = Time.zone.today.strftime('%d.%m.%y')
    "Habilitations Datapass validées au #{date_str}.csv"
  end

  def temporal_coverage_start_date
    context.authorizations.order(:created_at).first&.created_at&.to_date
  end
end
