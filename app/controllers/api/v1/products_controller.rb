# app/controllers/api/v1/products_controller.rb
module Api
  module V1
    class ProductsController < ApplicationController
      skip_before_action :authenticate_request, only: [ :index, :show, :search ]
      skip_after_action :verify_authorized, only: :search

      def index
        @pagy, @products = pagy(
          policy_scope(Product.with_attached_images),
          page: params[:page],
          limit: params[:per_page]
        )
        render json: @products,
               root: "products",
               each_serializer: ProductSerializer,
               meta: pagination_metadata(@pagy),
               adapter: :json
      end

      def show
        @product = Product.find(params[:id])
        authorize @product
        render json: @product, serializer: ProductDetailSerializer
      end

      def create
        @product = Product.new(product_params)
        authorize @product

        if @product.save
          handle_image_uploads
          render json: @product, serializer: ProductSerializer, status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @product = Product.find(params[:id])
        authorize @product

        if @product.update(product_params)
          handle_image_uploads
          render json: @product, serializer: ProductSerializer
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @product = Product.find(params[:id])
        authorize @product

        if @product.destroy
          render json: { message: "Product deleted successfully" }, status: :ok
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def search
        @results = Product.search_with_filters(params[:q], params)

        render json: {
          products: @results.map { |result| ProductSerializer.new(result.record).as_json },
          total: @results.total_count,
          page: params[:page] || 1,
          per_page: params[:per_page] || 20
        }
      end

      private

      def product_params
        params.require(:product).permit(:name, :description, :price, :sku, :quantity_in_stock, :category_id, :discount_percentage, :is_active)
      end

      def handle_image_uploads
        return unless params[:images].present?

        params[:images].each do |image|
          @product.images.attach(image)
        end
      end



      def pagination_metadata(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_items: pagy.count,
          per_page: pagy.limit,
          next_page: pagy.next
          # prev_page: pagy.prev
        }
      end
    end
  end
end
