
# app/controllers/api/v1/reviews_controller.rb
module Api
  module V1
    class ReviewsController < ApplicationController
      skip_before_action :authenticate_request, only: [ :index ]
      skip_after_action :verify_authorized, only: [ :index ]
      skip_after_action :verify_policy_scoped, only: [ :index ]

      def index
        @product = Product.find(params[:product_id])
        @pagy, @reviews = pagy(@product.reviews.recent, items: 10)
        render json: {
          reviews: ActiveModelSerializers::SerializableResource.new(@reviews, each_serializer: ReviewSerializer),
          pagination: pagination_metadata(@pagy)
        }
      end

      def create
        @product = Product.find(params[:product_id])
        @review = @product.reviews.build(review_params)
        @review.user = current_user

        if @review.save
          render json: @review, serializer: ReviewSerializer, status: :created
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @review = Review.find(params[:id])
        authorize @review

        if @review.destroy
          render json: { message: "Review deleted" }, status: :ok
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def review_params
        params.require(:review).permit(:rating, :comment)
      end

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
