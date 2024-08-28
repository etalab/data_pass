class HubEEImport
  include Singleton
  include ImportUtils

  def build_csv_from_api
    return if dumps_path('hubee_cert_dc').exists?

    # utiliser le code du gist ici
  end

  def post_main_import
    build_csv_from_api
    create_hubee_subscriptions_for_existing_authorization_requests
    create_or_update_existing_datapass_from_hubee_subscriptions
  end

  def create_hubee_subscriptions_for_existing_authorization_requests
    [
      AuthorizationRequest::HubEECertDC,
      AuthorizationRequest::HubEEDila,
    ].each do |model_klass|
      model_klass.find_each do |authorization_request|
        next if data_for(authorization_request.kind).any? { |csv| csv['datapass_id'] == authorization_request.id && }

        ExecuteAuthorizationRequestBridge.call(authorization_request:)
        sleep 0.1
      end
    end
  end

  def create_or_update_existing_datapass_from_hubee_subscriptions
    [
      AuthorizationRequest::HubEECertDC,
      AuthorizationRequest::HubEEDila,
    ].each do |model_klass|
      subscriptions = datas_for(model_klass.new.kind)
      all_models = model_klass.all

      subscriptions.each do |subscription|
        if subscription['datapass_id'].present? &&
        potential_existing_model = all_models.select { |model| model.id == subscription['datapass_id']}
      end
    end
  end

  private

  def data_for(kind)
    @datas ||= {}
    @datas[kind] ||= csv(kind)
    @datas[kind]
  end
end
