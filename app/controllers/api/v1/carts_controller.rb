
# app/controllers/api/v1/carts_controller.rb
module Api
  module V1
    class CartsController < ApplicationController
      def show
        @cart = current_user.carts.first_or_create
        render json: @cart, serializer: CartSerializer
      end

      def add_item
        @cart = current_user.carts.first_or_create
        @product = Product.find(params[:product_id])

        if @product.in_stock?
          @cart.add_product(@product, params[:quantity] || 1)
          render json: @cart, serializer: CartSerializer, status: :ok
        else
          render json: { error: "Product is out of stock" }, status: :unprocessable_entity
        end
      end

      def update_item
        @cart = current_user.carts.first_or_create
        @cart_item = @cart.cart_items.find(params[:id])

        if @cart_item.update(quantity: params[:quantity])
          @cart.update_total_price
          render json: @cart, serializer: CartSerializer
        else
          render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def remove_item
        @cart = current_user.carts.first_or_create
        @cart.remove_product(params[:product_id])
        render json: @cart, serializer: CartSerializer
      end

      def clear
        @cart = current_user.carts.first_or_create
        @cart.clear
        render json: { message: "Cart cleared" }, status: :ok
      end
    end
  end
end
