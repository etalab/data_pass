class DGFIP::ExportController < AuthenticatedUserController
  before_action :abort_if_not_admin_nor_dgfip_reporter

  def show
    send_data spreadsheet.to_stream.read,
      filename: "export-datapass-#{Time.zone.today}.xlsx",
      type: 'application/xlsx'
  end

  private

  def spreadsheet
    DGFIPSpreadsheetGenerator.new(authorization_requests).perform
  end

  def authorization_requests
    AuthorizationRequest
      .includes(:organization, :authorizations)
      .where(form_uid: dgfip_form_uids)
      .where.not(state: 'archived')
  end

  def dgfip_form_uids
    dgfip_form_uid_groups.flatten
  end

  def dgfip_form_uid_groups
    dgfip_authorization_definitions.map do |authorization_definition|
      authorization_definition.available_forms.map(&:uid)
    end
  end

  def dgfip_authorization_definitions
    @dgfip_authorization_definitions ||= data_provider.authorization_definitions
  end

  def data_provider
    @data_provider ||= DataProvider.find('dgfip')
  end

  def abort_if_not_admin_nor_dgfip_reporter
    return if current_user.admin?
    return if dgfip_reporter?

    head :forbidden
  end

  def dgfip_reporter?
    data_provider.reporters.exists?(id: current_user.id)
  end
end
