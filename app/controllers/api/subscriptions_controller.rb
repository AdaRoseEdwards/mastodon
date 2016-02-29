class Api::SubscriptionsController < ApplicationController
  before_action :set_account

  def show
    if @account.subscription(api_subscription_url(@account.id)).valid?(params['hub.topic'], params['hub.verify_token'])
      render text: params['hub.challenge'], status: 200
    else
      render nothing: true, status: 404
    end
  end

  def update
    body = request.body.read

    if @account.subscription(api_subscription_url(@account.id)).verify(body, env['HTTP_X_HUB_SIGNATURE'])
      ProcessFeedService.new.(body, @account)
      render nothing: true, status: 201
    else
      render nothing: true, status: 202
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end