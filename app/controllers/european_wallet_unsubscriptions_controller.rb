class EuropeanWalletUnsubscriptionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access

  before_action :find_subscriber

  def show
    render 'unsubscribed' if @subscriber.blank?
  end

  def create
    @subscriber&.destroy!

    render 'unsubscribed'
  end

  private

  def find_subscriber
    @subscriber = EuropeanWalletSubscriber.find_by_token_for(:unsubscribe, params[:token].to_s)
  end

  def layout_name
    'notification_unsubscription'
  end

  def track_impersonation_action
    return if model_to_track_for_impersonation.nil?

    super
  end

  def model_to_track_for_impersonation
    @subscriber
  end
end
