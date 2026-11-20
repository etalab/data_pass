class AuthorizationRequestForms::WalletRulebooksController < AuthorizationRequestFormsController
  helper WalletIntendedUsesHelper

  before_action :extract_authorization_request

  def index
    authorize @authorization_request, :update?

    @intended_use = WalletRegistry::IntendedUse.includes(:requested_attestations).find_by!(authorization_request_id: @authorization_request.id, id: params.expect(:intended_use_id))
    @query = params[:q].to_s.strip
    @rulebooks = WalletRegistry::Rulebook.for_catalog.search(@query).to_a

    turbo_frame_request? ? render_results : render(:index, layout: 'container')
  end

  private

  def render_results
    render partial: 'authorization_request_forms/wallet_rulebooks/results', locals: { use: @intended_use, rulebooks: @rulebooks, embedded: true }
  end

  def extract_authorization_request
    @authorization_request = authorization_request_class.find(params.expect(:authorization_request_id)).decorate
  end

  def user_not_authorized
    head :forbidden
  end
end
