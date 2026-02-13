
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
        shipping_address = params[:shipping_address]

        service = CheckoutService.new(
          user: current_user,
          cart: @cart,
          shipping_address: shipping_address
        )

        result = service.call

        if result
          render json: {
            order: OrderSerializer.new(result[:order]).as_json,
            checkout_url: result[:checkout_url]
          }, status: :created
        else
          render json: { error: service.error }, status: :unprocessable_entity
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
