class Datagouv::UploadHabilitationsCsv < ApplicationInteractor
  def call
    client.upload_resource(context.csv_path)
    client.update_resource_title(resource_title)
    client.update_dataset_temporal_coverage(start_date: Time.zone.today.beginning_of_month)
  end

  private

  def client
    @client ||= DatagouvAPIClient.new
  end

  def resource_title
    date_str = Time.zone.today.strftime('%d.%m.%y')
    "Habilitations Datapass validées au #{date_str}.csv"
  end
end
