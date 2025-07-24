class Instruction::DashboardController < Instruction::AbstractAuthorizationRequestsController
  before_action :redirect_to_searched_record
  before_action :save_or_load_search_params

  skip_before_action :extract_authorization_request

  Tab = Data.define(:id, :path, :count)

  def show
    case params[:id]
    when 'habilitations'
      search_object = Instruction::Search::DashboardHabilitationsSearch.new(
        params: params,
        scope: policy_scope([:instruction, Authorization])
      )
      @facade = Instruction::DashboardHabilitationsFacade.new(search_object: search_object)
    when 'demandes'
      search_object = Instruction::Search::DashboardDemandesSearch.new(
        params: params,
        scope: policy_scope([:instruction, AuthorizationRequest])
      )
      @facade = Instruction::DashboardDemandesFacade.new(search_object: search_object)
    else
      redirect_to(instruction_dashboard_show_path(id: 'demandes')) and return
    end
  end

  private

  def find_searched_record
    case params[:id]
    when 'demandes'
      AuthorizationRequest.find_by(id: params[:search_query][Instruction::Search::DashboardSearch.key])
    when 'habilitations'
      Authorization.find_by(id: params[:search_query][Instruction::Search::DashboardSearch.key])
    end
  end

  def load_search_params
    params[:search_query] = JSON.parse(cookies[search_key] || '{}') if params[:search_query].blank?
  end

  def redirect_to_searched_record
    return unless search_terms_is_a_possible_id?

    candidate = find_searched_record
    return unless candidate

    authorize [:instruction, candidate], :show?

    redirect_to search_record_path(candidate)
  rescue Pundit::NotAuthorizedError
    nil
  end

  def save_or_load_search_params
    save_search_params
    load_search_params
  end

  def save_search_params
    cookies[search_key] = { value: params[:search_query].to_json, expires: 1.month.from_now } if params[:search_query].present?
  end

  def search_key
    :"#{controller_name}_#{action_name}_#{params[:id]}_search"
  end

  def search_record_path(record)
    case params[:id]
    when 'demandes'
      instruction_authorization_request_path(record)
    when 'habilitations'
      authorization_path(record)
    end
  end

  def search_terms_is_a_possible_id?
    Instruction::Search::DashboardSearch.search_terms_is_a_possible_id?(params)
  end
end
