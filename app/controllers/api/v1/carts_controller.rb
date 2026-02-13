
# app/controllers/api/v1/carts_controller.rb
module Api
  module V1
    class CartsController < ApplicationController
      def show
        @cart = current_user.carts.first_or_create
        authorize @cart
        render json: @cart, serializer: CartSerializer
      end

      def add_item
        @cart = current_user.carts.first_or_create
        authorize @cart

        service = CartService.new(@cart)
        if service.add_item(params[:product_id], params[:quantity] || 1)
          render json: @cart, serializer: CartSerializer, status: :ok
        else
          render json: { error: service.error }, status: :unprocessable_entity
        end
      end

      def update_item
        @cart = current_user.carts.first_or_create
        authorize @cart

        service = CartService.new(@cart)
        if service.update_item(params[:id], params[:quantity])
          render json: @cart, serializer: CartSerializer
        else
          render json: { errors: service.error }, status: :unprocessable_entity
        end
      end

      def remove_item
        @cart = current_user.carts.first_or_create
        authorize @cart

        service = CartService.new(@cart)
        service.remove_item(params[:product_id])
        render json: @cart, serializer: CartSerializer
      end

      def clear
        @cart = current_user.carts.first_or_create
        authorize @cart

        service = CartService.new(@cart)
        service.clear
        render json: { message: "Cart cleared" }, status: :ok
      end
    end
  end
end
