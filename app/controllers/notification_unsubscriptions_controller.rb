class NotificationUnsubscriptionsController < AuthenticatedUserController
  allow_unauthenticated_access
  layout 'notification_unsubscription'

  before_action :decode_token

  def show
    render 'invalid' unless valid_request?
  end

  def create
    return render 'invalid' unless valid_request?

    Notifications::Unsubscribe.call(user: @user, definition_id: @definition_id, kind: @kind)
    render 'success'
  end

  private

  def decode_token
    payload = NotificationUnsubscribeToken.decode(params[:token])
    return unless payload

    @user = User.find_by(id: payload[:user_id])
    @definition_id = payload[:definition_id]
    @kind = payload[:kind]
  end

  def valid_request?
    @user.present? && still_has_role?
  end

  def still_has_role?
    @kind == 'submit' ? @user.reporter?(@definition_id) : @user.instructor?(@definition_id)
  end
end
