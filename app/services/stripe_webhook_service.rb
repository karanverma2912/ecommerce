class StripeWebhookService
  attr_reader :error

  def initialize(payload, signature)
    @payload = payload
    @signature = signature
    @error = nil
  end

  def call
    begin
      event = Stripe::Webhook.construct_event(
        @payload, @signature, ENV["STRIPE_WEBHOOK_SECRET"]
      )
    rescue JSON::ParserError
      @error = "Invalid payload"
      return false
    rescue Stripe::SignatureVerificationError
      @error = "Invalid signature"
      return false
    end

    handle_event(event)
    true
  end

  private

  def handle_event(event)
    data = event.data.object

    case event.type
    when "checkout.session.completed"
      handle_checkout_session_completed(data)
    when "charge.refunded"
      handle_charge_refunded(data)
    when "payment_intent.payment_failed"
      handle_payment_failed(data)
    end
  end

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
