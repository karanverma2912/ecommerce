# app/controllers/api/v1/webhooks_controller.rb
module Api
  module V1
    class WebhooksController < ApplicationController
      skip_before_action :authenticate_request

      def stripe
        service = StripeWebhookService.new(request.body.read, request.headers["Stripe-Signature"])

        if service.call
          render json: { status: "success" }, status: 200
        else
          render json: { error: service.error }, status: 400
        end
      end
    end
  end
end
