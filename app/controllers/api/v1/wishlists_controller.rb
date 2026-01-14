
# app/controllers/api/v1/wishlists_controller.rb
module Api
  module V1
    class WishlistsController < ApplicationController
      def index
        @pagy, @wishlists = pagy(policy_scope(Wishlist).includes(:product), items: 20)
        authorize @wishlists
        render json: {
          wishlists: ActiveModelSerializers::SerializableResource.new(@wishlists, each_serializer: WishlistSerializer),
          pagination: pagination_metadata(@pagy)
        }
      end

      def add
        @product = Product.find(params[:product_id])
        @wishlist = current_user.wishlists.build(product_id: @product.id)
        authorize @wishlist

        if @wishlist.save
          render json: { message: "Added to wishlist" }, status: :created
        else
          render json: { errors: @wishlist.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def remove
        @wishlist = current_user.wishlists.find_by(product_id: params[:product_id])
        
        if @wishlist
          authorize @wishlist
          @wishlist.destroy
          render json: { message: "Removed from wishlist" }, status: :ok
        else
          skip_authorization
          render json: { error: "Wishlist item not found" }, status: :not_found
        end
      end

      private

      def pagination_metadata(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_items: pagy.count
        }
      end
    end
  end
end
