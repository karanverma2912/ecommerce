
# app/controllers/api/v1/orders_controller.rb
module Api
  module V1
    class OrdersController < ApplicationController
      def index
        @pagy, @orders = pagy(current_user.orders.recent, items: 10)
        render json: {
            orders: ActiveModelSerializers::SerializableResource.new(@orders, each_serializer: OrderSerializer),
          pagination: pagination_metadata(@pagy)
        }
      end

      def show
        @order = Order.includes(order_items: { product: { images_attachments: :blob } }).find(params[:id])
        authorize @order
        render json: @order, serializer: OrderDetailSerializer
      end

      def create
        @cart = current_user.carts.first_or_create
        @order = Order.new

        if @order.create_from_cart(@cart, params[:shipping_address])
          session = create_stripe_session(@order)
          render json: {
            order: OrderSerializer.new(@order).as_json,
            checkout_url: session.url
          }, status: :created
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update_status
        @order = Order.find(params[:id])
        authorize @order

        if @order.update(status: params[:status])
          render json: @order, serializer: OrderSerializer
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def create_stripe_session(order)
        Stripe::Checkout::Session.create(
          payment_method_types: [ "card" ],
          line_items: build_line_items(order),
          mode: "payment",
          success_url: "#{ENV['FRONTEND_URL']}/orders/#{order.id}/success",
          cancel_url: "#{ENV['FRONTEND_URL']}/orders/#{order.id}/cancel",
          client_reference_id: order.id.to_s,
          customer_email: current_user.email,
          metadata: {
            order_id: order.id,
            user_id: current_user.id
          }
        )
      end

      def build_line_items(order)
        order.order_items.map do |item|
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
        product.images.first.attached? ? url_for(product.images.first) : "https://via.placeholder.com/400"
      end

      def pagination_metadata(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_items: pagy.count,
          per_page: pagy.items,
          next_page: pagy.next,
          prev_page: pagy.prev
        }
      end
    end
  end
end
