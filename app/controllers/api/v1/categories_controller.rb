# app/controllers/api/v1/categories_controller.rb
module Api
  module V1
    class CategoriesController < ApplicationController
      skip_before_action :authenticate_request, only: [ :index, :show ]
      skip_after_action :verify_authorized, only: [ :index, :show ]
      skip_after_action :verify_policy_scoped, only: [ :index, :show ]

      def index
        @categories = policy_scope(Category.active)
        render json: @categories, each_serializer: CategorySerializer
      end

      def show
        @category = Category.find(params[:id])
        render json: @category, serializer: CategorySerializer
      end

      def create
        @category = Category.new(category_params)
        authorize @category

        if @category.save
          handle_image_upload
          render json: @category, serializer: CategorySerializer, status: :created
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @category = Category.find(params[:id])
        authorize @category

        if @category.update(category_params)
          handle_image_upload
          render json: @category, serializer: CategorySerializer
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def category_params
        params.require(:category).permit(:name, :description, :is_active)
      end

      def handle_image_upload
        @category.image.attach(params[:image]) if params[:image].present?
      end
    end
  end
end
