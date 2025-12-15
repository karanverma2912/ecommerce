# app/controllers/api/v1/webhooks_controller.rb
module Api
  module V1
    class WebhooksController < ApplicationController
      skip_before_action :authenticate_request

      def stripe
        payload = request.body.read
        sig_header = request.headers["Stripe-Signature"]

        begin
          event = Stripe::Webhook.construct_event(
            payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"]
          )
        rescue JSON::ParserError => e
          render json: { error: "Invalid payload" }, status: 400
          return
        rescue Stripe::SignatureVerificationError => e
          render json: { error: "Invalid signature" }, status: 400
          return
        end

        case event.type
        when "checkout.session.completed"
          handle_checkout_session_completed(event.data.object)
        when "charge.refunded"
          handle_charge_refunded(event.data.object)
        when "payment_intent.payment_failed"
          handle_payment_failed(event.data.object)
        end

        render json: { status: "success" }, status: 200
      end

      private

      def handle_checkout_session_completed(session)
        order = Order.find(session.client_reference_id)
        order.update(
          payment_status: :paid,
          stripe_payment_id: session.payment_intent,
          status: :processing
        )
        PaymentConfirmationJob.perform_later(order.id)
      end

      def handle_charge_refunded(charge)
        order = Order.find_by(stripe_payment_id: charge.payment_intent)
        order&.update(payment_status: :refunded)
      end

      def handle_payment_failed(intent)
        order = Order.find_by(stripe_payment_id: intent.id)
        order&.update(payment_status: :failed)
      end
    end
  end
end
