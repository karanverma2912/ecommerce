
# app/controllers/api/v1/carts_controller.rb
module Api
  module V1
    class CartsController < ApplicationController
      before_action :set_cart_and_authorize

      def show
        render json: @cart, serializer: CartSerializer
      end

      def add_item
        service = CartService.new(@cart)
        if service.add_item(params[:product_id], params[:quantity] || 1)
          render json: @cart, serializer: CartSerializer, status: :ok
        else
          render json: { error: service.error }, status: :unprocessable_entity
        end
      end

      def update_item
        service = CartService.new(@cart)
        if service.update_item(params[:id], params[:quantity])
          render json: @cart, serializer: CartSerializer
        else
          render json: { errors: service.error }, status: :unprocessable_entity
        end
      end

      def remove_item
        service = CartService.new(@cart)
        service.remove_item(params[:product_id])
        render json: @cart, serializer: CartSerializer
      end

      def clear
        service = CartService.new(@cart)
        service.clear
        render json: { message: "Cart cleared" }, status: :ok
      end

      private

      def set_cart_and_authorize
        @cart = current_user.carts.first_or_create
        authorize @cart
      end
    end
  end
end
