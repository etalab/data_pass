class ClearBucket
  def perform
    s3_client.list_objects(bucket: bucket_name).contents.each do |object|
      s3_client.delete_object(bucket: bucket_name, key: object.key)
    end
  end

  private

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      endpoint: "https://s3.#{Rails.application.credentials.dig(:ovh_region)}.io.cloud.ovh.net/",
      credentials: Aws::Credentials.new(Rails.application.credentials.dig(:ovh_access_key_id), Rails.application.credentials.dig(:ovh_secret_key)),
      region: Rails.application.credentials.dig(:ovh_region).downcase,
    )
  end

  def bucket_name
    "datapass-v2-#{Rails.env}"
  end
end
