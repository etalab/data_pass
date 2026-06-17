class NotificationUnsubscriptionsController < AuthenticatedUserController
  allow_unauthenticated_access
  layout 'notification_unsubscription'

  before_action :decode_token

  helper_method :authorization_definition, :kind_label

  def show
    return render 'invalid' if @user.blank?
    return if still_has_role?

    @already_unsubscribed = true
    render 'success'
  end

  def create
    return render 'invalid' if @user.blank?

    @already_unsubscribed =
      if still_has_role?
        Notifications::Unsubscribe.call(user: @user, definition_id: @definition_id, kind: @kind).already_unsubscribed
      else
        true
      end

    render 'success'
  end

  private

  def authorization_definition
    @authorization_definition ||= AuthorizationDefinition.find(@definition_id)
  end

  def kind_label
    t("notification_unsubscriptions.kinds.#{@kind}")
  end

  def decode_token
    payload = NotificationUnsubscribeToken.decode(params[:token])
    return unless payload

    @user = User.find_by(id: payload[:user_id])
    @definition_id = payload[:definition_id]
    @kind = payload[:kind]
  end

  def still_has_role?
    @kind == 'submit' ? @user.reporter?(@definition_id) : @user.instructor?(@definition_id)
  end

  def track_impersonation_action
    return if @user.nil?

    super
  end

  def model_to_track_for_impersonation
    @user
  end
end
