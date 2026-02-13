class CheckoutService
  attr_reader :user, :cart, :shipping_address, :order, :error

  def initialize(user:, cart:, shipping_address:)
    @user = user
    @cart = cart
    @shipping_address = shipping_address
    @error = nil
  end

  def call
    return false unless validate_address
    return false unless check_stock
    
    ActiveRecord::Base.transaction do
      create_order
      raise ActiveRecord::Rollback unless @order.persisted?
    end

    return false unless @order&.persisted?

    session = create_stripe_session
    { order: @order, checkout_url: session.url }
  rescue StandardError => e
    @error = e.message
    false
  end

  private

  def validate_address
    unless valid_address_format?
      @error = "Invalid shipping address. Please provide street, city, state, zip_code, and country."
      return false
    end
    true
  end

  def valid_address_format?
    return false unless @shipping_address.is_a?(ActionController::Parameters) || @shipping_address.is_a?(Hash)
    required_fields = %w[street city state zip_code country]
    required_fields.all? { |field| @shipping_address[field].present? }
  end

  def check_stock
    order = Order.new
    unless order.check_stock!(@cart)
      @error = order.errors.full_messages.join(", ")
      return false
    end
    true
  end

  def create_order
    @order = Order.new
    unless @order.create_from_cart(@cart, @shipping_address.to_json)
      @error = @order.errors.full_messages.join(", ")
    end
  end

  def create_stripe_session
    Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: build_line_items,
      mode: "payment",
      success_url: "#{ENV['FRONTEND_URL']}/orders/#{@order.id}/success",
      cancel_url: "#{ENV['FRONTEND_URL']}/orders/#{@order.id}/cancel",
      client_reference_id: @order.id.to_s,
      customer_email: @user.email,
      metadata: {
        order_id: @order.id,
        user_id: @user.id
      }
    )
  end

  def build_line_items
    @order.order_items.map do |item|
      {
        price_data: {
          currency: "usd",
          product_data: {
            name: item.product.name,
            description: item.product.description,
            images: [ product_image_url(item.product) ]
          },
          unit_amount: (item.price * 100).to_i
        },
        quantity: item.quantity
      }
    end
  end

  def product_image_url(product)
    # Note: In a real service, URL generation might need helpers or a dedicated serializer/presenter.
    # We'll use a placeholder for now to keep it simple and dependency-free, 
    # or rely on active storage valid urls if we include UrlHelpers.
    # For now, let's stick to the logic from the controller:
    if product.images.attached? 
       Rails.application.routes.url_helpers.url_for(product.images.first)
    else
       "https://via.placeholder.com/400"
    end
  end
end
